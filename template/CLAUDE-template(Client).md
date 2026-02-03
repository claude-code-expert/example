# CLAUDE.md - TODO Client

<!-- 
packages/client 전용 설정
루트 CLAUDE.md를 상속하며, 클라이언트 특화 규칙을 정의
-->

## 패키지 개요

Next.js 14 기반 프론트엔드 애플리케이션.
App Router와 React Server Components를 활용한다.

## 디렉토리 구조
```
packages/client/
├── src/
│   ├── app/                 # Next.js App Router
│   │   ├── layout.tsx       # 루트 레이아웃
│   │   ├── page.tsx         # 홈 페이지
│   │   └── todos/           # TODO 관련 페이지
│   ├── components/
│   │   ├── ui/              # 범용 UI (Button, Input 등)
│   │   └── todo/            # TODO 도메인 컴포넌트
│   ├── hooks/               # 커스텀 훅
│   ├── lib/                 # 유틸리티, API 클라이언트
│   ├── styles/              # 전역 스타일
│   └── types/               # 로컬 타입 (shared 외)
├── public/                  # 정적 파일
└── __tests__/               # 테스트 파일
```

## 기술 스택 (클라이언트)

| 기술 | 용도 | 비고 |
|------|------|------|
| Next.js 14 | 프레임워크 | App Router 사용 |
| React 18 | UI 라이브러리 | |
| TanStack Query | 서버 상태 관리 | v5 |
| Tailwind CSS | 스타일링 | |
| React Hook Form | 폼 관리 | Zod 연동 |
| Zod | 런타임 검증 | shared에서 스키마 공유 |

## 컴포넌트 규칙

### 컴포넌트 분류
```
components/
├── ui/           # 프레젠테이션 컴포넌트 (상태 없음)
│   ├── Button.tsx
│   ├── Input.tsx
│   └── index.ts  # 배럴 export
└── todo/         # 도메인 컴포넌트 (비즈니스 로직 포함)
    ├── TodoList.tsx
    ├── TodoItem.tsx
    └── index.ts
```

### 컴포넌트 작성 패턴
```typescript
// ✅ Good: 명확한 Props, forwardRef 지원, 합성 가능

import { forwardRef, type ComponentPropsWithoutRef } from 'react';
import { cn } from '@/lib/utils';

interface ButtonProps extends ComponentPropsWithoutRef<'button'> {
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'primary', size = 'md', isLoading, children, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={cn(
          'rounded-md font-medium transition-colors',
          variantStyles[variant],
          sizeStyles[size],
          className
        )}
        disabled={isLoading || props.disabled}
        {...props}
      >
        {isLoading ? <Spinner /> : children}
      </button>
    );
  }
);

Button.displayName = 'Button';
```

### 훅 작성 패턴
```typescript
// ✅ Good: 단일 책임, 반환 타입 명시, 에러 처리

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { todoApi } from '@/lib/api';
import type { Todo, CreateTodoInput } from '@todo-app/shared';

export function useTodos(filter?: 'all' | 'active' | 'completed') {
  return useQuery({
    queryKey: ['todos', filter],
    queryFn: () => todoApi.getAll(filter),
  });
}

export function useCreateTodo() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: CreateTodoInput) => todoApi.create(input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['todos'] });
    },
    onError: (error) => {
      // 에러 토스트 표시
      console.error('Failed to create todo:', error);
    },
  });
}
```

## 스타일링 규칙

### Tailwind 사용 원칙
```typescript
// ✅ Good: 유틸리티 클래스, cn() 으로 조건부 스타일

import { cn } from '@/lib/utils';

<div className={cn(
  'flex items-center gap-2 p-4 rounded-lg',
  completed && 'opacity-50 line-through',
  className
)}>

// ❌ Bad: 인라인 스타일, CSS-in-JS

<div style={{ display: 'flex', opacity: completed ? 0.5 : 1 }}>
```

### 반응형 디자인
```typescript
// 모바일 퍼스트 접근
<div className="
  flex flex-col gap-2        // 모바일 기본
  sm:flex-row sm:gap-4       // 640px 이상
  lg:gap-6                   // 1024px 이상
">
```

