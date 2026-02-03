<!--
Claude Code가 어떻게 동작할지 설정
- 대화 스타일, 워크 플로우 규칙
- 프로젝트 구조와 컨텍스트 
- 행동 지침 기술 

서버-클라 구조의 모노레포 예시 
todo-app/
├── CLAUDE.md                 # 루트: 전체 프로젝트 공통 설정
├── packages/
│   ├── client/
│   │   ├── CLAUDE.md         # 클라이언트 전용 설정
│   │   └── ...
│   ├── server/
│   │   ├── CLAUDE.md         # 서버 전용 설정
│   │   └── ...
│   └── shared/
│       ├── CLAUDE.md         # 공유 패키지 설정
│       └── ...
├── docs/
│   ├── REQUIREMENTS.md
│   ├── PRD.md
│   └── TRD.md
└── ...

우선순위: 하위 디렉토리의 CLAUDE.md가 상위를 오버라이드합니다.
-->




# CLAUDE.md - TODO 애플리케이션

<!-- 
이 파일은 Claude Code가 프로젝트를 이해하고 
일관된 방식으로 작업하도록 안내합니다.
최종 수정: 2025-02-03
-->

## 프로젝트 개요

할 일 관리 웹 애플리케이션. 모노레포 구조로 클라이언트와 서버를 분리하여 관리한다.

- **목적**: AI 코딩 도구를 활용한 풀스택 개발 학습
- **상태**: 개발 중 (Phase 1: 백엔드 API)
- **문서**: 상세 요구사항은 `docs/REQUIREMENTS.md` 참조

## 프로젝트 구조
```
todo-app/
├── packages/
│   ├── client/          # React 프론트엔드 (Next.js)
│   ├── server/          # Express 백엔드 API
│   └── shared/          # 공유 타입, 유틸리티
├── docs/                # 프로젝트 문서
├── scripts/             # 빌드/배포 스크립트
└── docker/              # Docker 설정
```

<details>
<summary>📁 각 패키지 역할 상세</summary>

### packages/client
- Next.js 14 App Router 기반
- React Query로 서버 상태 관리
- Tailwind CSS 스타일링

### packages/server
- Express + TypeScript
- Prisma ORM
- Jest 테스트

### packages/shared
- 공유 TypeScript 타입 (`Todo`, `ApiResponse` 등)
- 공통 유틸리티 함수
- Zod 검증 스키마

</details>

## 기술 스택

| 영역 | 기술 | 버전 |
|------|------|------|
| 패키지 관리 | pnpm workspace | 8.x |
| 클라이언트 | Next.js, React, TypeScript | 14.x, 18.x, 5.x |
| 서버 | Express, TypeScript | 4.x, 5.x |
| 데이터베이스 | PostgreSQL, Prisma | 15.x, 5.x |
| 테스트 | Jest, React Testing Library | 29.x |

## 작업 규칙

### 일반 원칙

1. **테스트 먼저**: 새 기능 구현 시 테스트 코드를 먼저 작성한다
2. **작은 단위**: 한 번에 하나의 기능만 구현한다
3. **확인 후 진행**: 큰 변경 전에 계획을 먼저 공유하고 승인을 받는다

### 코드 변경 시
```
1. 변경할 내용을 먼저 설명
2. 영향받는 파일 목록 제시
3. 승인 후 구현
4. 테스트 통과 확인
```

### 금지 사항

<!-- 
각 금지 사항의 이유:
- any: 타입 안전성 훼손, 런타임 에러 증가
- console.log: 프로덕션 로그 오염, logger 사용으로 통일
- 테스트 스킵: 회귀 방지 안전망 무력화
-->

- `any` 타입 사용
- `console.log` 직접 사용 (logger 유틸 사용)
- 테스트 없이 기능 구현 완료 처리
- `node_modules`, `dist`, `.env` 파일 직접 수정
- 다른 패키지의 내부 구현에 직접 의존

## 명령어 참조

### 개발 환경
```bash
# 의존성 설치
pnpm install

# 전체 개발 서버 실행
pnpm dev

# 특정 패키지만 실행
pnpm --filter client dev
pnpm --filter server dev
```

### 테스트
```bash
# 전체 테스트
pnpm test

# 특정 패키지 테스트
pnpm --filter server test

# 감시 모드
pnpm --filter server test:watch

# 커버리지
pnpm test:coverage
```

