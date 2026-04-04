# Claude Code Cheat Sheet

> 📘 [github.com/claude-code-expert](https://github.com/claude-code-expert) — 클로드 코드 마스터 (한빛미디어 서적 공식 리포지토리) | 🍺 [www.brewnet.dev](https://www.brewnet.dev) — 셀프 호스팅 홈서버 자동 구축 오픈소스

> v2.1.91 · April 2026 · 공식 Changelog 대조 검증 완료 · 한국어 설명 포함

## 검증 범례

| 배지 | 의미 |
|------|------|
| ✅ 확인됨 | 공식 changelog 일치 항목 |
| ⚠️ 미확인 | v2.1.91 NEW 항목 (공홈 미반영) |
| ❌ 주의 | 오류 가능성 항목 |

---

## 1. Keyboard Shortcuts

### General Controls

| 단축키 | 기능 (EN) | 기능 (KO) |
|--------|-----------|-----------|
| `Ctrl+C` | Cancel input/generation | 입력 또는 생성 취소 |
| `Ctrl+D` | Exit session | 세션 종료 |
| `Ctrl+L` | Clear screen | 화면 지우기 |
| `Ctrl+O` | Toggle verbose/transcript | 상세 모드 / 대화 기록 토글 |
| `Ctrl+R` | Reverse search history | 히스토리 역방향 검색 |
| `Ctrl+G` | Open prompt in editor | 외부 에디터로 프롬프트 열기 |
| `Ctrl+B` | Background running task | 현재 작업을 백그라운드로 전환 |
| `Ctrl+T` | Toggle task list | 작업 목록 토글 |
| `Ctrl+V` | Paste image ([Image #N] chip) | 이미지 붙여넣기 (위치 칩 삽입) |
| `Ctrl+X` `Ctrl+K` | Kill background agents | 백그라운드 에이전트 전체 종료 (v2.1.83 Ctrl+F에서 변경) |
| `Esc` `Esc` | Rewind or summarize | 대화 되감기 또는 요약 |

### Mode Switching

| 단축키 | 기능 (EN) | 기능 (KO) |
|--------|-----------|-----------|
| `Shift+Tab` | Cycle permission modes | 권한 모드 순환 (Normal → Auto → Plan) |
| `Alt+P` | Switch model | 모델 전환 |
| `Alt+T` | Toggle thinking | 사고(thinking) 모드 토글 |
| `Alt+O` | Toggle fast mode **NEW** | 빠른 모드 토글 ⚠️ v2.1.91 미확인 |

### Input / Prefixes

| 키 | 기능 (EN) | 기능 (KO) |
|----|-----------|-----------|
| `\` + `Enter` | Newline | 줄바꿈 입력 |
| `/` | Slash command | 슬래시 명령어 입력 |
| `!` | Direct bash | 직접 bash 명령 실행 |
| `@` | File mention + autocomplete | 파일 멘션 및 자동완성 |

---

## 2. MCP Servers

### Transport

| 옵션 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `--transport http` | Remote HTTP (recommended) | 원격 HTTP 방식 (권장) |
| `--transport stdio` | Local process | 로컬 프로세스 방식 |
| `--transport sse` | Remote SSE | 원격 SSE 방식 |

### Scopes

| 범위 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| Local | `~/.claude.json` (you only) | 개인 전용 설정 |
| Project | `.mcp.json` (shared/VCS) | 프로젝트 공유 (버전 관리 포함) |

### Manage

| 명령/항목 | 기능 (EN) | 기능 (KO) |
|-----------|-----------|-----------|
| `/mcp` | Interactive UI | MCP 서버 대화형 관리 UI |
| `claude mcp list` | List all servers | 등록된 MCP 서버 목록 출력 |
| `claude mcp serve` | CC as MCP server | Claude Code 자체를 MCP 서버로 실행 |
| 2KB cap | Tool desc + server instructions limit | 툴 설명·서버 지시문 최대 2KB 제한 (v2.1.84) |
| `maxResultSizeChars` | `_meta` annotation override (up to 500K) **NEW** | 결과 크기 상한 재정의 최대 500K ⚠️ v2.1.91 미확인 |

---

## 3. Slash Commands

### Session

| 명령 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `/clear` | Clear conversation | 대화 내용 초기화 |
| `/compact [focus]` | Compact context | 컨텍스트 압축 (포커스 키워드 지정 가능) |
| `/resume` | Resume/switch session | 이전 세션 재개 또는 전환 |
| `/rename [name]` | Name current session | 현재 세션 이름 지정 |
| `/branch [name]` | Branch conversation | 대화 분기 생성 ⚠️ /fork alias 여부 미검증 |
| `/cost` | Token usage stats | 토큰 사용량 통계 |
| `/context` | Visualize context (grid) | 컨텍스트 사용량 시각화 |
| `/diff` | Interactive diff viewer | 대화형 변경사항 비교기 |
| `/rewind` | Rewind conv / code checkpoint | 대화 되감기 / 코드 체크포인트 복원 |

### Config

| 명령 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `/config` | Open settings | 설정 열기 |
| `/model [model]` | Switch model | 모델 전환 (←→ 으로 effort 조정) |
| `/effort [level]` | low / medium / high / max / auto | 추론 강도 설정 |
| `/vim` | Toggle vim mode | vim 키바인딩 모드 토글 |
| `/theme` | Change color theme | 컬러 테마 변경 |
| `/permissions` | View/update permissions | 권한 확인·수정 (Recent 탭에서 r로 retry) |

### Tools

| 명령 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `/init` | Create CLAUDE.md | 프로젝트 CLAUDE.md 자동 생성 |
| `/memory` | Edit CLAUDE.md files | CLAUDE.md 메모리 파일 편집 |
| `/mcp` | Manage MCP servers | MCP 서버 관리 |
| `/hooks` | Manage hooks | 훅(Hook) 관리 |
| `/skills` | List available skills | 사용 가능한 스킬 목록 출력 |
| `/agents` | Manage agents | 에이전트 관리 |

### Special

| 명령 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `/powerup` | Interactive feature lessons **NEW** | 기능 인터랙티브 튜토리얼 ✅ v2.1.90 확인 |
| `/btw <q>` | Side question (no context cost) | 컨텍스트 소비 없는 간단 질문 |
| `/plan [desc]` | Plan mode | 읽기 전용 계획 수립 모드 |
| `/voice` | Push-to-talk voice (20 langs) | 푸시투토크 음성 입력 (20개 언어 지원) |
| `/security-review` | Security analysis of changes | 변경사항 보안 분석 |
| `/pr-comments` | Fetch GitHub PR comments | GitHub PR 코멘트 불러오기 |

---

## 4. Memory & Files

### CLAUDE.md 위치

| 경로 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `./CLAUDE.md` | Project (team-shared) | 프로젝트 공유 (팀 전체 적용) |
| `~/.claude/CLAUDE.md` | Personal (all projects) | 개인 전역 (모든 프로젝트 적용) |
| `/etc/claude-code/` | Managed (org-wide) | 조직 관리형 (전사 적용) |

### Rules & Import

| 항목 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `.claude/rules/*.md` | Project rules | 프로젝트 규칙 파일 |
| `~/.claude/rules/*.md` | User rules | 사용자 전역 규칙 파일 |
| `paths:` frontmatter | Path-specific rules | 특정 경로에만 적용되는 규칙 |
| `@path/to/file` | Import in CLAUDE.md | CLAUDE.md 내 다른 파일 임포트 |

### Auto Memory

| 항목 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `~/.claude/projects/<proj>/memory/` | MEMORY.md + topic files, auto-loaded | 자동 로드되는 기억 파일 ⚠️ 25KB/200줄 상한은 미검증 |

---

## 5. Workflows & Tips

### Plan Mode

| 항목 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `Shift+Tab` | Normal → Auto → Plan cycle | 권한 모드 순환 전환 |
| `--permission-mode plan` | Start in plan mode | 플랜 모드로 시작 (읽기 전용) |

### Thinking & Effort

| 항목 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `"ultrathink"` | Max effort for this turn | 해당 턴 최대 추론 강도 적용 |
| `Alt+T` | Toggle thinking on/off | 사고 모드 켜기/끄기 |
| `showThinkingSummaries` | Opt-in (off by default now) ✅ v2.1.89 | 사고 요약 표시 (기본값 OFF로 변경됨) |

### Auto Mode Denied (✅ v2.1.89)

| 항목 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `/permissions` → Recent | Retry denied with R key | 거부된 명령을 Recent 탭에서 R 키로 재시도 |

### Git Worktrees

| 항목 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `--worktree name` | Isolated branch per feature | 기능별 독립 브랜치 워크트리 생성 |
| `isolation: worktree` | Agent in own worktree | 에이전트를 전용 워크트리에서 실행 |
| `sparsePaths` | Checkout only needed dirs | 필요한 디렉토리만 체크아웃 |
| `/batch` | Auto-creates worktrees (5-30) | 병렬 대규모 변경 (워크트리 자동 생성) |

### Context Management

| 항목 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `/compact [focus]` | Compress with focus keyword | 포커스 키워드를 유지하며 컨텍스트 압축 |
| Auto-compact | ~95% capacity, thrash detection ✅ v2.1.89 | 95% 도달 시 자동 압축, 3회 반복 시 중단 |
| CLAUDE.md | Survives compaction! | 압축 후에도 항상 유지됨 (필수 지시문 보존) |
| 1M context | Opus 4.6 (Max/Team/Ent) | Opus 4.6 기준 1M 토큰 (플랜 조건 별도 확인) |

### Session Power Moves

| 항목 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `claude -c` | Continue last conversation | 마지막 대화 이어가기 |
| `claude -r "name"` | Resume by name | 이름으로 세션 재개 |

### SDK / Headless

| 항목 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `claude -p "query"` | Non-interactive (headless) | 비대화형 헤드리스 실행 |
| `--output-format json` | Structured output | JSON 구조화 출력 |
| `--max-budget-usd 5` | Cost cap | 비용 상한 설정 (달러 기준) |
| `cat file \| claude -p` | Pipe input | 파이프로 입력 전달 |

---

## 6. Config & Env

### Config Files

| 파일 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `~/.claude/settings.json` | User settings | 사용자 전역 설정 |
| `.claude/settings.json` | Project (shared) | 프로젝트 공유 설정 |
| `.claude/settings.local.json` | Local only | 로컬 전용 (VCS 제외) |
| `managed-settings.d/` | Drop-in policy fragments ✅ v2.1.83 | 팀별 정책 조각 파일 디렉토리 |
| `.mcp.json` | Project MCP servers | 프로젝트 MCP 서버 설정 |

### Key Settings

| 설정 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `showThinkingSummaries` | Opt-in (off by default) ✅ v2.1.89 | 사고 요약 표시 여부 (기본 비활성화) |
| `sandbox.failIfUnavailable` | Exit if sandbox fails ✅ v2.1.83 | 샌드박스 불가 시 에러로 종료 |
| `hooks: if` | Conditional hooks ✅ v2.1.85 | 조건부 훅 실행 (permission rule 문법) |
| `hooks: "defer"` | Pause headless, resume later ✅ v2.1.89 | 헤드리스 세션 일시중단 후 나중에 재개 |
| `PermissionDenied` hook | Fires on auto mode denial ✅ v2.1.89 | 자동 모드 거부 시 훅 실행 |
| `disableSkillShellExec` | Block `!cmd` in skills **NEW** | 스킬/플러그인 내 쉘 실행 차단 ⚠️ v2.1.91 미확인 |
| `allowedChannelPlugins` | Admin channel plugin allowlist ✅ v2.1.84 | 관리자 채널 플러그인 허용 목록 |

### Key Env Vars

| 환경변수 | 기능 (EN) | 기능 (KO) |
|----------|-----------|-----------|
| `ANTHROPIC_API_KEY` | API key | Anthropic API 인증 키 |
| `ANTHROPIC_MODEL` | Default model override | 기본 모델 재정의 |
| `CLAUDE_CODE_EFFORT_LEVEL` | low/medium/high/max/auto | 기본 추론 강도 설정 |
| `MAX_THINKING_TOKENS` | 0 = off | 최대 사고 토큰 수 (0=비활성화) |
| `CLAUDE_CODE_NO_FLICKER` | Alt-screen rendering ✅ v2.1.89 | 깜빡임 없는 대체 화면 렌더링 (=1) |
| `MCP_CONNECTION_NONBLOCKING` | Skip MCP wait in -p ✅ v2.1.89 | 헤드리스 모드에서 MCP 연결 대기 스킵 |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | Strip creds from subprocesses ✅ v2.1.83 | 서브프로세스에서 자격증명 제거 |
| `CLAUDE_STREAM_IDLE_TIMEOUT_MS` | Streaming watchdog (default 90s) ✅ v2.1.84 | 스트리밍 감시 타임아웃 (기본 90초) |

---

## 7. Skills & Agents

### Built-in Skills

| 명령 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `/simplify` | Code review (parallel agents) | 코드 리뷰 (병렬 에이전트 사용) ⚠️ 3개 수치 미검증 |
| `/batch` | Large parallel changes (5-30 worktrees) | 대규모 병렬 변경 (워크트리 자동 분배) |
| `/debug [desc]` | Troubleshoot from debug log | 디버그 로그 기반 문제 해결 |
| `/loop [interval]` | Recurring scheduled task | 반복 예약 작업 실행 |
| `/claude-api` | Load API + SDK reference | API/SDK 레퍼런스 컨텍스트 로드 |

### Custom Skill Locations

| 경로 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `.claude/skills/<name>/` | Project skills | 프로젝트 전용 커스텀 스킬 |
| `~/.claude/skills/<name>/` | Personal skills | 개인 전역 커스텀 스킬 |

### Skill Frontmatter

| 속성 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `description` | Auto-invocation trigger | 자동 호출 트리거 설명 |
| `allowed-tools` | Skip permission prompts | 사전 허용 툴 (권한 프롬프트 스킵) |
| `model` / `effort` | Override model/effort for skill | 스킬 단위 모델·강도 재정의 |
| `paths: [globs]` | Path-specific ✅ v2.1.84 | 특정 경로 glob에만 적용 |
| `context: fork` | Run in subagent | 서브에이전트에서 독립 실행 |
| `$ARGUMENTS` | User input placeholder | 사용자 입력값 치환 변수 |
| `${CLAUDE_SKILL_DIR}` | Skill's own directory path | 스킬 자신의 디렉토리 경로 |
| `` !`cmd` `` | Dynamic context injection | 동적 컨텍스트 주입 (쉘 명령 실행) |
| `plugin bin/` | Ship executables for Bash tool **NEW** | Bash 툴용 실행파일 제공 ⚠️ v2.1.91 미확인 |

### Built-in Agents

| 에이전트 | 기능 (EN) | 기능 (KO) |
|----------|-----------|-----------|
| Explore | Fast read-only (Haiku) | 빠른 읽기 전용 탐색 (Haiku 모델) |
| Plan | Research for plan mode | 계획 수립용 리서치 에이전트 |
| General | Full tools, complex tasks | 전체 툴 사용, 복잡한 작업용 |
| Bash | Terminal separate context | 별도 컨텍스트의 터미널 에이전트 |

### Agent Frontmatter

| 속성 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `permissionMode` | default/acceptEdits/plan/dontAsk/bypassPermissions | 에이전트 권한 모드 설정 |
| `isolation: worktree` | Run in git worktree | 전용 git 워크트리에서 실행 |
| `background: true` | Background task | 백그라운드 작업으로 실행 |
| `initialPrompt` | Auto-submit first turn ✅ v2.1.83 | 첫 턴 자동 제출 프롬프트 |
| `@agent-name` | Mention named subagents ✅ v2.1.89 | 명명된 서브에이전트 멘션 |

---

## 8. CLI & Flags

### Core Commands

| 명령 | 기능 (EN) | 기능 (KO) |
|------|-----------|-----------|
| `claude` | Interactive mode | 대화형 모드 실행 |
| `claude "query"` | Start with prompt | 프롬프트와 함께 시작 |
| `claude -p "query"` | Headless (non-interactive) | 헤드리스 단일 실행 |
| `claude -c` | Continue last conversation | 마지막 대화 이어가기 |
| `claude -r "name"` | Resume by session name | 이름으로 세션 재개 |
| `claude update` | Update Claude Code | Claude Code 업데이트 |

### Key Flags

| 플래그 | 기능 (EN) | 기능 (KO) |
|--------|-----------|-----------|
| `--model` | Set model | 사용할 모델 지정 |
| `-w` / `--worktree` | Git worktree | 워크트리 지정 |
| `--add-dir` | Add working directory | 작업 디렉토리 추가 |
| `--agent` | Use specific agent | 특정 에이전트 사용 |
| `--allowedTools` | Pre-approve tools | 도구 사전 승인 |
| `--output-format` | json / stream-json | 출력 형식 지정 |
| `--max-turns` | Limit agentic turns | 에이전트 최대 턴 수 제한 |
| `--max-budget-usd` | Cost cap in USD | 비용 상한 (달러 기준) |
| `--verbose` | Verbose output | 상세 출력 모드 |
| `--bare` | Minimal headless (no hooks/LSP) | 경량 헤드리스 (훅·LSP 없음) |
| `--effort` | low/medium/high/max | 추론 강도 플래그 |
| `--permission-mode` | plan/default/acceptEdits... | 권한 모드 플래그 |
| `--dangerously-skip-permissions` | Skip all prompts | 모든 권한 프롬프트 스킵 (CI용, 주의) |
| `--remote` | Web session on claude.ai | claude.ai 웹 세션 연동 |
| PowerShell tool | Windows opt-in preview ✅ v2.1.84 | Windows PowerShell 툴 (선택적 프리뷰) |

---

## 9. Permission Modes

### default — 기본 모드

- 파일 읽기만 자동 허용, 나머지는 프롬프트 확인

```bash
claude --permission-mode default
# settings.json:
"permissions": { "defaultMode": "default" }
```

### acceptEdits — 편집 자동 수락

- 파일 읽기+편집 자동 허용, 코드 리뷰 중 반복 작업에 적합

```bash
claude --permission-mode acceptEdits
# 헤드리스에서도 동일:
claude -p "refactor auth" --permission-mode acceptEdits
```

### plan — 읽기 전용 계획 모드

- 코드 수정 없이 탐색·계획만 수행, `/plan` 접두사로도 전환

```bash
claude --permission-mode plan
# Shift+Tab으로 순환:
default → acceptEdits → plan
```

### auto — 자동 모드 [Team/Enterprise/API 전용]

- 백그라운드 classifier가 각 액션 안전 검사, Sonnet 4.6 / Opus 4.6 필요

```bash
claude --enable-auto-mode
# Shift+Tab에 auto가 나타남
# ⚠ --enable-auto-mode 없으면 사이클 미포함
```

### dontAsk — 사전 승인 툴만 허용

- `allowedTools`에 명시된 것만 실행 가능, Shift+Tab 사이클에 없음

```bash
claude --permission-mode dontAsk \
  --allowedTools "Bash(npm test)" "Read"
# settings.json으로도 설정 가능
```

### bypassPermissions — 전체 스킵

- 격리된 컨테이너·VM 전용, 세션 시작 시 지정해야 사이클에 추가됨

```bash
# CI/CD 파이프라인 전용 사용 예시:
claude --dangerously-skip-permissions \
  -p "run full test suite"
```

---

## 10. ENV Variables — 설정 위치 및 사용 예시

### 1) 쉘에서 임시 설정 (세션 단위)

```bash
# API 키 설정 (구독 대신 API 과금)
export ANTHROPIC_API_KEY=sk-ant-xxxxx

# 기본 모델 재정의
export ANTHROPIC_MODEL=claude-opus-4-6-20250514

# 추론 강도 설정 (low/medium/high/max)
export CLAUDE_CODE_EFFORT_LEVEL=high

# 깜빡임 없는 렌더링 활성화 (v2.1.89)
export CLAUDE_CODE_NO_FLICKER=1

# 스트리밍 타임아웃 재정의 (기본 90000ms)
export CLAUDE_STREAM_IDLE_TIMEOUT_MS=120000

claude  # 위 ENV 적용 상태로 실행
```

### 2) settings.json의 env 블록 (팀 공유 가능)

```jsonc
// .claude/settings.json (프로젝트 공유)
{
  "env": {
    "CLAUDE_CODE_EFFORT_LEVEL": "high",
    "MAX_THINKING_TOKENS": "8000",
    "CLAUDE_STREAM_IDLE_TIMEOUT_MS": "120000",
    "CLAUDE_CODE_SUBPROCESS_ENV_SCRUB": "1"
  },
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

### 3) 헤드리스 / CI 파이프라인 패턴

```bash
# CI에서 API 키 + 헤드리스 조합
ANTHROPIC_API_KEY=$SECRET \
CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1 \
claude -p "run tests and summarize" \
  --permission-mode acceptEdits \
  --output-format json \
  --max-budget-usd 2

# MCP 연결 대기 스킵 (-p 모드, v2.1.89)
MCP_CONNECTION_NONBLOCKING=true \
claude -p "query" --bare
```

### 4) 검증된 ENV 전체 목록 (공식 env-vars 문서 기준)

| 환경변수 | 설명 |
|----------|------|
| `ANTHROPIC_API_KEY` | API 인증 키 |
| `ANTHROPIC_MODEL` | 기본 모델 재정의 |
| `ANTHROPIC_BASE_URL` | API 엔드포인트 오버라이드 |
| `CLAUDE_CODE_EFFORT_LEVEL` | 추론 강도 (low~max) |
| `MAX_THINKING_TOKENS` | 사고 토큰 상한 (0=끄기) |
| `CLAUDE_CODE_NO_FLICKER` | 대체화면 렌더링 (=1) v2.1.89 |
| `MCP_CONNECTION_NONBLOCKING` | MCP 연결 대기 스킵 v2.1.89 |
| `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | 서브프로세스 자격증명 제거 |
| `CLAUDE_STREAM_IDLE_TIMEOUT_MS` | 스트리밍 타임아웃 (기본 90s) |
| `BASH_DEFAULT_TIMEOUT_MS` | bash 명령 기본 타임아웃 |
| `CLAUDECODE` | CC 내부 쉘 감지용 (=1 자동설정) |
| `CLAUDE_CODE_EFFORT_LEVEL` | ⚠ 치트시트에 있으나 공식 docs에는 없음 |

---

## 검증 출처

- 원문: [cc.storyfox.cz](https://cc.storyfox.cz/) (개인 제작, by Martin Baláž @phasE89)
- [GitHub CHANGELOG.md](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
- [공식 Docs Changelog](https://code.claude.com/docs/en/changelog)
- [Permission Modes 공식 문서](https://code.claude.com/docs/en/permission-modes)
- [ENV Vars 공식 문서](https://code.claude.com/docs/en/env-vars)

> ✅ 확인됨 | ⚠️ 미확인 = v2.1.91 미반영 | ❌ 주의 = 오류 가능
