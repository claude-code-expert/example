# 클라이언트 코드 패턴
- CLAUDE-template(Client).md 에서 참조하는 파일 (.claude/rules/ 하위에 위치)
## UI 컴포넌트 (forwardRef 패턴)

```typescript
import { forwardRef, type ComponentPropsWithoutRef } from 'react'
import { cn } from '@/lib/utils'

interface ButtonProps extends ComponentPropsWithoutRef<'button'> {
  variant?: 'primary' | 'secondary' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  isLoading?: boolean
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'primary', size = 'md', isLoading, children, ...props }, ref) => (
    <button
      ref={ref}
      className={cn('rounded-md font-medium transition-colors', variantStyles[variant], sizeStyles[size], className)}
      disabled={isLoading || props.disabled}
      {...props}
    >
      {isLoading ? <Spinner /> : children}
    </button>
  )
)
Button.displayName = 'Button'
```

## TanStack Query 훅 패턴

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { todoApi } from '@/lib/api'
import type { CreateTodoInput } from '@todo-app/shared'

export function useTodos(filter?: 'all' | 'active' | 'completed') {
  return useQuery({
    queryKey: ['todos', filter],
    queryFn: () => todoApi.getAll(filter),
  })
}

export function useCreateTodo() {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn: (input: CreateTodoInput) => todoApi.create(input),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
  })
}
```

## API 클라이언트

```typescript
// lib/api/client.ts
const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:4000'

export async function apiClient<T>(endpoint: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${API_BASE}${endpoint}`, {
    headers: { 'Content-Type': 'application/json', ...options?.headers },
    ...options,
  })
  if (!res.ok) {
    const err = await res.json()
    throw new ApiError(err.error.code, err.error.message)
  }
  return res.json()
}

// lib/api/todo.ts
export const todoApi = {
  getAll: (filter?: string) =>
    apiClient<{ data: Todo[] }>(`/api/todos${filter ? `?completed=${filter === 'completed'}` : ''}`),
  create: (input: CreateTodoInput) =>
    apiClient<{ data: Todo }>('/api/todos', { method: 'POST', body: JSON.stringify(input) }),
}
```

## 반응형 스타일 (모바일 퍼스트)

```typescript
// Good
<div className={cn(
  'flex flex-col gap-2',       // 모바일 기본
  'sm:flex-row sm:gap-4',      // 640px+
  'lg:gap-6',                  // 1024px+
  completed && 'opacity-50 line-through',
  className
)}>

// Bad
<div style={{ display: 'flex', opacity: completed ? 0.5 : 1 }}>
```

## 컴포넌트 테스트

```typescript
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { TodoItem } from './TodoItem'

const mockTodo = { id: '1', title: '테스트 할 일', completed: false }

describe('TodoItem', () => {
  it('체크박스 클릭 시 onToggle 호출', async () => {
    const onToggle = jest.fn()
    render(<TodoItem todo={mockTodo} onToggle={onToggle} onDelete={jest.fn()} />)
    await userEvent.setup().click(screen.getByRole('checkbox'))
    expect(onToggle).toHaveBeenCalledWith('1')
  })
})
```

## 훅 테스트

```typescript
import { renderHook, waitFor } from '@testing-library/react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { useTodos } from './useTodos'

const wrapper = ({ children }: { children: React.ReactNode }) => (
  <QueryClientProvider client={new QueryClient()}>{children}</QueryClientProvider>
)

it('할 일 목록 페치 성공', async () => {
  const { result } = renderHook(() => useTodos(), { wrapper })
  await waitFor(() => expect(result.current.isSuccess).toBe(true))
})
```