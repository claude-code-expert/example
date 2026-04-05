# Server — packages/server

Express REST API. PostgreSQL via Prisma ORM.

## Commands
- `pnpm dev` — dev server with hot reload (port 4000)
- `pnpm build` — compile TypeScript
- `pnpm start` — run compiled output
- `pnpm test` — Jest (unit + integration)
- `pnpm test:watch` — watch mode
- `pnpm test:coverage` — coverage report
- `pnpm prisma:generate` — regenerate Prisma client (run after schema changes)
- `pnpm prisma:migrate` — run migrations
- `pnpm prisma:studio` — open DB GUI
- `pnpm prisma:seed` — insert seed data

## Architecture (Request flow)
```
Routes → Controllers → Services → Repositories → Database
```
- **Routes**: URL mapping, middleware wiring only — no logic
- **Controllers**: parse request, format response, call next(error) on failure
- **Services**: domain rules, transactions, throws typed errors (NotFoundError etc.)
- **Repositories**: Prisma queries only — no business logic

## Environment Variables
| Var | Required | Default | Description |
|-----|----------|---------|-------------|
| `DATABASE_URL` | Y | — | PostgreSQL connection string |
| `PORT` | N | 4000 | Server port |
| `NODE_ENV` | N | development | Environment |
| `LOG_LEVEL` | N | info | Log level (debug/info/warn/error) |

## Guardrails

### Prisma
- NEVER edit files in `prisma/migrations/` manually — use prisma migrate only
- ALWAYS run `pnpm prisma:generate` after any `schema.prisma` change
- Multi-write operations MUST use `prisma.$transaction()`
- NEVER expose raw Prisma errors to API responses

### Error Handling
- Controllers: always wrap with try-catch, pass to `next(error)`
- Services: throw typed errors from `lib/errors.ts` (NotFoundError, ValidationError, etc.)
- NEVER use `console.log` — use `logger` from `lib/logger.ts`
- NEVER log sensitive data (passwords, tokens, PII)

### Tests
- Integration tests hit real DB — use `beforeEach` with `prisma.todo.deleteMany()`
- Unit tests mock repositories — never mock services directly
- Test file mirrors source path: `src/services/todo.service.ts` → `__tests__/unit/todo.service.test.ts`

@.claude/rules/server-patterns.md