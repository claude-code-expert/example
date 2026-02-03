<!--
TRD (Technical Requirements Document)
- 개발팀, 아키텍트 역할의 어떻게 구현할 것인가?를 대상으로 기술 

필수 섹션

1. 기술 개요 (Technical Overview)

- 시스템 아키텍처 다이어그램
- 기술 스택 선정 및 근거


2. 시스템 아키텍처 (System Architecture)

- 컴포넌트 구조
- 데이터 흐름
- 외부 서비스 연동


3. 데이터 모델 (Data Model)

- ERD 또는 스키마 정의
- 관계 설명


4. API 설계 (API Design)

- 엔드포인트 목록
- 요청/응답 형식
- 에러 코드


5. 보안 고려사항 (Security Considerations)
6. 인프라와 배포 (Infrastructure & Deployment)
7. 테스트 전략 (Testing Strategy)

-->

# TRD: TODO 애플리케이션

## 문서 정보
- **버전**: 1.0
- **작성일**: 2025-02-03
- **관련 PRD**: PRD v1.0

---

## 1. 기술 개요

### 1.1 시스템 아키텍처
```
┌─────────────────────────────────────────────────────────┐
│                        Client                           │
│  ┌───────────────────────────────────────────────────┐  │
│  │           React + TypeScript + Tailwind           │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────────────┐   │  │
│  │  │ TodoList│  │TodoItem │  │ TodoInput       │   │  │
│  │  └─────────┘  └─────────┘  └─────────────────┘   │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────┬───────────────────────────────┘
                          │ HTTPS
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Next.js Server                       │
│  ┌───────────────────────────────────────────────────┐  │
│  │                  API Routes                        │  │
│  │  /api/todos (GET, POST)                           │  │
│  │  /api/todos/[id] (GET, PATCH, DELETE)             │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │                  Prisma ORM                        │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    PostgreSQL                           │
│                   (Railway/Supabase)                    │
└─────────────────────────────────────────────────────────┘
```

### 1.2 기술 스택

| 레이어 | 기술 | 버전 | 선정 이유 |
|--------|------|------|----------|
| Frontend | React | 18.x | 컴포넌트 기반, 풍부한 생태계 |
| Language | TypeScript | 5.x | 타입 안전성, AI 도구와의 호환성 |
| Styling | Tailwind CSS | 3.x | 유틸리티 기반, 빠른 개발 |
| Framework | Next.js | 14.x | API Routes 통합, Vercel 배포 용이 |
| ORM | Prisma | 5.x | 타입 안전한 쿼리, 마이그레이션 |
| Database | PostgreSQL | 15.x | 안정성, Railway 지원 |
| Testing | Jest + RTL | 29.x | 표준 테스트 도구 |

---

## 2. 데이터 모델

### 2.1 ERD
```
┌────────────────────────────────┐
│            Todo                │
├────────────────────────────────┤
│ id          UUID       PK      │
│ title       VARCHAR(100) NOT NULL │
│ completed   BOOLEAN    DEFAULT false │
│ createdAt   TIMESTAMP  DEFAULT now() │
│ updatedAt   TIMESTAMP  AUTO UPDATE │
└────────────────────────────────┘
```

### 2.2 Prisma Schema
```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Todo {
  id        String   @id @default(uuid())
  title     String   @db.VarChar(100)
  completed Boolean  @default(false)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@map("todos")
}
```

### 2.3 인덱스 전략

| 인덱스 | 컬럼 | 용도 |
|--------|------|------|
| PRIMARY | id | 기본 조회 |
| idx_completed | completed | 필터링 쿼리 최적화 |
| idx_created_at | createdAt | 정렬 쿼리 최적화 |

---

## 3. API 설계

### 3.1 기본 규칙

- Base URL: `/api`
- 응답 형식: JSON
- 날짜 형식: ISO 8601 (YYYY-MM-DDTHH:mm:ss.sssZ)
- 에러 응답 형식 통일

### 3.2 엔드포인트 상세

#### GET /api/todos
전체 TODO 목록 조회

**Query Parameters:**
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| completed | boolean | N | 완료 상태로 필터링 |
| limit | number | N | 반환 개수 제한 (기본: 100) |
| offset | number | N | 페이지네이션 오프셋 |

**Response 200:**
```json
{
  "data": [
    {
      "id": "uuid",
      "title": "할 일 제목",
      "completed": false,
      "createdAt": "2025-02-03T10:00:00.000Z",
      "updatedAt": "2025-02-03T10:00:00.000Z"
    }
  ],
  "meta": {
    "total": 42,
    "limit": 100,
    "offset": 0
  }
}
```

#### POST /api/todos
새 TODO 생성

**Request Body:**
```json
{
  "title": "새로운 할 일"  // 필수, 1-100자
}
```

**Response 201:**
```json
{
  "data": {
    "id": "uuid",
    "title": "새로운 할 일",
    "completed": false,
    "createdAt": "2025-02-03T10:00:00.000Z",
    "updatedAt": "2025-02-03T10:00:00.000Z"
  }
}
```

#### GET /api/todos/:id
특정 TODO 조회

**Response 200:**
```json
{
  "data": {
    "id": "uuid",
    "title": "할 일 제목",
    "completed": false,
    "createdAt": "2025-02-03T10:00:00.000Z",
    "updatedAt": "2025-02-03T10:00:00.000Z"
  }
}
```

#### PATCH /api/todos/:id
TODO 수정

**Request Body:**
```json
{
  "title": "수정된 제목",    // 선택
  "completed": true          // 선택
}
```

