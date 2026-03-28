# Testing Rules
- CLAUDE.md 에서 참조하는 파일 (.claude/rules/ 하위에 위치)
## Stack
- Unit / Integration: Vitest
- E2E: Playwright
- Component: React Testing Library

## File Location
- Unit tests: co-located with source — `src/lib/utils.test.ts`
- E2E tests: `tests/e2e/*.spec.ts`
- Test fixtures / factories: `tests/fixtures/`

## What to Test
- Test behavior, not implementation details
- Focus on public API (exported functions, component props, route responses)
- Do not test internal private functions directly — test them through the public surface
- Cover: happy path, edge cases (empty, null, max), error states

## What NOT to Test
- Third-party library internals
- Trivial getters/setters with no logic
- Generated files (migrations, type stubs)

## Writing Tests

### Unit Tests (Vitest)
```ts
import { describe, it, expect } from 'vitest'
import { formatCurrency } from './format'

describe('formatCurrency', () => {
  it('formats positive amount in KRW', () => {
    expect(formatCurrency(1000, 'KRW')).toBe('₩1,000')
  })

  it('handles zero', () => {
    expect(formatCurrency(0, 'KRW')).toBe('₩0')
  })

  it('throws on negative amount', () => {
    expect(() => formatCurrency(-1, 'KRW')).toThrow('Amount must be non-negative')
  })
})
```

### Component Tests (React Testing Library)
```tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { UserCard } from './UserCard'

it('shows user name and triggers edit on button click', async () => {
  const onEdit = vi.fn()
  render(<UserCard name="Alice" onEdit={onEdit} />)

  expect(screen.getByText('Alice')).toBeInTheDocument()

  await userEvent.click(screen.getByRole('button', { name: /edit/i }))
  expect(onEdit).toHaveBeenCalledOnce()
})
```

### DB Tests
- Use a separate test database (`DATABASE_URL_TEST` env var)
- Wrap each test in a transaction and rollback after
- Never run DB tests against production

## Running Tests
```bash
npm run test              # run all unit tests (watch mode)
npm run test -- --run     # single run (CI mode)
npm run test:e2e          # Playwright E2E
npm run test:coverage     # coverage report
```

## Coverage Targets
- Statements: 80%+
- Functions: 80%+
- Branches: 70%+
- Do not chase 100% — test the things that matter