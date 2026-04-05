# TODO 앱 — 루트

할 일 관리 풀스택 웹 앱. pnpm 모노레포로 client/server/shared 패키지를 관리한다.

- **상세 요구사항**: `docs/REQUIREMENTS.md`, `docs/PRD.md`, `docs/TRD.md`
- **API 명세**: `docs/api/`

## ⚙️ 운영 규칙 (Meta Rules)

**반복 문제 재발 시**: 단순 재시도 금지. 관련 소스 코드를 반드시 직접 읽고 근본 원인을 파악한 뒤 응답한다.

**세션 재시작 후**: `/compact` 완료 및 새 세션 시작 시 반드시 이 파일을 먼저 다시 읽어 프로젝트 컨텍스트를 복원한다.


## 패키지 구조

```
packages/
├── client/   Next.js 14 App Router + React Query + Tailwind CSS
├── server/   Express + TypeScript + Prisma ORM
└── shared/   공유 타입, Zod 스키마, 유틸리티
```

## 기술 스택

| 영역 | 기술 | 버전 |
|------|------|------|
| 패키지 관리 | pnpm workspace | 8.x |
| 클라이언트 | Next.js / React / TypeScript | 14.x / 18.x / 5.x |
| 서버 | Express / TypeScript | 4.x / 5.x |
| DB | PostgreSQL / Prisma | 15.x / 5.x |
| 테스트 | Jest / React Testing Library | 29.x |

## 명령어

```bash
# 전체 설치
pnpm install

# 전체 개발 서버
pnpm dev

# 패키지 개별 실행
pnpm --filter client dev
pnpm --filter server dev

# 전체 테스트
pnpm test
pnpm test:coverage

# 타입 체크 + 린트
pnpm typecheck
pnpm lint

# 전체 빌드
pnpm build

# Prisma
pnpm --filter server prisma migrate dev --name <이름>
pnpm --filter server prisma generate
pnpm --filter server prisma db seed
```

## 언어 규칙

- 코드, 변수명, 주석, 커밋 메시지: **영어**
- 사용자 응답, 요약, 설명: **한국어**
- 에러 메시지: 원문 영어 유지, 원인 설명은 한국어

## 조사 원칙

- 경로, 설정값, 동작 방식은 반드시 소스 코드를 먼저 읽고 답할 것. 추측 금지.
- 같은 버그가 반복되면 소스 레벨 깊이 파고들어 근본 원인 파악.
- `/compact` 이후 새 세션 시작 시 CLAUDE.md를 다시 읽고 컨텍스트 재확립.

## 가드레일

### 공통
- `any` 타입 사용 금지 — `unknown` + 타입 내로잉 사용
- `console.log` 직접 사용 금지 — `lib/logger.ts` 사용
- 테스트 없이 기능 구현 완료 처리 금지
- 패키지 간 내부 구현 직접 의존 금지 — `shared` 패키지를 통해 공유

### Git
- `git push --force`, `git reset --hard`, `git commit --no-verify` 금지
- 자동 커밋/푸시 금지 — 사용자 명시 요청 시에만
- 큰 아키텍처 변경 전 계획 공유 후 승인받을 것

### 의존성
- `npm audit fix --force` 금지
- 이유 없는 라이브러리 버전 업그레이드 금지
- 코어 스택 외 새 라이브러리 도입 시 사유 제시 후 승인 필요

### 보호 파일
- `packages/server/prisma/migrations/` — 수동 편집 금지, prisma migrate만 사용
- `packages/*/package.json` (의존성 항목) — 변경 전 사용자 승인 필요
- `.env*` 파일 — 생성/편집 금지, 사용자가 직접 관리
- `docs/` — 삭제 금지, 편집은 허용

@.claude/rules/root-code-style.md


### 작업 완료 후 응답 형식

작업을 완료한 뒤 반드시 한국어로 다음 항목을 요약한다:

1. **무엇을 변경했는지**
2. **왜 그렇게 했는지**
3. **주의할 점이 있는지**