**Response 200:** (생성과 동일한 형식)

#### DELETE /api/todos/:id
TODO 삭제

**Response 204:** No Content

### 3.3 에러 응답
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Title is required",
    "details": {
      "field": "title",
      "constraint": "required"
    }
  }
}
```

| HTTP 상태 | 코드 | 설명 |
|----------|------|------|
| 400 | VALIDATION_ERROR | 요청 데이터 유효성 검증 실패 |
| 404 | NOT_FOUND | 리소스를 찾을 수 없음 |
| 500 | INTERNAL_ERROR | 서버 내부 오류 |

---

## 4. 프론트엔드 아키텍처

### 4.1 디렉토리 구조
```
src/
├── app/                    # Next.js App Router
│   ├── layout.tsx
│   ├── page.tsx
│   └── api/
│       └── todos/
│           ├── route.ts
│           └── [id]/
│               └── route.ts
├── components/
│   ├── ui/                 # 재사용 가능한 UI 컴포넌트
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   └── Checkbox.tsx
│   └── todo/               # TODO 도메인 컴포넌트
│       ├── TodoList.tsx
│       ├── TodoItem.tsx
│       ├── TodoInput.tsx
│       └── TodoFilter.tsx
├── hooks/
│   └── useTodos.ts         # TODO CRUD 커스텀 훅
├── lib/
│   ├── api.ts              # API 클라이언트
│   └── prisma.ts           # Prisma 클라이언트 인스턴스
├── types/
│   └── todo.ts             # 타입 정의
└── __tests__/              # 테스트 파일
```

### 4.2 컴포넌트 계층
```
App (page.tsx)
└── TodoContainer
    ├── TodoInput
    ├── TodoFilter
    └── TodoList
        └── TodoItem (반복)
            ├── Checkbox
            ├── Title (편집 가능)
            └── DeleteButton
```

### 4.3 상태 관리

React Query (TanStack Query)를 사용하여 서버 상태 관리:
```typescript
// hooks/useTodos.ts
export function useTodos(filter?: 'all' | 'active' | 'completed') {
  return useQuery({
    queryKey: ['todos', filter],
    queryFn: () => fetchTodos(filter),
  });
}

export function useCreateTodo() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: createTodo,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['todos'] });
    },
  });
}
```

---

## 5. 보안 고려사항

### 5.1 입력 검증
- 서버 사이드에서 모든 입력 검증 수행
- Zod 스키마를 사용한 런타임 타입 검증
```typescript
import { z } from 'zod';

export const createTodoSchema = z.object({
  title: z.string().min(1).max(100).trim(),
});

export const updateTodoSchema = z.object({
  title: z.string().min(1).max(100).trim().optional(),
  completed: z.boolean().optional(),
});
```

### 5.2 SQL Injection 방지
- Prisma ORM 사용으로 자동 방어
- Raw 쿼리 사용 금지

### 5.3 XSS 방지
- React의 자동 이스케이핑 활용
- dangerouslySetInnerHTML 사용 금지

---

## 6. 인프라와 배포

### 6.1 배포 환경

| 환경 | 플랫폼 | 용도 |
|------|--------|------|
| Development | Local | 개발 |
| Production | Vercel + Railway | 운영 |

### 6.2 환경 변수
```env
# .env.local (개발)
DATABASE_URL="postgresql://user:pass@localhost:5432/todo_dev"

# Vercel Environment Variables (운영)
DATABASE_URL="postgresql://..."
```

### 6.3 CI/CD 파이프라인
```yaml
# GitHub Actions 워크플로우 개요
main 브랜치 push:
  1. 의존성 설치
  2. 린트 검사
  3. 타입 체크
  4. 테스트 실행
  5. Vercel 자동 배포
```

---

## 7. 테스트 전략

### 7.1 테스트 피라미드
```
         ▲
        /│\        E2E (Playwright)
       / │ \       - 핵심 사용자 플로우 3-5개
      /  │  \
     /───┼───\     Integration
    /    │    \    - API 엔드포인트 테스트
   /     │     \   - 컴포넌트 통합 테스트
  /──────┼──────\  
 /       │       \ Unit
/────────┼────────\- 유틸 함수, 훅 테스트
                   - 개별 컴포넌트 테스트
```

### 7.2 테스트 범위

| 레이어 | 도구 | 커버리지 목표 |
|--------|------|--------------|
| Unit | Jest | > 80% |
| Integration | Jest + Supertest | 주요 API 100% |
| E2E | Playwright | 핵심 플로우 100% |

### 7.3 테스트 파일 네이밍
```
src/
├── components/
│   └── todo/
│       ├── TodoItem.tsx
│       └── TodoItem.test.tsx    # 컴포넌트 테스트
├── hooks/
│   ├── useTodos.ts
│   └── useTodos.test.ts         # 훅 테스트
└── app/
    └── api/
        └── todos/
            ├── route.ts
            └── route.test.ts    # API 테스트
```

---

## 부록: 기술 결정 기록 (ADR)

### ADR-001: Next.js API Routes vs Express 분리

**상태**: 채택

**맥락**: 백엔드를 Express로 분리할지 Next.js API Routes로 통합할지 결정 필요

**결정**: Next.js API Routes 사용

**근거**:
- 배포 단순화 (단일 Vercel 배포)
- 타입 공유 용이
- 학습 목적으로 충분한 복잡도

**결과**:
- 인프라 관리 부담 감소
- Vercel 무료 티어 활용 가능