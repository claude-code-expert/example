# [Claude Code Expert](https://github.com/claude-code-expert) 서적의 예제 문서 모음

> 📘 [github.com/claude-code-expert](https://github.com/claude-code-expert) — 클로드 코드 마스터 (한빛미디어 서적 공식 리포지토리) <br>  
> ☕ [www.brewnet.dev](https://www.brewnet.dev) — 셀프 호스팅 홈서버 자동 구축 오픈소스

# Template 디렉토리 가이드

> 이 디렉토리는 AI 코딩 에이전트(Claude Code, Cursor, Codex 등)에게 프로젝트 맥락을 전달하는 지침 파일 템플릿 모음이다.
> 각 파일은 독립적으로 사용할 수도 있고, `@` 참조로 연결하여 계층 구조를 구성할 수도 있다.

---

## 목차

1. [파일 목록 및 역할](#1-파일-목록-및-역할)
2. [파일 연관 관계도](#2-파일-연관-관계도)
3. [사용 시나리오별 조합](#3-사용-시나리오별-조합)
4. [멀티턴 방어 설계 가이드](#4-멀티턴-방어-설계-가이드)

---

## 1. 파일 목록 및 역할

### CLAUDE.md 계열 — 프로젝트 지침 (Claude Code용)

| 파일 | 역할 | 대상 프로젝트 |
|------|------|-------------|
| `CLAUDE.md` | 싱글 프로젝트용 기본 템플릿. 프로젝트 개요, 명령어, 조사 규칙, 가드레일 포함 | Next.js 단일 앱 |
| `CLAUDE-template(Root).md` | 모노레포 루트용. 공통 규칙을 정의하고 하위 패키지가 상속 | pnpm 모노레포 |
| `CLAUDE-template(Client).md` | 모노레포 클라이언트 패키지용. Next.js/React 특화 규칙 | `packages/client` |
| `CLAUDE-template(Server).md` | 모노레포 서버 패키지용. Express/Prisma 특화 규칙 | `packages/server` |
| `CLAUDE.local.md` | 개인 환경 설정 (`.gitignore`에 추가). OS, Node 버전, 개인 선호 | 모든 프로젝트 |

### AGENTS.md 계열 — 프로젝트 지침 (범용)

| 파일 | 역할 | 대상 |
|------|------|------|
| `AGENTS-Guide.md` | AGENTS.md 작성 방법 가이드. 필수 섹션, 핵심 원칙, 도구별 파일명 안내 | 가이드 문서 |
| `AGENTS-template.md` | AGENTS.md 빈 템플릿. 섹션 구조만 제공 | 모든 프로젝트 |
| `AGENTS(java-back).md` | Java/Spring Boot 백엔드 실전 예시. Layered Architecture 규칙 포함 | Spring Boot 프로젝트 |

### Rules 파일 — `@` 참조로 CLAUDE.md에서 불러오는 세부 규칙

| 파일 | 참조하는 상위 파일 | 내용 |
|------|-----------------|------|
| `code-style.md` | `CLAUDE.md` | TypeScript, React, 파일 네이밍, import 순서, 에러 핸들링 |
| `root-code-style.md` | `CLAUDE-template(Root).md` | 모노레포 전역 코드 스타일 (네이밍, TS strict, API 응답 형식) |
| `testing.md` | `CLAUDE.md` | Vitest/Playwright/RTL 스택, 테스트 작성 패턴, 커버리지 목표 |
| `git-workflow.md` | `CLAUDE.md` | 브랜치 네이밍, Conventional Commits, PR 규칙, 머지 전략 |
| `client-patterns.md` | `CLAUDE-template(Client).md` | forwardRef, TanStack Query, API 클라이언트, 컴포넌트 테스트 패턴 |
| `server-patterns.md` | `CLAUDE-template(Server).md` | Route→Controller→Service→Repository 코드 패턴, 에러 핸들링 |
| `patterns.md` | `AGENTS(java-back).md` | Java Controller/Service/Repository/Test 코드 패턴 |

### 기타

| 파일 | 역할 |
|------|------|
| `skill-template.md` | Claude Code 커스텀 Skill 작성 템플릿 (frontmatter + Instructions) |

---

## 2. 파일 연관 관계도

### `@` 참조 관계

`CLAUDE.md`와 `AGENTS.md`는 `@파일경로` 문법으로 다른 파일을 참조할 수 있다. 참조된 파일은 Claude Code가 자동으로 컨텍스트에 포함시킨다.

```
싱글 프로젝트
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CLAUDE.md
 ├── @.claude/rules/code-style.md
 ├── @.claude/rules/testing.md
 └── @.claude/rules/git-workflow.md


모노레포 (pnpm workspace)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CLAUDE-template(Root).md          ← 루트 (packages/ 상위)
 └── @.claude/rules/root-code-style.md

CLAUDE-template(Client).md       ← packages/client/CLAUDE.md
 └── @.claude/rules/client-patterns.md

CLAUDE-template(Server).md       ← packages/server/CLAUDE.md
 └── @.claude/rules/server-patterns.md


Java 백엔드
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

AGENTS(java-back).md
 └── @docs/patterns.md
```

### 상속 구조

모노레포에서는 루트 `CLAUDE.md`가 전체에 적용되고, 각 패키지의 `CLAUDE.md`가 해당 디렉토리에서 추가 규칙을 적용한다:

```
프로젝트 루트/
├── CLAUDE.md                         ← CLAUDE-template(Root).md 기반
│   (공통: 언어 규칙, 조사 원칙, Git 가드레일)
│
├── packages/client/CLAUDE.md         ← CLAUDE-template(Client).md 기반
│   (추가: Server/Client 컴포넌트 규칙, 스타일링, 테스트)
│
├── packages/server/CLAUDE.md         ← CLAUDE-template(Server).md 기반
│   (추가: Request flow, Prisma 가드레일, 에러 핸들링)
│
└── CLAUDE.local.md                   ← 개인 설정 (.gitignore에 포함)
    (OS, Node 버전, 개인 선호)
```

**규칙 병합 순서** (낮은 → 높은 우선순위):

```
루트 CLAUDE.md → 패키지 CLAUDE.md → CLAUDE.local.md
```

동일 규칙이 충돌하면 하위(패키지) 설정이 우선한다.

### CLAUDE.md vs AGENTS.md

| | CLAUDE.md | AGENTS.md |
|--|-----------|-----------|
| **대상 도구** | Claude Code 전용 | 범용 (Claude Code, Cursor, Codex 등) |
| **자동 로드** | Claude Code가 자동 인식 | 에이전트에게 먼저 읽으라고 지시 필요 |
| **`@` 참조** | 지원 (자동 컨텍스트 포함) | 도구에 따라 다름 |
| **호환 방법** | `ln -s AGENTS.md CLAUDE.md` | - |

둘의 내부 구조(섹션 구성)는 동일하다. 도구에 맞는 파일명을 선택하면 된다.

---

## 3. 사용 시나리오별 조합

### 시나리오 A: Next.js 단일 프로젝트

```
복사할 파일:
  CLAUDE.md              → 프로젝트 루트/CLAUDE.md
  code-style.md          → .claude/rules/code-style.md
  testing.md             → .claude/rules/testing.md
  git-workflow.md        → .claude/rules/git-workflow.md
  CLAUDE.local.md        → 프로젝트 루트/CLAUDE.local.md (.gitignore 추가)
```

### 시나리오 B: pnpm 모노레포 (React + Express)

```
복사할 파일:
  CLAUDE-template(Root).md     → 프로젝트 루트/CLAUDE.md
  CLAUDE-template(Client).md   → packages/client/CLAUDE.md
  CLAUDE-template(Server).md   → packages/server/CLAUDE.md
  root-code-style.md           → .claude/rules/root-code-style.md
  client-patterns.md           → .claude/rules/client-patterns.md
  server-patterns.md           → .claude/rules/server-patterns.md
  git-workflow.md              → .claude/rules/git-workflow.md
  CLAUDE.local.md              → 프로젝트 루트/CLAUDE.local.md
```

### 시나리오 C: Spring Boot 백엔드 (Java)

```
복사할 파일:
  AGENTS(java-back).md   → 프로젝트 루트/AGENTS.md (또는 CLAUDE.md)
  patterns.md            → docs/patterns.md
  git-workflow.md        → .claude/rules/git-workflow.md
```

### 시나리오 D: 새 프로젝트 (프레임워크 미정)

```
복사할 파일:
  AGENTS-template.md     → 프로젝트 루트/AGENTS.md (빈 템플릿에서 시작)
  AGENTS-Guide.md        → 작성 가이드로 참고 (프로젝트에 포함하지 않음)
```

### 시나리오 E: Claude Code Skill 제작

```
참고 파일:
  skill-template.md      → ~/.claude/skills/ 또는 프로젝트 .claude/skills/에 작성
```

---

## 4. 멀티턴 방어 설계 가이드

> LLM은 멀티턴 대화에서 평균 39% 성능이 하락한다. 초기 턴에서 잘못된 가정을 하면 이후 복구하지 못한다.
> 이 섹션은 CLAUDE.md, Hooks, 작업 구조화를 통해 이 문제를 방어하는 실전 패턴을 정리한다.

---

### 4.1 문제 정의

#### 연구 배경

LLM의 멀티턴 대화에서 성능이 저하되는 원인은 두 가지로 분해된다:

| 요인 | 영향도 | 설명 |
|------|--------|------|
| **Aptitude Loss** | 경미 | 턴이 늘어날수록 모델 능력 자체가 소폭 하락 |
| **Unreliability** | 심각 | 초기 턴에서 잘못된 가정 → 끝까지 고수 → 복구 불가 |

#### 실제 코딩 작업에서의 증상

```
사용자: "로그인이 안 돼"
Claude: (가정) 아마 토큰 만료 문제일 것이다 → 토큰 갱신 로직 구현
사용자: "아니, 비밀번호 해싱이 문제야"
Claude: 토큰 갱신 코드 위에 해싱 로직을 덧붙임 → 꼬인 코드
사용자: "처음부터 다시 해줘"
```

**핵심**: 첫 턴에서 "토큰 만료"라고 가정한 순간, 이후 대화 전체가 오염된다.

#### 왜 Claude Code에서 특히 문제인가

| 상황 | 위험도 | 이유 |
|------|--------|------|
| 장시간 코딩 세션 | 높음 | 20+ 턴이 쉽게 쌓임, 초기 가정이 모든 코드에 영향 |
| `/compact` 후 | 높음 | 컨텍스트 압축 시 초기 지시사항과 판단 근거가 유실됨 |
| 서브에이전트 위임 | 중간 | 서브에이전트는 대화 맥락 없이 단편적 지시만 받음 |
| 디버깅 루프 | 높음 | 첫 가설이 틀리면 같은 방향으로 계속 시도 |

---

### 4.2 방어 계층 구조

```
┌─────────────────────────────────────────────────────────┐
│ Layer 4: 사용자 습관 (가장 효과적)                            │  
│  → 구체적 프롬프트, 단일턴 완결, 중간 확인                       │
├─────────────────────────────────────────────────────────┤
│ Layer 1: CLAUDE.md 지시사항                                │
│  → 가정 금지, 확인 우선, 복구 프로토콜                          │
├─────────────────────────────────────────────────────────┤
│ Layer 2: Hooks (자동 강제)                                 │
│  → Stop 시 검증, 위험 명령 차단, 포맷팅                        │
├─────────────────────────────────────────────────────────┤ 
│ Layer 3: 작업 구조화                                       │
│  → Plan → Task → Checkpoint → Verify                    │
└─────────────────────────────────────────────────────────┘
```

**효과 순서**: Layer 4 > Layer 1 > Layer 2 > Layer 3

- **Layer 4**가 가장 효과적인 이유: 멀티턴 자체를 줄이면 문제가 발생하지 않음
- **Layer 1**이 그 다음: 매 턴마다 참조되는 행동 규칙
- **Layer 2**는 안전망: CLAUDE.md를 무시해도 Hooks는 실행됨
- **Layer 3**은 구조적 보조: 복잡한 작업의 진행 방향을 고정

---

### 4.3 Layer 1: CLAUDE.md 지시사항

#### 4.3.1 조기 가정 방지 (Early Assumption Guard)

**원리**: LLM이 초기 턴에서 가정하고 솔루션을 조기 생성하는 것을 막는다.

```markdown
## Investigation Rules (English)
- Read source code before answering. No guessing on paths, configs, or behavior.
- Never claim to have confirmed a fix without actually reading the relevant file.
- When the same bug recurs, do a source-level deep dive — do not patch blindly.
- After /compact, re-read CLAUDE.md before continuing work.

## 조사 규칙 (한글)
- 답변 전에 반드시 소스 코드를 직접 읽을 것. 경로, 설정, 동작을 추측하지 않는다.
- 관련 파일을 실제로 읽어 확인하지 않았다면, 수정을 완료했다고 주장하지 않는다.
- 동일한 버그가 반복될 경우, 맹목적으로 패치하지 말고 소스 수준의 심층 분석을 수행한다.
- /compact 이후에는 작업을 계속하기 전에 CLAUDE.md를 다시 읽는다.

```

**작동 원리**:

1. Claude가 "아마 이 파일이겠지"라고 추측하려는 순간, Investigation Rules에 의해 먼저 파일을 읽게 됨
2. 파일을 읽으면 실제 상태를 알게 되므로 잘못된 가정이 형성되지 않음
3. `/compact` 이후에도 CLAUDE.md를 다시 읽으므로 규칙이 재적용됨

**Bad vs Good 비교**:

```markdown
# Bad: 가정 허용
## Rules
- 코드를 수정해줘

# Good: 가정 차단
## Investigation Rules
- 코드를 수정하기 전에 반드시 관련 파일을 읽을 것
- "아마 이럴 것이다"라는 가정으로 구현하지 말 것
- 에러 원인을 3가지 이상 가설로 세운 뒤 검증할 것
- 첫 번째 시도가 실패하면, 접근 방식 자체를 재검토할 것
```

**적용 예시** — 로그인 버그 수정:

```
사용자: "로그인이 안 돼"

[Investigation Rules 적용 전]
Claude: 토큰 만료 문제 같네요 → 바로 토큰 갱신 코드 작성 (가정)

[Investigation Rules 적용 후]
Claude: 먼저 관련 파일을 확인하겠습니다.
  → src/auth/login.ts 읽기
  → src/middleware/auth.ts 읽기
  → 에러 로그 확인
  → "bcrypt 버전 불일치로 해싱 결과가 다릅니다" (사실 기반 진단)
```

#### 4.3.2 체크포인트 강제 (Drift Prevention)

**원리**: 멀티턴에서 방향이 서서히 틀어지는 것을 감지하는 장치.

```markdown
## Checkpoint Rules
- 5단계 이상의 작업은 시작 전 계획을 세우고 사용자 승인을 받을 것
- 각 단계 완료 후 "현재 상태"를 한 줄로 보고할 것
- 원래 요청과 현재 작업이 다른 방향이면, 사용자에게 확인할 것
```

**작동 원리**:

```
Turn 1: 사용자 "회원가입 기능 만들어줘"
Turn 2: Claude "계획: 1) 스키마 2) API 3) 폼 4) 검증 5) 테스트" → 승인 요청
Turn 3: 사용자 "좋아, 진행해"
Turn 5: Claude "현재 상태: 스키마와 API 완료, 폼 작업 중"
Turn 7: Claude "현재 상태: 폼 완료, 이메일 인증도 추가할까요?" → 확인 요청
         (원래 요청에 이메일 인증은 없었음 → drift 감지)
```

**체크포인트가 없으면**:

```
Turn 1: "회원가입 기능 만들어줘"
Turn 3: 스키마 추가
Turn 5: API 추가... 그런데 이메일 인증도 필요할 것 같아서 추가
Turn 7: OAuth 로그인도 있으면 좋겠다... 추가
Turn 9: 사용자 "나는 간단한 회원가입만 원했는데 왜 이렇게 복잡해?"
```

#### 4.3.3 실패 시 복구 전략 (Recovery Protocol)

**원리**: "wrong turn → lost" 문제를 직접 방어. 같은 방향으로 계속 실패하는 루프를 끊는다.

```markdown
## Recovery Protocol
- 같은 접근을 2번 시도해서 실패하면 전혀 다른 방법을 시도할 것
- 에러가 반복되면 현재까지의 시도를 정리하고 사용자에게 보고할 것
- git diff로 변경사항이 커지면(100줄+) 중간 확인을 요청할 것
- 확신이 없는 상태에서 코드를 계속 작성하지 말 것
```

**작동 원리**:

```
시도 1: 환경변수 문제라고 가정 → .env 수정 → 실패
시도 2: 환경변수 로딩 순서 변경 → 실패

[Recovery Protocol 발동]
Claude: "2번 실패했습니다. 접근을 바꾸겠습니다."
  → 에러 스택 트레이스를 처음부터 다시 분석
  → 실제 원인: import 순서로 인한 circular dependency
```

**Recovery Protocol이 없으면**:

```
시도 1: 환경변수 수정 → 실패
시도 2: 환경변수 다른 방식 → 실패
시도 3: 환경변수 또 다른 방식 → 실패
시도 4: 환경변수 라이브러리 교체 → 실패
시도 5: ...계속 같은 방향... (wrong turn → lost)
```

#### 4.3.4 컨텍스트 압축 대비 (Compaction Defense)

**원리**: `/compact` 또는 자동 컨텍스트 압축 시 초기 지시사항이 유실되는 문제 방어.

```markdown
## Context Management
- 장기 작업 시 CLAUDE.md의 핵심 규칙을 참조할 것
- compaction 후에도 현재 작업 목표를 유지할 것
- 작업 계획은 TODO/Task로 외부화하여 컨텍스트 유실에 대비할 것
```

**작동 원리**:

CLAUDE.md는 매 턴마다 시스템에 의해 자동으로 주입된다. 대화 내용은 압축되더라도 CLAUDE.md는 항상 전문이 유지된다. 따라서:

1. **핵심 규칙은 CLAUDE.md에** → 압축 후에도 유지됨
2. **작업 계획은 Task 도구로 외부화** → 대화와 독립적으로 유지됨
3. **중간 결과는 파일로 저장** → 컨텍스트에 의존하지 않음

```
[Compact 전]
Turn 1-20: 복잡한 리팩토링 진행 중
  - CLAUDE.md: Investigation Rules, Recovery Protocol 적용 중
  - Task 목록: 5개 중 3개 완료
  - 중간 결과: src/utils/refactored.ts에 저장

[Compact 발생 → 대화 내용 압축]

[Compact 후]
  - CLAUDE.md: 여전히 전문 주입됨 → 규칙 유지
  - Task 목록: 여전히 "5개 중 3개 완료" 상태 유지
  - 중간 결과: 파일에 있으므로 읽을 수 있음
  - ⚠️ 유실: "왜 이 방식을 선택했는지"의 판단 근거
```

**판단 근거 유실 방어**:

중요한 결정은 CLAUDE.md의 Investigation Rules에 의해 매번 소스 코드를 다시 읽게 되므로, compact 후에도 올바른 판단을 재구성할 수 있다.

---

### 4.4 Layer 2: Hooks 자동 가드레일

#### 4.4.1 왜 Hooks가 필요한가

CLAUDE.md 지시사항은 **권고**다. LLM이 무시할 수 있다.
Hooks는 **강제**다. 코드가 실행되므로 LLM이 우회할 수 없다.

| 방어 수단 | 강제력 | 우회 가능 | 적용 시점 |
|----------|--------|----------|----------|
| CLAUDE.md | 약함 | LLM이 무시 가능 | 매 턴 |
| Hooks | 강함 | 코드 실행, 우회 불가 | 이벤트 기반 |
| settings.json deny | 절대적 | 시스템 레벨 차단 | 도구 호출 시 |

#### 4.4.2 Stop Hook — 작업 완료 시 검증

**원리**: Claude가 응답을 끝낼 때마다 원래 요청과 결과를 비교하도록 상기시킨다.

```jsonc
// .claude/settings.json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo '작업이 완료되었습니다. 원래 요청과 결과물이 일치하는지 검증하세요.'"
          }
        ]
      }
    ]
  }
}
```

**작동 원리**:

```
Turn 1: 사용자 "로그인 버그 수정해줘"
Turn 5: Claude "수정 완료했습니다"
  → [Stop Hook 실행]
  → Claude 컨텍스트에 "원래 요청과 결과물이 일치하는지 검증하세요" 주입
  → Claude: (자체 검증) 원래 요청은 로그인 버그 수정... 실제로 수정한 것은... 일치함
```

**drift가 발생한 경우**:

```
Turn 1: "로그인 버그 수정해줘"
Turn 5: OAuth 연동 코드를 작성하고 있음
  → [Stop Hook 실행]
  → "원래 요청과 결과물이 일치하는지 검증하세요"
  → Claude: 원래 요청은 "로그인 버그 수정"인데 OAuth 연동을 하고 있었습니다. 
            궤도를 벗어났네요. 원래 요청으로 돌아가겠습니다.
```

#### 4.4.3 PostToolUse Hook — 파일 수정 후 자동 검증

**원리**: 파일을 수정할 때마다 린트, 타입 체크를 자동 실행하여 잘못된 코드가 누적되는 것을 방지.

```jsonc
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.(ts|tsx)$'; then npx tsc --noEmit --pretty 2>&1 | head -20; fi"
          }
        ]
      }
    ]
  }
}
```

**작동 원리**:

```
Turn 3: Claude가 src/auth/login.ts 수정
  → [PostToolUse Hook 실행]
  → tsc --noEmit 실행
  → 타입 에러 2개 발견
  → Claude 컨텍스트에 에러 메시지 주입
  → Claude: 타입 에러를 즉시 수정 (잘못된 방향으로 진행하기 전에 catch)
```

**Hook이 없으면**:

```
Turn 3: login.ts 수정 (타입 에러 발생, 모름)
Turn 5: auth.ts 수정 (login.ts의 타입 에러 위에 추가 코드)
Turn 7: middleware.ts 수정 (에러 누적)
Turn 9: "왜 빌드가 안 되지?" → 3개 파일의 꼬인 타입 에러를 한꺼번에 수정해야 함
```

#### 4.4.4 PreToolUse Hook — 위험한 작업 사전 차단

**원리**: 잘못된 방향으로 갈 때 위험한 작업을 실행하기 전에 차단.

```jsonc
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_TOOL_INPUT\" | grep -qE 'rm -rf|DROP TABLE|git push --force'; then echo 'BLOCKED: 위험한 명령어가 감지되었습니다.' >&2; exit 2; fi"
          }
        ]
      }
    ]
  }
}
```

**exit code의 의미**:

| exit code | 동작 |
|-----------|------|
| `0` | 정상 진행 |
| `1` | 출력을 Claude에게 보여주되, 계속 진행 |
| `2` | **실행 차단** — 도구 호출이 취소됨 |

**작동 원리**:

```
Claude: (잘못된 방향으로) 테이블을 다시 만들자 → DROP TABLE todos
  → [PreToolUse Hook 실행]
  → "DROP TABLE" 감지 → exit 2
  → Bash 실행 자체가 차단됨
  → Claude: "위험한 명령어가 차단되었습니다. 다른 접근을 시도하겠습니다."
```

#### 4.4.5 SubagentStop Hook — 서브에이전트 검증

**원리**: 서브에이전트는 대화 맥락이 없으므로, 결과를 원래 목표와 대조해야 한다.

```jsonc
{
  "hooks": {
    "SubagentStop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo '서브에이전트 결과를 원래 목표와 대조하세요. 벗어났으면 무시하고 직접 수행하세요.'"
          }
        ]
      }
    ]
  }
}
```

#### 4.4.6 통합 Hook 설정

위 모든 Hook을 하나의 settings.json으로 통합한 예시:

```jsonc
// .claude/settings.json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Bash(npm run *)", "Bash(npx tsc:*)", "Bash(npx jest:*)",
      "Bash(git status:*)", "Bash(git log:*)", "Bash(git diff:*)"
    ],
    "deny": [
      "Bash(git push --force*)",
      "Bash(git reset --hard*)",
      "Bash(rm -rf*)",
      "Bash(sudo*)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_TOOL_INPUT\" | grep -qE 'rm -rf|DROP TABLE|TRUNCATE|git push --force'; then echo 'BLOCKED: dangerous command detected' >&2; exit 2; fi"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.(ts|tsx)$'; then npx tsc --noEmit --pretty 2>&1 | head -20; fi"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo '원래 요청과 결과물이 일치하는지 검증하세요.'"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo '서브에이전트 결과를 원래 목표와 대조하세요.'"
          }
        ]
      }
    ]
  }
}
```

---

### 4.5 Layer 3: 작업 구조화

#### 4.5.1 Plan → Task → Checkpoint → Verify 패턴

**원리**: 복잡한 작업을 미리 구조화하면 각 단계에서 방향을 확인할 수 있다.

```
[Plan 단계] — 무엇을 할지 정의
    ↓
[Task 분해] — 단계별로 나누기
    ↓
[실행 + Checkpoint] — 각 단계 완료 시 확인
    ↓
[Verify] — 전체 결과를 원래 요청과 비교
```

**실제 작업 흐름 예시**:

```
사용자: "회원가입 기능을 만들어줘"

[Plan]
Claude: 다음 계획으로 진행하겠습니다:
  1. User 모델에 email, password 필드 추가
  2. POST /api/auth/register 엔드포인트 구현
  3. 회원가입 폼 컴포넌트 생성
  4. 입력 검증 (Zod 스키마)
  5. 테스트 작성
  승인하시겠습니까?

사용자: "승인"

[Task 1 완료 → Checkpoint]
Claude: "User 모델 완료. 다음 단계: API 엔드포인트"

[Task 3 완료 → Checkpoint]  
Claude: "폼 컴포넌트 완료. 현재 소셜 로그인도 추가할 수 있는데, 범위에 포함할까요?"
  → drift 감지 — 원래 요청에 소셜 로그인은 없었음

[Verify]
Claude: "모든 단계 완료. 원래 요청 '회원가입 기능'에 대해:
  ✅ User 모델, ✅ API, ✅ 폼, ✅ 검증, ✅ 테스트"
```

#### 4.5.2 외부화 (Externalization)

작업 상태를 대화 컨텍스트가 아닌 외부 도구에 저장하면, compact 후에도 유지된다.

| 저장 위치 | 용도 | compact 시 유지 |
|----------|------|----------------|
| 대화 내 텍스트 | 임시 논의 | ❌ 유실됨 |
| Task 도구 | 작업 목록, 진행 상태 | ✅ 유지됨 |
| 파일 시스템 | 중간 결과물, 코드 | ✅ 유지됨 |
| CLAUDE.md | 핵심 규칙 | ✅ 매 턴 자동 주입 |
| Git commit | 완료된 작업 | ✅ 영구 보존 |

---

### 4.6 Layer 4: 사용자 습관

#### 4.6.1 단일 턴 완결 프롬프트

**가장 효과적인 방어**: 멀티턴 자체를 줄이면 성능 저하가 발생하지 않는다.

```markdown
# Bad: 3턴 소요 (멀티턴 의존)
Turn 1: "버그 수정해줘"
Turn 2: "로그인 관련이야"
Turn 3: "401 에러가 나"

# Good: 1턴 완결
Turn 1: "로그인 시 401 반환되는 버그 수정. 
         src/auth/login.ts의 토큰 검증 로직 확인.
         기대 동작: 유효한 credentials로 200 + JWT 반환"
```

**단일 턴 완결 프롬프트 구조**:

```
[무엇을] + [어디서] + [어떤 상태인지] + [기대 결과]
```

예시:

| 구성 요소 | 예시 |
|----------|------|
| 무엇을 | 로그인 버그 수정 |
| 어디서 | `src/auth/login.ts` |
| 어떤 상태 | 유효한 비밀번호로 401 반환됨 |
| 기대 결과 | 200 + JWT 토큰 반환 |

#### 4.6.2 중간 확인 습관

장기 작업에서 5턴마다 한 번씩 확인:

```
사용자: "현재 상태 요약해줘"
Claude: "원래 요청: X. 현재 진행: Y 완료, Z 진행 중. 범위 변경 없음."
사용자: "좋아, 계속해"
```

이 한 턴이 drift를 초기에 잡아준다.

#### 4.6.3 새 세션 활용

의미 있는 방향 전환이 필요할 때는 같은 대화를 이어가지 말고 새 세션을 시작한다:

```bash
# 기존 대화에서 방향이 꼬였을 때
# Bad: 같은 세션에서 "아까 한 거 다 무시하고 처음부터 다시 해줘"
# Good: 새 세션 시작
claude "로그인 시 401 에러 수정. bcrypt 해싱 불일치가 원인. src/auth/login.ts 확인"
```

새 세션은:
- 이전 턴의 잘못된 가정이 없음
- CLAUDE.md가 새로 로드됨
- 깨끗한 컨텍스트에서 시작

---

### 4.7 완성 템플릿

아래는 멀티턴 방어가 적용된 CLAUDE.md 전체 템플릿이다. 프로젝트에 맞게 `[placeholder]`를 수정하여 사용한다.

```markdown
# [ProjectName]

## Project
[One-line description]

- Framework: [e.g. Next.js 15]
- Language: [e.g. TypeScript 5]
- Database: [e.g. PostgreSQL + Prisma]

## Commands
- `npm run dev` — dev server
- `npm run test` — run tests
- `npm run build` — production build
- `npm run lint` — lint check

## Language Rules
- Code, comments, variable names, git commits: **English**
- All responses to user: **Korean**
- Error messages: keep original English, explain in Korean

## Investigation Rules
- Read source code before answering. No guessing on paths, configs, or behavior.
- Never claim to have confirmed a fix without actually reading the relevant file.
- When the same bug recurs, do a source-level deep dive — do not patch blindly.
- After /compact, re-read CLAUDE.md before continuing work.
- Form at least 3 hypotheses before investigating a bug. Verify each.
- If first attempt fails, reconsider the approach itself — not just the implementation.

## Checkpoint Rules
- For tasks with 5+ steps, present a plan and get user approval before starting.
- Report current status in one line after completing each step.
- If current work diverges from the original request, ask user to confirm.

## Recovery Protocol
- If the same approach fails twice, try a fundamentally different method.
- When errors repeat, summarize all attempts so far and report to user.
- If git diff exceeds 100 lines of changes, request mid-point review.
- Do not keep writing code when uncertain — stop and ask.

## Context Management
- Reference CLAUDE.md rules during long tasks.
- Maintain current task objective even after compaction.
- Externalize plans via TODO/Task tools to survive context loss.

## Guardrails

### Database
- NEVER: `DROP TABLE`, `DROP DATABASE`, `TRUNCATE`, `DELETE FROM` without WHERE
- NEVER: `ALTER TABLE DROP COLUMN` without explicit user approval
- Always confirm a backup exists before any destructive operation

### Git
- NEVER: `git push --force`, `git reset --hard`, `git commit --no-verify`
- NEVER auto-commit or auto-push — always wait for explicit user request

### Dependencies
- NEVER: `npm audit fix --force`
- Do not upgrade versions without a clear reason
- Do not introduce new libraries outside core stack without approval

### Protected Files
- [list your protected files here]

@.claude/rules/code-style.md
@.claude/rules/testing.md
```

---

### 4.8 참고 자료

#### 이 가이드의 근거

- **연구**: "When LLMs Take a Wrong Turn in a Conversation, They Get Lost and Do Not Recover" — 200,000+ 시뮬레이션 대화 분석, 6개 생성 작업에서 평균 39% 성능 하락 확인
- **핵심 발견**: Aptitude loss(경미) + Unreliability(심각). 초기 턴의 잘못된 가정이 전체 대화를 오염시킴

#### 방어 수단별 효과

| 방어 수단 | 효과 | 구현 난이도 | 적용 위치 |
|----------|------|-----------|----------|
| 단일턴 완결 프롬프트 | 매우 높음 | 쉬움 | 사용자 습관 |
| Investigation Rules | 높음 | 쉬움 | CLAUDE.md |
| Checkpoint Rules | 높음 | 쉬움 | CLAUDE.md |
| Recovery Protocol | 중간 | 쉬움 | CLAUDE.md |
| Stop Hook | 중간 | 보통 | settings.json |
| PostToolUse Hook | 중간 | 보통 | settings.json |
| PreToolUse Hook | 높음 | 보통 | settings.json |
| Task 외부화 | 중간 | 쉬움 | 작업 방식 |
| 새 세션 활용 | 높음 | 쉬움 | 사용자 습관 |

#### 관련 문서

- `CLAUDE.md` — 기본 프로젝트 템플릿
- `CLAUDE.local.md` — 개인 설정 템플릿
- `CLAUDE-template(Root).md` — 모노레포 루트 템플릿
- [Claude Code Hooks Guide](../guide/claude-code-hooks-guide.md) — 상세 Hook 설정 가이드
- [CLI Alias & Settings](../tips/CLAUDE-CODE-CLI-ALIAS-SETTINGS.md) — 권한/설정 레퍼런스
