# 코드 스타일 규칙
- CLAUDE-template(Root).md 에서 참조하는 파일 (.claude/rules/ 하위에 위치)

## 파일 네이밍

| 유형 | 규칙 | 예시 |
|------|------|------|
| React 컴포넌트 | PascalCase | `TodoItem.tsx` |
| React 훅 | camelCase, `use` 접두사 | `useTodos.ts` |
| 유틸리티 | camelCase | `formatDate.ts` |
| 상수 | camelCase 또는 `constants.ts` | `api.constants.ts` |
| 타입 | camelCase 또는 `types.ts` | `todo.types.ts` |
| 테스트 | 대상 파일명 + `.test.ts(x)` | `TodoItem.test.tsx` |

## TypeScript

- strict 모드 활성화 (`"strict": true`)
- `any` 금지 — `unknown` + 타입 내로잉 사용
- 함수 반환 타입 명시
- `interface`는 확장이 필요한 경우, 나머지는 `type` 사용
- 설정 객체는 `satisfies` 연산자 활용

```typescript
// Good
type CreateTodoInput = { title: string }

function createTodo(input: CreateTodoInput): Promise<Todo> { ... }

const config = { port: 4000 } satisfies ServerConfig

// Bad
function createTodo(input: any): any { ... }
```

## React / Next.js

- 기본값은 서버 컴포넌트 — `'use client'`는 꼭 필요할 때만
- 파일당 컴포넌트 하나, 파일명 = 컴포넌트명
- named export 사용 (page.tsx, layout.tsx 제외)
- 조건부 클래스명은 `cn()` 헬퍼 사용 (clsx + tailwind-merge)
- Props 타입 항상 명시

```typescript
// Good
interface TodoItemProps {
  todo: Todo
  onToggle: (id: string) => void
}

export function TodoItem({ todo, onToggle }: TodoItemProps) { ... }

// Bad
export default function TodoItem(props) { ... }
```

## API 응답 형식

프로젝트 전반에서 일관되게 사용:

```typescript
// 성공
interface SuccessResponse<T> {
  data: T
  meta?: { total?: number; page?: number; limit?: number }
}

// 에러
interface ErrorResponse {
  error: {
    code: string
    message: string
    details?: Record<string, unknown>
  }
}
```

## Import 순서

```typescript
// 1. 외부 라이브러리
import { useState } from 'react'
import { z } from 'zod'

// 2. 내부 패키지 (@todo-app/*)
import type { Todo } from '@todo-app/shared'

// 3. 절대 경로 (@/)
import { db } from '@/lib/db'

// 4. 상대 경로
import { formatDate } from './utils'
```

## 금지 패턴

```typescript
// 배럴 파일 과도한 사용 금지
// Bad: index.ts에서 모든 것 재-export → 번들 크기 증가
export * from './TodoItem'
export * from './TodoList'
export * from './TodoForm'

// 패키지 내부 직접 의존 금지
// Bad
import { something } from '../../server/src/lib/utils'

// Good
import { something } from '@todo-app/shared'
```