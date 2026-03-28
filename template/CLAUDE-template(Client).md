# CLAUDE.md - TODO Client

<!-- 
packages/client 전용 설정
루트 CLAUDE.md를 상속하며, 클라이언트 특화 규칙을 정의
-->
# 클라이언트 — packages/client

Next.js 14 App Router 기반 프론트엔드. React Server Components 우선 사용.

## 기술 스택

| 기술 | 용도 |
|------|------|
| Next.js 14 App Router | 프레임워크 |
| TanStack Query v5 | 서버 상태 관리 |
| Tailwind CSS + `cn()` | 스타일링 |
| React Hook Form + Zod | 폼 + 검증 |

## 디렉토리 구조

```
src/
├── app/            Next.js App Router (페이지, 레이아웃)
├── components/
│   ├── ui/         범용 UI 컴포넌트 (Button, Input 등) — 상태 없음
│   └── todo/       도메인 컴포넌트 (비즈니스 로직 포함)
├── hooks/          커스텀 훅
├── lib/            API 클라이언트, 유틸리티
└── types/          로컬 타입 (shared 외)
```

## 명령어

```bash
pnpm dev          # 개발 서버
pnpm build        # 프로덕션 빌드
pnpm test         # Jest 테스트
pnpm test:watch   # 감시 모드
pnpm lint         # 린트
pnpm typecheck    # 타입 체크
```

## 환경 변수

| 변수 | 필수 | 설명 |
|------|------|------|
| `NEXT_PUBLIC_API_URL` | Y | 백엔드 API URL (기본: `http://localhost:4000`) |

## 가드레일

### Server / Client 컴포넌트
- 기본값은 Server Component — `'use client'`는 상태·이벤트 핸들러가 필요할 때만
- Server Component에서 `useQuery` 등 클라이언트 훅 사용 금지

### 이미지
- `<img>` 직접 사용 금지 — `next/image` 사용, `width`/`height` 또는 `fill` 필수

### 타입 / 스키마
- 타입과 Zod 스키마는 `@todo-app/shared`에서 import
- 로컬에 중복 정의 금지

### 스타일
- 인라인 스타일(`style={{}}`) 금지 — Tailwind 유틸리티 클래스 사용
- 조건부 클래스명은 `cn()` 헬퍼 사용

### 테스트
- 컴포넌트 테스트: 사용자 관점 쿼리 사용 (`getByRole`, `getByText`)
- 구현 세부사항 테스트 금지 (클래스명, 내부 상태 직접 검사)
- 훅 테스트: `renderHook` + `QueryClientProvider` wrapper 사용

@.claude/rules/client-patterns.md