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

## 프로젝트 구조

```
├── docs/                            # 프로젝트 핵심 문서
│   ├── PRD.md                       # 제품 요구사항 정의서 (무엇을, 왜)
│   ├── TRD.md                       # 기술 요구사항 정의서 (어떻게 설계)
│   └── REQUIREMENTS.md              # AI 구현 요구사항 (어떻게 구현)
├── template/                        # 재사용 가능한 템플릿
│   ├── AGENTS-Guide.md              # AGENTS.md 작성 가이드
│   ├── AGENTS-template.md           # AGENTS.md 기본 템플릿
│   ├── AGENTS(java-back).md         # Spring Boot 백엔드 예제
│   ├── CLAUDE-template(Root).md     # 모노레포 루트 CLAUDE.md 템플릿
│   ├── CLAUDE-template(Client).md   # 클라이언트 CLAUDE.md 템플릿
│   └── CLAUDE-template(Server).md   # 서버 CLAUDE.md 템플릿
├── skills/                          # AI 워크플로우 정의
│   ├── test-driven-development.md   # TDD 워크플로우
│   ├── code-reviewer.md             # 코드 리뷰 가이드
│   └── react-component.md           # React 컴포넌트 생성 가이드
└── commands/                        # 커스텀 명령어
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

### Skills 적용

`skills/` 디렉토리의 파일을 프로젝트의 `.claude/skills/` 경로에 복사하여 사용합니다.

## 핵심 원칙

- **AI 관점으로 작성**: 사람이 아닌 AI가 읽고 실행할 수 있도록 명확하게
- **버전을 명시**: `Node.js` 대신 `Node.js 20.11`처럼 정확한 버전 기재
- **Good/Bad 예제 제공**: 금지 패턴과 권장 패턴을 코드로 보여주기
- **테스트 우선**: TDD 방법론을 기본 워크플로우로 채택
