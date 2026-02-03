# CLAUDE.local.md 샘플

> 이 파일은 개인 설정용으로, `.gitignore`에 추가하여 커밋에서 제외합니다.
> 팀 공유가 필요한 내용은 `CLAUDE.md`에 작성하세요.

## 내 개발 환경

- OS: macOS Sonoma
- IDE: VS Code / Cursor
- Node.js: v20.11.0 (nvm 사용)
- 터미널: iTerm2 + zsh

## 개인 선호 설정

- 코드 설명은 한국어로 해줘
- 커밋 메시지는 영어로 작성
- 테스트 실행 전 항상 lint 먼저 실행
- 긴 설명보다 코드 예시 위주로 답변

## 로컬 경로 정보

- 프로젝트 경로: `~/projects/example`
- 로컬 DB: `postgresql://localhost:5432/example_dev`
- 환경변수 파일: `.env.local` 사용 중

## 자주 사용하는 명령어

```bash
# 개발 서버 실행
pnpm dev

# 테스트 (watch 모드)
pnpm test:watch

# DB 마이그레이션
pnpm prisma migrate dev
```

## 현재 작업 컨텍스트

- 진행 중인 브랜치: `feature/user-auth`
- 관련 이슈: #42, #45
- 담당 영역: 백엔드 API

## 개인 메모

- `src/lib/auth.ts` 리팩토링 필요
- 다음 스프린트에서 캐싱 레이어 추가 예정
- 성능 테스트는 금요일에 진행

---

## 사용법

1. 이 파일을 프로젝트 루트에 `CLAUDE.local.md`로 복사
2. `.gitignore`에 `CLAUDE.local.md` 추가
3. 본인 환경에 맞게 내용 수정
