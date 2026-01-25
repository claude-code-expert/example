---
name: test-driven-development
description: TDD 방법론 적용. 기능 구현, 버그 수정, 리팩토링 전에 사용. React/TypeScript 프로젝트에서 테스트 먼저 작성.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Test-Driven Development

테스트 먼저. 실패 확인. 최소 코드로 통과.

**핵심 원칙:** 테스트가 실패하는 것을 보지 않았다면, 그 테스트가 올바른 것을 검증하는지 알 수 없다.

## 이 Skill을 사용할 때

- 새 기능 구현
- 버그 수정
- 리팩토링
- React 컴포넌트 개발
- API 함수 작성

**예외 (사용자 확인 필요):**
- 일회용 프로토타입
- 설정 파일 수정

## Instructions

### 철칙

```
실패하는 테스트 없이 프로덕션 코드를 작성하지 않는다.
```

테스트 전에 코드를 작성했다면? **삭제하고 처음부터.**

### RED-GREEN-REFACTOR 사이클

```
  ┌─────────┐      ┌─────────┐      ┌───────────┐
  │   RED   │ ───→ │  GREEN  │ ───→ │ REFACTOR  │
  │ 실패하는  │      │ 최소한의 │        │   정리    │
  │ 테스트    │      │  코드    │      │           │
  └─────────┘      └─────────┘      └───────────┘
       ↑                                   │
       └───────────────────────────────────┘
```

**1. RED - 실패하는 테스트 작성**
```bash
npm test -- --watch  # 테스트 워치 모드 실행
```
- 테스트 하나 작성
- 실행하여 **실패 확인** (필수)
- 실패 메시지가 예상대로인지 확인

**2. GREEN - 최소 코드 작성**
- 테스트를 통과시키는 **가장 단순한** 코드
- 과도한 설계 금지 (YAGNI)
- **통과 확인** (필수)

**3. REFACTOR - 정리**
- 중복 제거, 네이밍 개선
- 테스트는 계속 통과 상태 유지
- 동작 변경 금지

### 위험 신호 - 즉시 중단

| 신호 | 대응 |
|------|------|
| 테스트 전에 코드 작성 | 삭제 후 재시작 |
| 테스트가 바로 통과 | 테스트가 잘못됨, 수정 |
| "이번만 생략" | 합리화, TDD로 복귀 |
| 여러 기능 한 번에 | 하나만 남기고 주석 처리 |

### 테스트 파일 위치 규칙

```
src/
├── components/
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.test.tsx    # 컴포넌트 테스트
│   │   └── index.ts
├── hooks/
│   ├── useAuth.ts
│   └── useAuth.test.ts        # 훅 테스트
├── utils/
│   ├── validation.ts
│   └── validation.test.ts     # 유틸 테스트
└── services/
    ├── api.ts
    └── api.test.ts            # API 테스트
```

### 완료 체크리스트

- [ ] 각 테스트 실패 확인함
- [ ] 최소 코드로 통과시킴
- [ ] 모든 테스트 통과
- [ ] 타입 에러 없음 (`npm run type-check`)
- [ ] 린트 통과 (`npm run lint`)

## Examples

### 예시 1: 유틸 함수 - 이메일 검증

**RED:**
```typescript
// src/utils/validation.test.ts
import { validateEmail } from './validation';

describe('validateEmail', () => {
  test('빈 이메일을 거부한다', () => {
    expect(() => validateEmail('')).toThrow('이메일은 필수입니다');
  });

  test('유효하지 않은 형식을 거부한다', () => {
    expect(() => validateEmail('invalid')).toThrow('이메일 형식이 올바르지 않습니다');
  });

  test('유효한 이메일을 허용한다', () => {
    expect(validateEmail('user@example.com')).toBe('user@example.com');
  });
});
```

```bash
$ npm test validation
FAIL  src/utils/validation.test.ts
  ● validateEmail › 빈 이메일을 거부한다
    Cannot find module './validation'
```

**GREEN:**
```typescript
// src/utils/validation.ts
export function validateEmail(email: string): string {
  if (!email) {
    throw new Error('이메일은 필수입니다');
  }
  
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    throw new Error('이메일 형식이 올바르지 않습니다');
  }
  
  return email;
}
```

```bash
$ npm test validation
PASS  src/utils/validation.test.ts
  ✓ 빈 이메일을 거부한다
  ✓ 유효하지 않은 형식을 거부한다
  ✓ 유효한 이메일을 허용한다
```

### 예시 2: React 컴포넌트 - 버튼

