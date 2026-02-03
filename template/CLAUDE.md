# [프로젝트명]

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

1. **간결하게 유지**: 모든 내용이 컨텍스트 윈도우를 차지하므로 필수적인 내용만 포함
2. **구체적으로 작성**: "Format code properly" 대신 "Use 2-space indentation" 처럼 명확하게
3. **구조화**: 마크다운 헤더와 불릿 포인트로 관련 내용을 그룹화
4. **정기적 검토**: 프로젝트가 발전함에 따라 업데이트하여 최신 상태 유지
5. **/init으로 시작**: `claude` 실행 후 `/init` 명령으로 기본 파일 생성, 이후 불필요한 내용 삭제

### 빠른 메모리 추가 방법

Claude Code에서 `#` 문자로 시작하면 바로 메모리에 저장할 수 있습니다:
```
# Always use descriptive variable names