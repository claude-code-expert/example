# [Claude Code Expert](https://github.com/claude-code-expert) 서적의 예제 문서 모음

> 한빛미디어 | 2026.04 출간 예정

## 저자

| 이름 | 이메일 | GitHub | Homepage |
|------|--------|--------|----------|
| 이남희 | [villainscode@gmail.com](mailto:villainscode@gmail.com) | | | 
| 백승현 | [pekuid@gmail.com](mailto:pekuid@gmail.com) | | | 

## 서적 링크

- [교보문고](https://www.kyobobook.co.kr/)
- [알라딘](https://www.aladin.co.kr/)

# AI 협업을 위한 프로젝트 문서화 가이드

AI 코딩 도구(Claude Code, OpenAI Codex, Google Jules, Cursor 등)와 효과적으로 협업하기 위한 프로젝트 문서 구조와 템플릿 모음입니다. TODO 앱을 예제 프로젝트로 활용하여 실전 문서화 방법을 보여줍니다.

## Claude Code 레퍼런스

| 문서 | 설명 |
|------|------|
| [Claude Code 치트시트 (HTML)](https://claude-code-expert.github.io/example/guide/claude-code-cheatsheet-ko.html) | v2.1.91 — 키보드 단축키, 슬래시 명령어, 설정, MCP, 권한 모드 전체 정리 (인터랙티브 버전) |
| [`claude-code-cheatsheet-ko.md`](guide/claude-code-cheatsheet-ko.md) | 위와 동일 내용의 Markdown 버전 |
| [미공개 예정 기능 분석 (HTML)](https://claude-code-expert.github.io/example/guide/claude-code-unshipped.html) | npm 소스 유출(2026-03-31) 기반 23개 미출시 기능 정리 (인터랙티브 버전) |
| [`claude-code-unshipped.md`](guide/claude-code-unshipped.md) | 위와 동일 내용의 Markdown 버전 |

## 프로젝트 구조

```
├── docs/                              # 프로젝트 핵심 문서
│   ├── PRD.md                         # 제품 요구사항 정의서 (무엇을, 왜)
│   ├── TRD.md                         # 기술 요구사항 정의서 (어떻게 설계)
│   ├── REQUIREMENTS.md                # AI 구현 요구사항 (어떻게 구현)
│   ├── COMMANDS.md                    # Claude Code 슬래시 명령어 레퍼런스
│   └── guide/                         # 외부 도구 가이드
│       ├── SpecKit_Guide.md           # GitHub Spec Kit (SDD 프레임워크)
│       ├── SuperClaude_Guide.md       # SuperClaude 프레임워크
│       └── Vercel_Agent_Skills_Guide.md # Vercel Agent Skills 생태계
├── template/                          # 재사용 가능한 템플릿
│   ├── AGENTS-Guide.md                # AGENTS.md 작성 가이드
│   ├── AGENTS-template.md             # AGENTS.md 기본 템플릿
│   ├── AGENTS(java-back).md           # Spring Boot 백엔드 예제
│   ├── CLAUDE-template(Root).md       # 모노레포 루트 CLAUDE.md 템플릿
│   ├── CLAUDE-template(Client).md     # 클라이언트 CLAUDE.md 템플릿
│   ├── CLAUDE-template(Server).md     # 서버 CLAUDE.md 템플릿
│   ├── CLAUDE.md                      # CLAUDE.md 전체 예제
│   ├── CLAUDE.local.md                # CLAUDE.local.md 개인 설정 템플릿
│   ├── code-style.md                  # 코딩 스타일 컨벤션
│   ├── root-code-style.md             # 모노레포 루트 코드 스타일
│   ├── git-workflow.md                # Git 워크플로우 가이드라인
│   ├── testing.md                     # 테스트 전략 템플릿
│   ├── patterns.md                    # 아키텍처 패턴 가이드
│   ├── client-patterns.md             # 클라이언트 패턴 (컴포넌트, 훅, 상태관리)
│   ├── server-patterns.md             # 서버 패턴 (미들웨어, 검증, 에러처리)
│   └── skill-template.md              # 스킬 작성 템플릿
├── skills/                            # AI 워크플로우 정의 (Skills)
│   ├── test-driven-development.md     # TDD 워크플로우
│   ├── code-reviewer.md               # 코드 리뷰 가이드
│   └── react-component.md             # React 컴포넌트 생성 가이드
├── subagent/                          # 서브에이전트 문서
│   └── subagent.md                    # 서브에이전트 동작 원리 및 구성 가이드
├── tips/                              # 실전 팁 & 활용 가이드
│   ├── CLAUDE-CODE-CLI-ALIAS-SETTINGS.md  # CLI 플래그, 별칭, 설정 레퍼런스
│   ├── CLAUDE-CODE-NTFY-MOBILE-APPROVAL.md # 모바일 승인 알림(ntfy) 설정
│   └── lsp.md                         # LSP 연동 가이드 (공식 플러그인, cclsp, Serena)
├── guide/                             # 심화 가이드
│   ├── claude-code-hooks-guide.md     # Hooks 사용법 종합 가이드
│   ├── claude-code-cheatsheet-ko.html # Claude Code 치트시트 (HTML 인터랙티브)
│   ├── claude-code-cheatsheet-ko.md   # Claude Code 치트시트 (Markdown)
│   ├── claude-code-unshipped.html     # 미공개 예정 기능 분석 (HTML)
│   └── claude-code-unshipped.md       # 미공개 예정 기능 분석 (Markdown)
├── cli/                               # CLI 명령어 레퍼런스
│   ├── git_cli.md                     # Git 터미널 명령어 모음
│   └── postgres_cli.md                # PostgreSQL 터미널 명령어 모음
├── postgres/                          # 데이터베이스 레퍼런스
│   └── postgres-commands.md           # PostgreSQL 터미널 명령어 모음
├── images/                            # 시각 자료
│   ├── cc-2026-03-31.jpeg             # Claude Code 소스 유출 관련 이미지
│   ├── claude-code-cheatsheet.png     # Claude Code 치트시트 이미지
│   ├── response-1.png                 # 응답 비교 이미지 1
│   ├── response-2.png                 # 응답 비교 이미지 2
│   └── response-compare.md            # 응답 비교 문서
├── .claude/                           # Claude Code 설정
│   ├── settings.json                  # 프로젝트 설정 (권한, 훅)
│   ├── settings.local.json            # 로컬 전용 설정 (VCS 제외)
│   ├── hooks/                         # 훅 스크립트 예제 (12개)
│   └── rules/                         # 규칙 파일 템플릿 (4개)
└── .gitignore
```

## 3계층 문서 체계

이 프로젝트는 AI가 코드를 정확히 생성하기 위해 필요한 문서를 3계층으로 분리합니다.

| 계층 | 문서 | 역할 | 대상 |
|------|------|------|------|
| 비즈니스 | `PRD.md` | 무엇을, 왜 만드는가 | PM, 기획자 |
| 아키텍처 | `TRD.md` | 시스템을 어떻게 설계하는가 | 개발자, 아키텍트 |
| 구현 | `REQUIREMENTS.md` | AI가 어떻게 구현하는가 | AI 코딩 도구 |

## AI 도구별 설정 파일

| 파일 | 대상 도구 | 특징 |
|------|-----------|------|
| `AGENTS.md` | 범용 (Codex, Jules, Cursor 등) | 오픈 표준, 60,000+ 프로젝트 채택 |
| `CLAUDE.md` | Claude Code | 모노레포 계층 구조 지원 |

두 파일 모두 프로젝트 구조, 기술 스택, 코딩 컨벤션, 금지 패턴, 테스트 전략을 정의합니다.

## 예제 프로젝트: TODO 앱

문서화 방법을 실전으로 보여주기 위한 예제 프로젝트입니다.

**기술 스택:**
- Frontend: Next.js 14 / React 18 / TypeScript 5 / Tailwind CSS 3
- Backend: Next.js API Routes / Prisma 5
- Database: PostgreSQL 15
- Test: Jest 29 / React Testing Library

**핵심 기능:**
- TODO CRUD (생성, 조회, 수정, 삭제)
- 완료 상태 토글
- 필터링 (전체/완료/미완료)

## 서브에이전트 가이드

`subagent/subagent.md`에서 Claude Code 서브에이전트의 동작 원리를 다룹니다. 책에 다 쓰지 못한 분량이라 별도의 가이드 문서를 만들었고, 실제 구현 예제는 https://github.com/claude-code-expert/subagents 를 통해 확인할 수 있습니다. 
해당 repository에 자세한 사용법 설명이 첨부되어 있으니 참고하시기 바랍니다. 

- 서브에이전트 개념 및 사용 이유 (컨텍스트 보존, 도구 제한, 병렬 실행, 모델 선택)
- 내부 동작 방식 (Task 도구 기반 호출 흐름)
- 에이전트 정의 형식 (YAML frontmatter + Markdown 시스템 프롬프트)
- 저장 위치와 우선순위 (`CLI > .claude/agents/ > ~/.claude/agents/ > plugin`)
- Frontmatter 필드 레퍼런스 (`name`, `tools`, `model`, `maxTurns`, `isolation` 등)
- 서브에이전트 vs Agent Teams 비교
- [실전 서브에이전트 구성 예제 (GitHub)](https://github.com/claude-code-expert/subagents)

## 외부 도구 가이드

`docs/guide/` 디렉토리에서 주요 AI 코딩 프레임워크의 가이드를 제공합니다.

| 문서 | 설명 |
|------|------|
| `SpecKit_Guide.md` | GitHub Spec Kit — Spec-Driven Development 프레임워크. 5개 핵심 명령어, 20+ AI 에이전트 지원 |
| `SuperClaude_Guide.md` | SuperClaude — Claude Code 전용 확장. 30개 슬래시 명령어, 16개 전문 페르소나, 8개 MCP 서버 |
| `Vercel_Agent_Skills_Guide.md` | Vercel Agent Skills — 17+ AI 에이전트 호환 스킬 생태계. React, 웹 디자인, 배포 스킬 제공 |

## 실전 팁 & 활용 가이드

`tips/` 디렉토리에서 Claude Code 활용 팁을 제공합니다.

| 문서 | 설명 |
|------|------|
| `CLAUDE-CODE-CLI-ALIAS-SETTINGS.md` | CLI 플래그 65+개, 셸 별칭 20+개, settings.json 구조, 권한 규칙, 위험 모드 가이드 |
| `CLAUDE-CODE-NTFY-MOBILE-APPROVAL.md` | ntfy를 이용한 모바일 승인 알림 설정 방법 |
| `lsp.md` | LSP 연동 3가지 방법 비교 — 공식 플러그인(권장), cclsp(MCP), Serena(심볼 편집) |

## Hooks 가이드

`guide/claude-code-hooks-guide.md`에서 Hooks 시스템을 상세히 다룹니다.

- 훅 타이밍: `PreToolUse`, `PostToolUse`, `Notification`, `Stop`
- 환경 변수: `$CLAUDE_FILE_PATH`, `$CLAUDE_TOOL_NAME`, `$CLAUDE_TOOL_INPUT`
- 매처 형식: regex 문자열 및 tools 객체
- `.claude/hooks/`에 12개 예제 스크립트 포함 (포맷팅, 린팅, 테스트, 보안 차단, 알림)

## 슬래시 명령어 레퍼런스

`docs/COMMANDS.md`에서 Claude Code의 전체 슬래시 명령어를 카테고리별로 정리합니다.

- 필수 명령어: `/init`, `/memory`, `/model`, `/plan`
- 자주 사용: `/add-dir`, `/review`, `/rewind`, `/context`
- 설정/환경: `/config`, `/permissions`, `/hooks`
- 외부 연동: `/mcp`, `/install-github-app`
- 보안/진단: `/security-review`, `/doctor`

## CLI 명령어 레퍼런스

`cli/` 디렉토리에서 개발 환경에서 자주 사용하는 CLI 명령어를 정리합니다.

| 문서 | 설명 |
|------|------|
| `git_cli.md` | Git 필수·고급 명령어 — 초기화, 브랜치, 스테이징, 리셋, 리베이스, stash, 서브모듈 등 |
| `postgres_cli.md` | PostgreSQL 명령어 — 접속, psql 메타명령어, DB·유저·권한 관리, CRUD, 백업/복원, 서버 관리 |

## PostgreSQL 레퍼런스

`postgres/postgres-commands.md`에서 PostgreSQL 터미널 명령어를 종합적으로 정리합니다.

- psql 메타 명령어 19개, 사용자/역할 관리, 데이터베이스/스키마 운영
- 테이블 관리 (제약조건, 인덱스, 파티셔닝), CRUD 고급 문법 (UPSERT, CTE, JOIN)
- 권한 관리 (GRANT/REVOKE), 백업/복원, 고급 모니터링 쿼리

## 템플릿 사용법

### AGENTS.md 적용

1. `template/AGENTS-Guide.md`로 작성 원칙 파악
2. `template/AGENTS-template.md`를 프로젝트 루트에 `AGENTS.md`로 복사
3. 프로젝트에 맞게 내용 작성 (Java 백엔드는 `AGENTS(java-back).md` 참고)

### CLAUDE.md 적용 (모노레포)

```
프로젝트 루트/
├── CLAUDE.md                        ← CLAUDE-template(Root).md
├── packages/client/CLAUDE.md        ← CLAUDE-template(Client).md
└── packages/server/CLAUDE.md        ← CLAUDE-template(Server).md
```

하위 디렉토리의 `CLAUDE.md`는 상위 설정을 상속하며 해당 패키지에 특화된 규칙을 추가합니다.

개인 설정은 `template/CLAUDE.local.md`를 참고하여 `.claude/CLAUDE.local.md`로 작성합니다 (gitignore 대상).

### Skills 적용

`skills/` 디렉토리의 파일을 프로젝트의 `.claude/skills/` 경로에 복사하여 사용합니다. 새 스킬을 만들 때는 `template/skill-template.md`를 참고합니다.

### Rules 적용

`.claude/rules/` 디렉토리에 규칙 파일 템플릿 4종이 포함되어 있습니다.

| 파일 | 적용 경로 | 설명 |
|------|-----------|------|
| `api-routes.md` | `src/api/**/*.ts` | API 개발 규칙 (응답 형식, 에러 처리, 인증) |
| `frontend.md` | `src/components/**/*.tsx` | 프론트엔드 컴포넌트 규칙 |
| `testing.md` | `**/*.test.ts` | 테스트 작성 규칙 (AAA 패턴) |
| `database.md` | `src/models/**/*.ts` | 데이터베이스 규칙 (모델 정의, 쿼리) |

### Hooks 적용

`.claude/hooks/` 디렉토리에 12개 예제 스크립트가 포함되어 있습니다.

| 카테고리 | 파일 | 설명 |
|----------|------|------|
| 포맷팅 | `format-ts.sh`, `format-py.sh` | 저장 시 코드 포맷팅 |
| 린팅 | `lint-ts.sh`, `lint-py.sh` | 파일 수정 시 린트 실행 |
| 테스트 | `test-ts.sh`, `test-py.sh` | 자동 테스트 실행 |
| 보안 | `block-dangerous.py`, `check-deps-py.py` | 위험 명령 차단, 의존성 검사 |
| 알림 | `notify-slack.sh`, `notify-telegram.sh` | 완료 알림 발송 |
| 설정 | `settings.typescript.json`, `settings.python.json` | 언어별 설정 오버라이드 |

### 코딩 컨벤션 & 패턴 템플릿

`template/` 디렉토리에 프로젝트 전반의 코딩 컨벤션과 아키텍처 패턴 템플릿이 포함되어 있습니다.

| 파일 | 설명 |
|------|------|
| `code-style.md` | 코딩 스타일 컨벤션 (네이밍, 포맷팅, 타입 안전성) |
| `root-code-style.md` | 모노레포 루트 레벨 코드 스타일 |
| `git-workflow.md` | Git 워크플로우 (브랜치 전략, 커밋, PR) |
| `testing.md` | 테스트 전략 (단위, 통합, E2E) |
| `patterns.md` | 아키텍처 패턴 가이드 |
| `client-patterns.md` | 클라이언트 패턴 (컴포넌트, 훅, 상태관리) |
| `server-patterns.md` | 서버 패턴 (미들웨어, 검증, 에러처리) |

## 핵심 원칙

- **AI 관점으로 작성**: 사람이 아닌 AI가 읽고 실행할 수 있도록 명확하게
- **버전을 명시**: `Node.js` 대신 `Node.js 20.11`처럼 정확한 버전 기재
- **Good/Bad 예제 제공**: 금지 패턴과 권장 패턴을 코드로 보여주기
- **테스트 우선**: TDD 방법론을 기본 워크플로우로 채택
