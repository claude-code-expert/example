# Claude Code 슬래시 명령어 레퍼런스

Claude Code REPL에서 사용할 수 있는 슬래시 명령어 목록입니다.
작성일: 2026-06-12 / 버전: 1.2 (Claude Code v2.1.173 기준)
키보드 단축키·CLI 플래그·환경변수까지 포함한 전체 치트시트는 `../guide/claude-code-cheatsheet-ko.md` 참고

---

## 필수 명령어

| 명령어 | 설명 |
|--------|------|
| `/init` | CLAUDE.md로 프로젝트 초기화. 새 프로젝트 시작 시 필수 |
| `/memory` | CLAUDE.md 메모리 파일 편집. 프로젝트 정보 추가/수정 |
| `/model` | AI 모델 선택/변경. `/model sonnet`, `/model opus`, `/model haiku` 등 |
| `/plan` | 계획 모드 진입. 복잡한 작업 전 단계별 계획 수립용 |
| `/compact [지시사항]` | 대화 압축. 컨텍스트 윈도우 확보용. 선택적으로 집중할 내용 지정 가능 |
| `/clear` | 대화 기록 전체 삭제. 새 주제로 전환하거나 깨끗하게 시작할 때 사용 |
| `/help` | 사용법 도움말 표시 |
| `/exit` | REPL 종료 |

## 자주 사용하는 명령어

| 명령어 | 설명 |
|--------|------|
| `/add-dir` | 추가 작업 디렉토리 지정. 모노레포나 여러 폴더에 걸친 프로젝트에서 Claude가 접근할 경로 추가 |
| `/review` | 코드 리뷰 요청. 구현 완료 후 품질 점검용 |
| `/diff` | 변경사항 diff 보기 |
| `/rewind` | 대화 및 코드 변경 되돌리기. Claude 수정이 마음에 안 들 때 원복 |
| `/context` | 컨텍스트 사용량을 색상 그리드로 시각화. 남은 용량 파악에 유용 |
| `/resume [세션]` | 이전 대화 재개. 세션 ID/이름 지정 또는 선택 화면 열기 |
| `/rename <이름>` | 현재 세션 이름 변경. 나중에 `/resume`으로 쉽게 찾기 위함 |
| `/todos` | 현재 프로젝트 TODO 항목 나열 |
| `/pr-comments` | 제거됨 — PR 코멘트 확인은 gh CLI 또는 `/review` 활용 |

## 설정 및 환경

| 명령어 | 설명 |
|--------|------|
| `/config` | 설정 화면(Config 탭) 열기. API 키, 기본 모델, 출력 스타일 등 설정 |
| `/permissions` | 파일 접근, 명령어 실행 등 권한 확인 및 수정 |
| `/hooks` | 훅 설정 관리. 특정 이벤트 발생 시 자동 스크립트 실행 설정 |
| `/output-style [스타일]` | `/config`의 Output style 설정으로 이동됨 |
| `/ide` | IDE 통합 상태 관리. VS Code, JetBrains 등 연동 확인 |
| `/terminal-setup` | Shift+Enter 키 바인딩 설치. VS Code, Alacritty, Zed, Warp 지원 |
| `/theme` | 색상 테마 변경 |
| `/statusline` | Claude Code 상태 표시줄 UI 설정 |
| `/vim` | `/config`의 Editor mode 설정으로 이동됨 |
| `/sandbox` | 샌드박스 모드. 파일시스템/네트워크 격리된 환경에서 안전하게 실행 |
| `/effort` | 추론 강도 조절 (low~max) |
| `/voice` | 음성 입력 |

## 계정 및 사용량

| 명령어 | 설명 |
|--------|------|
| `/login` | Anthropic 계정 전환 |
| `/logout` | Anthropic 계정 로그아웃 |
| `/status` | 버전, 모델, 계정, 연결 상태 확인 (Status 탭) |
| `/usage` (별칭: `/cost`, `/stats`) | 세션 비용·플랜 사용량·활동 통계 통합 표시 |
| `/privacy-settings` | 개인정보 설정 확인 및 수정 |

## 외부 연동

| 명령어 | 설명 |
|--------|------|
| `/mcp` | MCP 서버 연결 및 OAuth 인증 관리. GitHub, Slack, DB 등 외부 서비스 연동 |
| `/install-github-app` | 저장소에 Claude GitHub Actions 설정. CI/CD 통합용 |
| `/agents` | 커스텀 AI 서브에이전트 관리. 특수 작업용 에이전트 생성/수정/삭제 |
| `/plugin` | Claude Code 플러그인 관리 |
| `/skills` | 스킬 목록·관리 |

## 보안 및 진단

| 명령어 | 설명 |
|--------|------|
| `/security-review` | 현재 브랜치 변경사항 보안 리뷰. 배포 전 취약점 점검용 |
| `/doctor` | Claude Code 설치 상태 점검. 문제 발생 시 진단용 |
| `/feedback` (별칭: `/bug`, `/share`) | 피드백·버그 신고·대화 공유. 대화 내용이 Anthropic에 전송되므로 민감 정보 주의 |
| `/release-notes` | Claude Code 릴리스 노트 확인. 새 기능/변경사항 파악 |

## 대화 관리

| 명령어 | 설명 |
|--------|------|
| `/export [파일명]` | 대화 내용 내보내기. 파일명 생략 시 클립보드로 복사 |
| `/tasks` (별칭: `/bashes`) | 백그라운드에서 실행 중인 모든 작업 확인 및 관리 |
| `/branch [이름]` (별칭: `/fork`) | 현재 지점에서 대화 분기 |

## 실험적 기능

| 명령어 | 설명 |
|--------|------|
| `/powerup` | 실험적 기능 |
| `/btw` | 실험적 기능 |

## 원격 세션 (claude.ai 구독자 전용)

| 명령어 | 설명 |
|--------|------|
| `/teleport` | claude.ai 원격 세션 재개. 웹에서 시작한 작업을 터미널에서 이어서 진행 |
| `/remote-env` | 원격 세션 환경 구성 |
