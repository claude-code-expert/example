# Code Style Rules
- CLAUDE.md 에서 참조하는 파일 (.claude/rules/ 하위에 위치)
## General
- 2-space indentation (no tabs)
- Single quotes for strings; template literals for interpolation
- Trailing commas in multi-line objects and arrays
- Semicolons: omit (prettier handles this)
- Max line length: 100 characters

## TypeScript
- Strict mode enabled (`"strict": true` in tsconfig)
- Prefer `type` over `interface` unless extending is needed
- Never use `any`; use `unknown` + type narrowing instead
- Always type function return values explicitly
- Use `satisfies` operator for config objects

```ts
// Good
const config = {
  port: 3000,
  host: 'localhost',
} satisfies ServerConfig

// Bad
const config: any = { port: 3000 }
```

## React / Next.js
- Use Server Components by default; add `'use client'` only when necessary
- One component per file; file name matches component name
- Co-locate component styles, tests, and types in the same directory
- Prefer named exports over default exports (except page/layout files)
- Use `cn()` utility for conditional class names (clsx + tailwind-merge)

```tsx
// Good
export function UserCard({ userId }: { userId: string }) { ... }

// Bad
export default ({ userId }) => { ... }
```

## File & Directory Naming
- Components: `PascalCase.tsx`
- Utilities / hooks: `camelCase.ts`
- Route segments (Next.js): `kebab-case/`
- Constants: `SCREAMING_SNAKE_CASE`
- Test files: `*.test.ts` or `*.spec.ts` next to the source file

## Imports
- Use absolute imports via `@/` alias (configured in tsconfig)
- Group order: external → internal (`@/`) → relative
- No circular imports; keep dependency direction: `lib → server → client`

```ts
// Good
import { z } from 'zod'
import { db } from '@/lib/db'
import { formatDate } from './utils'
```

## Error Handling
- Never swallow errors silently
- Use typed error classes for domain errors
- In server actions: always return `{ data, error }` shape — never throw to client

```ts
// Good
export async function getUser(id: string): Promise<{ data: User | null; error: string | null }> {
  try {
    const user = await db.query.users.findFirst({ where: eq(users.id, id) })
    return { data: user ?? null, error: null }
  } catch (e) {
    return { data: null, error: 'Failed to fetch user' }
  }
}
```