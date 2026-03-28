# Git Workflow Rules
- CLAUDE.md 에서 참조하는 파일 (.claude/rules/ 하위에 위치)
## Branch Naming
```
feature/short-description     # new features
fix/short-description          # bug fixes
refactor/short-description     # refactoring, no behavior change
docs/short-description         # documentation only
chore/short-description        # tooling, config, deps
hotfix/short-description       # urgent prod fixes
```

## Commit Messages (Conventional Commits)
```
<type>(<scope>): <short summary>

[optional body]

[optional footer: BREAKING CHANGE / Closes #issue]
```

### Types
| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code change with no behavior change |
| `perf` | Performance improvement |
| `test` | Adding or fixing tests |
| `docs` | Documentation only |
| `chore` | Build process, tooling, deps |
| `ci` | CI/CD config changes |
| `style` | Formatting, whitespace (no logic change) |

### Examples
```bash
feat(auth): add magic link login via Resend
fix(cart): correct total price when discount applied
refactor(db): extract query helpers to lib/db/queries.ts
docs(api): add JSDoc to all server action exports
chore(deps): upgrade drizzle-orm to 0.38
```

## PR Rules
- PR title = same format as commit message
- Keep PRs small (< 400 lines changed where possible)
- Link related issue: `Closes #123`
- Add screenshots for UI changes
- Self-review before requesting review

## Pre-commit Checklist
- [ ] Tests pass: `npm run test -- --run`
- [ ] Lint passes: `npm run lint`
- [ ] Type check passes: `npm run typecheck`
- [ ] No `console.log` left in production code
- [ ] No commented-out code blocks
- [ ] No hardcoded secrets or credentials

## Merge Strategy
- `main` ← squash merge from feature branches (clean history)
- `main` is always deployable
- No direct commits to `main` except hotfixes (require review)

## Tag / Release
```bash
git tag -a v1.2.0 -m "feat: add checkout flow"
git push origin v1.2.0
```