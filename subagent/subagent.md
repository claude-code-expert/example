## How Subagents Work / 서브에이전트 동작 원리

> 📘 [github.com/claude-code-expert](https://github.com/claude-code-expert) — 클로드 코드 마스터 (한빛미디어 서적 공식 리포지토리) 
> ☕ [www.brewnet.dev](https://www.brewnet.dev) — 셀프 호스팅 홈서버 자동 구축 오픈소스


### What is a Subagent? / 서브에이전트란?

Claude Code의 서브에이전트는 메인 세션 안에서 **독립된 컨텍스트 윈도우**를 가지고 동작하는 전문화된 AI 인스턴스입니다. 일반적인 채팅에서 Claude에게 "코드 리뷰해줘"라고 하면 모든 분석 과정과 결과가 하나의 대화 컨텍스트에 쌓이지만, 서브에이전트에 위임하면 분석은 별도 윈도우에서 일어나고 메인에는 요약만 돌아옵니다.

A subagent is a specialized AI instance that runs inside your main Claude Code session with its **own independent context window**. When you ask Claude to "review this code" in a normal chat, all the analysis fills your main context. With a subagent, the heavy analysis happens in a separate window — only the summary returns to your main conversation.

### Why Use Subagents? / 왜 서브에이전트를 쓰나?

**1. Context preservation / 컨텍스트 보존**

```
Without subagent (서브에이전트 없이):
┌─────────────────────────────────────────┐
│ Main context window (200k tokens)       │
│                                         │
│ Your conversation          ██░░░░  30%  │
│ git diff output            ████░░  60%  │  ← diff가 컨텍스트를 잡아먹음
│ Review analysis            █████░  80%  │
│ Remaining for coding       ░░░░░░  20%  │  ← 작업 공간 부족
└─────────────────────────────────────────┘

With subagent (서브에이전트 사용):
┌─────────────────────────────────────────┐
│ Main context window (200k tokens)       │
│                                         │
│ Your conversation          ██░░░░  30%  │
│ Review summary (returned)  ██░░░░  35%  │  ← 요약만 반환
│ Remaining for coding       ░░░░░░  65%  │  ← 여유로운 작업 공간
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ Subagent context (separate window)      │
│ git diff, file reads, analysis...       │  ← 여기서 처리되고 사라짐
└─────────────────────────────────────────┘
```

**2. Tool scoping / 도구 제한**

각 에이전트에 허용할 도구를 명시적으로 지정할 수 있습니다. 리뷰어는 Read-only, 리팩토링은 Write만, 테스터는 Bash만 — 실수로 의도하지 않은 동작을 하는 것을 구조적으로 방지합니다.

Each agent gets only the tools it needs. A reviewer can't accidentally modify files. A refactoring agent can't run tests. A tester can't edit source code. This is enforced at the tool level, not by instruction alone.

**3. Parallel execution / 병렬 실행**

여러 서브에이전트를 동시에 스폰할 수 있습니다. "auth, payment, dashboard를 각각 리뷰해줘"라고 하면 3개의 squad-review가 병렬로 분석합니다.

Multiple subagents can run simultaneously. "Review auth, payment, and dashboard modules" spawns 3 parallel squad-review instances.

**4. Model routing / 모델 선택**

에이전트마다 다른 모델을 지정할 수 있습니다. 보안 리뷰는 opus(정밀), 커밋 메시지는 haiku(빠르고 저렴) — 작업 특성에 맞는 비용 최적화가 가능합니다.

Different agents can use different models. Security audits get opus (thorough), commit messages get haiku (fast and cheap).

### How It Works Internally / 내부 동작 방식

서브에이전트는 Claude Code의 **Task 도구**를 통해 호출됩니다. `bash`로 `claude -p`를 실행하는 것이 아닙니다.

Subagents are invoked via Claude Code's built-in **Task tool** — not by running `claude -p` in bash.

```
1. 사용자: "/squad-review src/auth/"
   User: "/squad-review src/auth/"

2. Claude Code (메인 세션):
   → Task(subagent_type="squad-review", prompt="Review src/auth/...")
   Main session delegates via Task tool

3. 새 컨텍스트 윈도우 생성:
   New context window created:
   - squad-review.md의 시스템 프롬프트 로드
     System prompt from squad-review.md loaded
   - tools: Read, Grep, Glob, Bash만 사용 가능
     Only tools listed in frontmatter available
   - model: opus 사용
     Uses model specified in frontmatter

4. 서브에이전트 작업 수행 (독립 컨텍스트):
   Subagent works in its own context:
   - git diff 실행 → 출력이 서브에이전트 컨텍스트에만 존재
     git diff output stays in subagent context only
   - 파일 읽기, 분석...
     File reads, analysis...
   - 최종 메시지 작성
     Composes final message

5. 결과 반환:
   Result returned:
   - 서브에이전트의 최종 메시지만 메인 세션에 전달
     Only the final message returns to main session
   - 서브에이전트 컨텍스트는 폐기
     Subagent context is discarded
```

### Agent Definition Format / 에이전트 정의 형식

서브에이전트는 **YAML frontmatter + Markdown 시스템 프롬프트** 형식의 `.md` 파일로 정의됩니다.

Subagents are defined as `.md` files with **YAML frontmatter + Markdown system prompt**.

```markdown
---
name: squad-review                    # 에이전트 식별자 / Agent identifier
description: >                        # 자동 위임 트리거 조건 / Auto-delegation trigger
  Use PROACTIVELY after code changes.
  Trigger when user says "review".
tools: Read, Grep, Glob, Bash         # 허용 도구 / Allowed tools
model: opus                           # 사용 모델 / Model to use
maxTurns: 15                          # 최대 턴 수 / Max turns before stopping
---

You are a senior staff engineer...    # 시스템 프롬프트 (본문 전체)
                                      # System prompt (entire body)
## Review Process
1. Run git diff...
...
```

`description` 필드가 핵심입니다 — Claude는 이 설명을 읽고 자동 위임 여부를 결정합니다. `PROACTIVELY` 키워드가 있으면 사용자가 명시적으로 요청하지 않아도 description 매칭만으로 자동 호출됩니다.

The `description` field is critical — Claude reads it to decide whether to auto-delegate. The `PROACTIVELY` keyword enables automatic invocation without explicit user request.

### Storage Locations & Priority / 저장 위치와 우선순위

```
CLI --agents flag  >  .claude/agents/ (project)  >  ~/.claude/agents/ (user)  >  plugin
     (highest)              (team-shared)               (personal)              (lowest)
```

동일한 이름의 에이전트가 여러 곳에 있으면 높은 우선순위가 적용됩니다. Squad Agent는 `~/.claude/agents/`(개인)에 설치되므로, 프로젝트에 같은 이름의 파일을 두면 프로젝트 버전이 우선합니다.

When agents with the same name exist in multiple locations, the higher-priority one wins. Squad Agent installs to `~/.claude/agents/` (user), so placing a same-named file in `.claude/agents/` (project) overrides it.

### Subagent vs Agent Teams / 서브에이전트 vs Agent Teams

| | Subagent / 서브에이전트 | Agent Teams |
|---|---|---|
| **Scope / 범위** | Within a single session / 단일 세션 내 | Across separate sessions / 별도 세션 간 |
| **Context / 컨텍스트** | Own window, returns summary / 독립 윈도우, 요약 반환 | Fully independent (worktree) / 완전 독립 |
| **Communication / 통신** | Via Task tool / Task 도구 | Via filesystem & Git / 파일/Git |
| **Best for / 적합** | Review, analysis, short tasks / 리뷰, 분석, 단발 작업 | Long-running parallel dev / 장기 병렬 개발 |
| **Nesting / 중첩** | Cannot spawn sub-subagents / 서브의 서브 불가 | Independent sessions / 독립 세션 |

### Frontmatter Reference / Frontmatter 레퍼런스

| Field / 필드 | Required / 필수 | Default / 기본값 | Description / 설명 |
|------|------|--------|------|
| `name` | ✅ | — | Agent identifier / 에이전트 식별자 |
| `description` | ✅ | — | Auto-delegation trigger / 자동 위임 조건. `PROACTIVELY` 포함 시 자동 호출 |
| `tools` | ❌ | (inherit) | Comma-separated / 콤마 구분. `Task(agent-name)` 지원 |
| `disallowedTools` | ❌ | — | Tools to block / 차단 도구 |
| `model` | ❌ | `inherit` | `haiku` / `sonnet` / `opus` / `inherit` / full model ID |
| `maxTurns` | ❌ | — | Max agentic turns / 최대 턴 수 |
| `permissionMode` | ❌ | — | `plan` / `acceptEdits` / `bypassPermissions` |
| `memory` | ❌ | — | `user` / `project` / `local` — persistent MEMORY.md across sessions |
| `background` | ❌ | `false` | Run as background task / 백그라운드 실행 |
| `skills` | ❌ | — | Skills to preload / 프리로드 스킬 |
| `mcpServers` | ❌ | — | Agent-scoped MCP servers / 에이전트 전용 MCP |
| `hooks` | ❌ | — | Agent-scoped lifecycle hooks / 에이전트 전용 훅 |
| `isolation` | ❌ | — | `worktree` for Git worktree isolation |

### Model Resolution Order / 모델 결정 우선순위

```
1. CLAUDE_CODE_SUBAGENT_MODEL env var    (highest / 최우선)
2. model parameter passed by Task tool
3. model field in frontmatter
4. inherit (same as main session)        (lowest / 최하위)
```

---

## 서브 에이전트 실제 구성 예제 

- [Claude Code Master 도서 구매자들을 위한 실전 서브에이전트 사용방법 살펴보기](https://github.com/claude-code-expert/subagents)

https://github.com/claude-code-expert/subagents 에서 관련 코드와 문서를 확인할 수 있습니다. 


--- 

## References

- [Claude Code Sub-agents (Official)](https://code.claude.com/docs/en/sub-agents)
- [Claude Agent SDK](https://platform.claude.com/docs/en/agent-sdk/subagents)
- [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice)
- [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)
