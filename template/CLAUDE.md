# [프로젝트명]
---
## ⚠️ MANDATORY — 모든 응답 전 반드시 확인
### 가급적 영문으로 작성하는 걸 권고 (토근 절약)
1. **응답 형식**: 모든 작업 완료 시 반드시 Korean summary로 마무리
   - 무엇을 변경했는지
   - 왜 그렇게 했는지
   - 주의할 점이 있는지

2. **조사 원칙**: 경로, 설정값, 코드 동작에 대해 답하기 전 반드시 소스 코드를 먼저 읽을 것. 추측으로 답변 금지.


## Language Policy

- Internal reasoning and planning: English
- Code and technical artifacts: English (variable names, comments, logs, error messages)
- Git commits: English, follow Conventional Commits (e.g., feat:, fix:, refactor:)
- User-facing responses: Korean (한국어)
  - Task summaries, explanations, and clarifying questions in Korean
  - When reporting errors or issues, describe the problem in Korean but keep the original error message in English

## Working Relationship
- You can push back on ideas - this can lead to better outcomes
- Ask clarifying questions before making architectural changes

## About This Project
[프로젝트에 대한 한 줄 설명]
예: "This is a Next.js e-commerce app with Stripe integration"

## Tech Stack
- Framework: [프레임워크명]
- Language: [언어 및 버전]
- Database: [데이터베이스]
- Other: [기타 주요 기술]

## Project Structure
- `src/` - Source code
- `tests/` - Test files
- `docs/` - Documentation

## Commands
- `npm run dev` - Start development server
- `npm run test` - Run tests
- `npm run build` - Build for production

## Code Style
- [코드 스타일 규칙 1]
- [코드 스타일 규칙 2]

## Git Workflow
- Branch naming: `feature/`, `fix/`, `docs/`
- Commit message format: [규칙 설명]
- Always run tests before committing

## Important Notes
- [프로젝트 특이사항이나 주의점]
```

### 메모리 파일 위치와 계층 구조

공식 문서에 따르면 Claude Code는 다음 위치에서 메모리 파일을 읽습니다:
```
your-project/
├── CLAUDE.md              # 프로젝트 루트 (팀 공유용)
├── CLAUDE.local.md        # 개인 설정 (git에서 제외됨)
├── .claude/
│   ├── CLAUDE.md          # 메인 프로젝트 지침
│   └── rules/
│       ├── code-style.md  # 코드 스타일 가이드라인
│       ├── testing.md     # 테스트 규칙
│       └── security.md    # 보안 요구사항
```

### 주요 작성 원칙 (공식 권장사항)

1. **간결하게 유지**: 모든 내용이 컨텍스트 윈도우를 차지하므로 필수적인 내용만 포함 200 라인 이내. 
2. **구체적으로 작성**: "Format code properly" 대신 "Use 2-space indentation" 처럼 명확하게
3. **구조화**: 마크다운 헤더와 불릿 포인트로 관련 내용을 그룹화
4. **정기적 검토**: 프로젝트가 발전함에 따라 업데이트하여 최신 상태 유지
5. **/init으로 시작**: `claude` 실행 후 `/init` 명령으로 기본 파일 생성, 이후 불필요한 내용 삭제
6. 내용이 길어질 경우 @로 include  해야 할 md와 경로를 참조해야 할 md 를 백틱(``) 으로 표현하여 파일을 분리 

### 빠른 메모리 추가 방법

Claude Code에서 `#` 문자로 시작하면 바로 메모리에 저장할 수 있습니다:
```
# Always use descriptive variable names

# ⛔ NEVER Rules (샘플)

## Guardrails

### Database — Never Without Explicit User Approval
- NEVER run: `DROP TABLE`, `DROP DATABASE`, `TRUNCATE`
- NEVER run `DELETE FROM` without a WHERE clause
- NEVER run `ALTER TABLE DROP` without user permission
- NEVER reset the database while test data exists
- NEVER auto-modify a production database under any circumstance
- Always request explicit user approval before any destructive database operation
- Always confirm a backup exists before deleting data
- Fix issues with SQL modifications before considering a database reset

### Git — Never Without Explicit User Request
- NEVER run: `git push --force`, `git reset --hard`, `git commit --no-verify`
- NEVER run `git commit` unless the user explicitly asks (e.g., "커밋해줘", "commit this")
- NEVER run `git push` unless the user explicitly asks
- If a commit seems necessary after completing work, ask the user first — do not commit automatically

### Dependencies & Libraries
- NEVER run `npm audit fix --force`
- Do not change library versions without a clear reason; after initial setup, request permission before upgrading
- Avoid introducing libraries, frameworks, or languages outside the core stack; if unavoidable, present the rationale and request explicit approval

### File Modifications (기술 스택에 맞도록 수정해서 사용하세요)
- **`src/db/schema.ts`** — confirm with user before editing (schema changes affect migrations)
- **`drizzle.config.ts`, `next.config.ts`** and other core config files — confirm with user before editing
- **`package.json` dependencies** — require user approval before changes
- **`.env.local`** — never create or edit directly; environment variables are managed by the user
- **`migrations/`** — never manually edit files inside; use drizzle-kit only
- **`docs/`** — never delete documentation files; edits are allowed, deletions require user confirmation