**RED:**
```typescript
// src/components/Button/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  test('children을 렌더링한다', () => {
    render(<Button>클릭</Button>);
    expect(screen.getByRole('button', { name: '클릭' })).toBeInTheDocument();
  });

  test('클릭 시 onClick을 호출한다', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>클릭</Button>);
    
    fireEvent.click(screen.getByRole('button'));
    
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  test('disabled 상태에서 클릭해도 onClick을 호출하지 않는다', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick} disabled>클릭</Button>);
    
    fireEvent.click(screen.getByRole('button'));
    
    expect(handleClick).not.toHaveBeenCalled();
  });

  test('loading 상태에서 스피너를 표시한다', () => {
    render(<Button loading>클릭</Button>);
    
    expect(screen.getByRole('button')).toBeDisabled();
    expect(screen.getByTestId('spinner')).toBeInTheDocument();
  });
});
```

```bash
$ npm test Button
FAIL  src/components/Button/Button.test.tsx
  ● Button › children을 렌더링한다
    Cannot find module './Button'
```

**GREEN:**
```typescript
// src/components/Button/Button.tsx
import React from 'react';

interface ButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  disabled?: boolean;
  loading?: boolean;
}

export function Button({ 
  children, 
  onClick, 
  disabled = false, 
  loading = false 
}: ButtonProps) {
  const isDisabled = disabled || loading;

  return (
    <button
      type="button"
      onClick={isDisabled ? undefined : onClick}
      disabled={isDisabled}
    >
      {loading && <span data-testid="spinner">⏳</span>}
      {children}
    </button>
  );
}
```

```bash
$ npm test Button
PASS  src/components/Button/Button.test.tsx
  ✓ children을 렌더링한다
  ✓ 클릭 시 onClick을 호출한다
  ✓ disabled 상태에서 클릭해도 onClick을 호출하지 않는다
  ✓ loading 상태에서 스피너를 표시한다
```

**REFACTOR:**
```typescript
// src/components/Button/Button.tsx - 스타일과 variant 추가
import React from 'react';
import { Spinner } from '../Spinner';
import styles from './Button.module.css';

interface ButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  disabled?: boolean;
  loading?: boolean;
  variant?: 'primary' | 'secondary';
}

export function Button({ 
  children, 
  onClick, 
  disabled = false, 
  loading = false,
  variant = 'primary'
}: ButtonProps) {
  const isDisabled = disabled || loading;

  return (
    <button
      type="button"
      className={styles[variant]}
      onClick={isDisabled ? undefined : onClick}
      disabled={isDisabled}
    >
      {loading && <Spinner data-testid="spinner" />}
      {children}
    </button>
  );
}
```

### 예시 3: Custom Hook - useCounter

**RED:**
```typescript
// src/hooks/useCounter.test.ts
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  test('초기값으로 시작한다', () => {
    const { result } = renderHook(() => useCounter(10));
    expect(result.current.count).toBe(10);
  });

  test('increment는 1 증가시킨다', () => {
    const { result } = renderHook(() => useCounter(0));
    
    act(() => {
      result.current.increment();
    });
    
    expect(result.current.count).toBe(1);
  });

  test('decrement는 1 감소시킨다', () => {
    const { result } = renderHook(() => useCounter(10));
    
    act(() => {
      result.current.decrement();
    });
    
    expect(result.current.count).toBe(9);
  });

  test('reset은 초기값으로 되돌린다', () => {
    const { result } = renderHook(() => useCounter(5));
    
    act(() => {
      result.current.increment();
      result.current.increment();
      result.current.reset();
    });
    
    expect(result.current.count).toBe(5);
  });
});
```

**GREEN:**
```typescript
// src/hooks/useCounter.ts
import { useState, useCallback } from 'react';

export function useCounter(initialValue: number = 0) {
  const [count, setCount] = useState(initialValue);

  const increment = useCallback(() => setCount(c => c + 1), []);
  const decrement = useCallback(() => setCount(c => c - 1), []);
  const reset = useCallback(() => setCount(initialValue), [initialValue]);

  return { count, increment, decrement, reset };
}
```

### 예시 4: API 서비스 - 비동기 테스트

**RED:**
```typescript
// src/services/userApi.test.ts
import { fetchUser } from './userApi';

global.fetch = jest.fn();

describe('fetchUser', () => {
  beforeEach(() => {
    jest.resetAllMocks();
  });

  test('사용자 정보를 반환한다', async () => {
    const mockUser = { id: 1, name: 'John' };
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: async () => mockUser,
    });

    const user = await fetchUser(1);

    expect(user).toEqual(mockUser);
    expect(fetch).toHaveBeenCalledWith('/api/users/1');
  });

  test('API 오류 시 예외를 던진다', async () => {
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: false,
      status: 404,
    });

    await expect(fetchUser(999)).rejects.toThrow('사용자를 찾을 수 없습니다');
  });
});
```

**GREEN:**
```typescript
// src/services/userApi.ts
interface User {
  id: number;
  name: string;
}

export async function fetchUser(id: number): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  
  if (!response.ok) {
    throw new Error('사용자를 찾을 수 없습니다');
  }
  
  return response.json();
}
```