## API 연동

### API 클라이언트 구조
```typescript
// lib/api/client.ts
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000';

export async function apiClient<T>(
  endpoint: string,
  options?: RequestInit
): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
    ...options,
  });

  if (!response.ok) {
    const error = await response.json();
    throw new ApiError(error.error.code, error.error.message);
  }

  return response.json();
}

// lib/api/todo.ts
export const todoApi = {
  getAll: (filter?: string) => 
    apiClient<{ data: Todo[] }>(`/api/todos${filter ? `?completed=${filter === 'completed'}` : ''}`),
  
  create: (input: CreateTodoInput) =>
    apiClient<{ data: Todo }>('/api/todos', {
      method: 'POST',
      body: JSON.stringify(input),
    }),
  
  // ...
};
```

## 테스트 규칙

### 컴포넌트 테스트
```typescript
// ✅ Good: 사용자 관점 테스트, 접근성 쿼리 사용

import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { TodoItem } from './TodoItem';

describe('TodoItem', () => {
  const mockTodo = {
    id: '1',
    title: '테스트 할 일',
    completed: false,
  };

  it('할 일 제목이 표시되어야 한다', () => {
    render(<TodoItem todo={mockTodo} onToggle={jest.fn()} onDelete={jest.fn()} />);
    
    expect(screen.getByText('테스트 할 일')).toBeInTheDocument();
  });

  it('체크박스 클릭 시 onToggle이 호출되어야 한다', async () => {
    const onToggle = jest.fn();
    const user = userEvent.setup();
    
    render(<TodoItem todo={mockTodo} onToggle={onToggle} onDelete={jest.fn()} />);
    
    await user.click(screen.getByRole('checkbox'));
    
    expect(onToggle).toHaveBeenCalledWith('1');
  });

  it('완료된 할 일은 취소선이 표시되어야 한다', () => {
    render(
      <TodoItem 
        todo={{ ...mockTodo, completed: true }} 
        onToggle={jest.fn()} 
        onDelete={jest.fn()} 
      />
    );
    
    expect(screen.getByText('테스트 할 일')).toHaveClass('line-through');
  });
});
```

### 훅 테스트
```typescript
// 훅 테스트는 @testing-library/react의 renderHook 사용
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useTodos } from './useTodos';

const wrapper = ({ children }) => (
  <QueryClientProvider client={new QueryClient()}>
    {children}
  </QueryClientProvider>
);

describe('useTodos', () => {
  it('할 일 목록을 가져와야 한다', async () => {
    const { result } = renderHook(() => useTodos(), { wrapper });

    await waitFor(() => {
      expect(result.current.isSuccess).toBe(true);
    });

    expect(result.current.data).toHaveLength(2);
  });
});
```

## 명령어 (클라이언트)
```bash
# 개발 서버
pnpm dev

# 빌드
pnpm build

# 테스트
pnpm test
pnpm test:watch
pnpm test:coverage

# 린트
pnpm lint

# 타입 체크
pnpm typecheck
```

## 환경 변수
```env
# .env.local
NEXT_PUBLIC_API_URL=http://localhost:4000
```

| 변수 | 필수 | 설명 |
|------|------|------|
| `NEXT_PUBLIC_API_URL` | Y | 백엔드 API URL |

## 주의사항

<!-- 클라이언트 개발 시 자주 실수하는 부분 -->

1. **Server/Client 컴포넌트 구분**
    - 기본은 Server Component
    - 상태, 이벤트 핸들러 필요 시 `'use client'` 명시

2. **이미지 최적화**
    - `<img>` 대신 `next/image` 사용
    - width, height 또는 fill 필수

3. **환경 변수**
    - 클라이언트에서 접근하려면 `NEXT_PUBLIC_` 접두사 필요

4. **shared 패키지 의존**
    - 타입과 스키마는 `@todo-app/shared`에서 import
    - 로컬에 중복 정의 금지