### 빌드 및 배포
```bash
# 타입 체크
pnpm typecheck

# 린트
pnpm lint

# 전체 빌드
pnpm build
```

### 데이터베이스
```bash
# Prisma 마이그레이션 생성
pnpm --filter server prisma migrate dev --name <migration_name>

# Prisma 클라이언트 생성
pnpm --filter server prisma generate

# DB 시드
pnpm --filter server prisma db seed
```

## 파일 네이밍 규칙

| 유형 | 규칙 | 예시 |
|------|------|------|
| 컴포넌트 | PascalCase | `TodoItem.tsx` |
| 훅 | camelCase, use 접두사 | `useTodos.ts` |
| 유틸리티 | camelCase | `formatDate.ts` |
| 테스트 | 대상파일.test.ts(x) | `TodoItem.test.tsx` |
| 타입 정의 | camelCase 또는 types.ts | `todo.types.ts` |
| 상수 | camelCase 또는 constants.ts | `api.constants.ts` |

## 코딩 컨벤션

### TypeScript
```typescript
// ✅ Good: 명시적 타입, 인터페이스 사용
interface Todo {
  id: string;
  title: string;
  completed: boolean;
}

function createTodo(input: CreateTodoInput): Promise<Todo> {
  // ...
}

// ❌ Bad: any 사용, 암시적 타입
function createTodo(input: any): any {
  // ...
}
```

### React 컴포넌트
```typescript
// ✅ Good: Props 타입 정의, 함수형 컴포넌트
interface TodoItemProps {
  todo: Todo;
  onToggle: (id: string) => void;
  onDelete: (id: string) => void;
}

export function TodoItem({ todo, onToggle, onDelete }: TodoItemProps) {
  return (
    // ...
  );
}

// ❌ Bad: Props 타입 없음, default export만 사용
export default function TodoItem(props) {
  // ...
}
```

### API 응답 형식
```typescript
// 성공 응답
interface SuccessResponse<T> {
  data: T;
  meta?: {
    total?: number;
    page?: number;
    limit?: number;
  };
}

// 에러 응답
interface ErrorResponse {
  error: {
    code: string;
    message: string;
    details?: Record<string, unknown>;
  };
}
```

## 작업 컨텍스트

### 현재 진행 중

<!-- 작업 진행에 따라 업데이트 -->

- **Phase 1**: 백엔드 API 개발
    - [x] Prisma 스키마 정의
    - [x] CRUD API 테스트 작성
    - [ ] API 구현 (진행 중)
    - [ ] 에러 핸들링

### 다음 작업

- **Phase 2**: 프론트엔드 개발
    - UI 컴포넌트 구현
    - API 연동
    - 상태 관리

### 보류/제외

- 사용자 인증 (v2에서 구현 예정)
- 실시간 동기화 (범위 외)

## 응답 스타일

### 언어
- 한국어로 응답
- 코드 주석은 영어

### 설명 방식
- 코드 변경 시 **왜** 이렇게 하는지 간단히 설명
- 여러 방법이 있을 때 선택지와 트레이드오프 제시
- 긴 코드는 섹션별로 나눠서 설명

### 코드 제시 방식
- 전체 파일보다 변경 부분 위주로 제시
- 새 파일은 전체 코드 제시
- 기존 파일 수정 시 변경 전/후 비교 또는 diff 형식

## 참조 문서

| 문서 | 위치 | 용도 |
|------|------|------|
| 요구사항 | `docs/REQUIREMENTS.md` | 상세 기능/기술 요구사항 |
| PRD | `docs/PRD.md` | 제품 요구사항, 사용자 스토리 |
| TRD | `docs/TRD.md` | 기술 설계, API 명세 |
| API 문서 | `docs/api/` | OpenAPI 스펙 |

## 트러블슈팅 가이드

<details>
<summary>🔧 자주 발생하는 문제</summary>

### pnpm install 실패
```bash
# node_modules 삭제 후 재설치
rm -rf node_modules packages/*/node_modules
pnpm install
```

### Prisma 클라이언트 타입 에러
```bash
# Prisma 클라이언트 재생성
pnpm --filter server prisma generate
```

### 포트 충돌
- 클라이언트: 3000
- 서버: 4000
- PostgreSQL: 5432
```bash
# 포트 사용 확인
lsof -i :3000
```

</details>

