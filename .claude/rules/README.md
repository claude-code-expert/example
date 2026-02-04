<!--
Claude Code Rule 템플릿입니다.
작성일: 2026-01-04
버전: 1.1
-->

# Claude Code Rules 템플릿


이 디렉토리에는 `.claude/rules/`에서 사용할 수 있는 규칙 파일 템플릿이 포함되어 있습니다.

## 파일 목록

| 파일명 | 적용 경로 | 설명 |
|--------|-----------|------|
| `api-routes.md` | `src/api/**/*.ts` | API 개발 규칙 (응답 형식, 에러 처리, 인증) |
| `frontend.md` | `src/components/**/*.tsx`, `src/pages/**/*.tsx` | 프론트엔드 컴포넌트 규칙 |
| `testing.md` | `**/*.test.ts`, `**/*.spec.ts`, `tests/**/*` | 테스트 작성 규칙 (AAA 패턴, Mock 사용) |
| `database.md` | `src/models/**/*.ts`, `prisma/**/*` | 데이터베이스 규칙 (모델 정의, 쿼리 작성) |

## 사용 방법

1. 프로젝트 루트에 `.claude/rules/` 디렉토리 생성:
   ```bash
   mkdir -p .claude/rules
   ```

2. 필요한 규칙 파일을 복사:
   ```bash
   cp api-routes.md .claude/rules/
   cp frontend.md .claude/rules/
   cp testing.md .claude/rules/
   cp database.md .claude/rules/
   ```

3. 프로젝트에 맞게 `paths` 섹션과 규칙 내용을 수정

## 파일 구조

각 규칙 파일은 다음 구조를 따릅니다:

```markdown
---
paths:
  - "적용할/경로/패턴/**/*.ts"
---

# 규칙 제목

## 섹션 1
- 규칙 내용...

## 섹션 2
- 규칙 내용...
```

- **paths**: glob 패턴으로 규칙이 적용될 파일 경로 지정
- **본문**: Claude가 따라야 할 구체적인 지침

## 참고사항

- `paths`가 없는 규칙 파일은 모든 파일에 무조건 적용됩니다.
- 여러 경로 패턴을 지정할 수 있습니다.
- glob 패턴 예시:
  - `**/*.ts` - 모든 하위 디렉토리의 .ts 파일
  - `src/api/**/*.ts` - src/api 하위의 모든 .ts 파일
  - `*.test.ts` - 현재 디렉토리의 .test.ts 파일만
