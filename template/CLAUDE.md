# [ProjectName]

## Project
[One-line description. e.g. "Next.js e-commerce app with Stripe and Supabase."]

- Framework: [e.g. Next.js 15]
- Language: [e.g. TypeScript 5]
- Database: [e.g. Supabase (PostgreSQL) + Drizzle ORM]
- Auth: [e.g. Clerk]
- Other: [e.g. Tailwind CSS, Shadcn/ui, Vercel]

## ⚙️ Meta Rules

**On recurring issues**: Do not simply retry. Always read the relevant source code first, identify the root cause, then respond.

**After session restart**: After `/compact` completes or a new session starts, always re-read this file first to restore the project context.

## Commands
- `npm run dev` — dev server (port 3000)
- `npm run test` — run test suite
- `npm run build` — production build
- `npm run lint` — lint check
- `npm run db:push` — push schema changes (dev only)
- `npm run db:migrate` — run migrations (production)

## Language Rules
- Code, comments, variable names, git commits: **English**
- All responses, summaries, explanations to user: **Korean**
- Error messages: keep original English, describe the cause in Korean

## Investigation Rules
- Read source code before answering. No guessing on paths, configs, or behavior.
- Never claim to have confirmed a fix without actually reading the relevant file.
- When the same bug recurs, do a source-level deep dive — do not patch blindly.

## Guardrails

### Database
- NEVER: `DROP TABLE`, `DROP DATABASE`, `TRUNCATE`, `DELETE FROM` without WHERE
- NEVER: `ALTER TABLE DROP COLUMN` without explicit user approval
- NEVER modify production DB directly under any circumstance
- Always confirm a backup exists before any destructive operation

### Git
- NEVER: `git push --force`, `git reset --hard`, `git commit --no-verify`
- NEVER auto-commit or auto-push — always wait for explicit user request
- If committing seems needed after finishing work, ask first

### Dependencies
- NEVER: `npm audit fix --force`
- Do not upgrade library versions without a clear reason
- Do not introduce new libraries outside the core stack without approval

### Protected Files
- `src/db/schema.ts` — confirm before editing (affects migrations)
- `drizzle.config.ts`, `next.config.ts`, `tailwind.config.ts` — confirm before editing
- `package.json` (deps section) — require user approval
- `.env*` files — never create or edit; user manages all env vars
- `migrations/` — never edit manually; use drizzle-kit only


@.claude/rules/code-style.md

@.claude/rules/testing.md

@.claude/rules/git-workflow.md

### Response Format After Task Completion

After completing a task, always summarize the following in Korean:

1. **What was changed**
2. **Why it was done that way**
3. **Any caveats or things to watch out for**   