# Claude Code — 미공개 예정 기능 분석

> 📘 [github.com/claude-code-expert](https://github.com/claude-code-expert) — 클로드 코드 마스터 (한빛미디어 서적 공식 리포지토리) 
> ☕ [www.brewnet.dev](https://www.brewnet.dev) — 셀프 호스팅 홈서버 자동 구축 오픈소스


---

## 유출 경위

> **유출 경위:** 2026년 3월 31일, 보안 연구자 Chaofan Shou가 Claude Code npm 패키지(v2.1.88)에 `.npmignore`에서 제외되지 않은 소스맵 파일(`main.js.map`)을 발견, Anthropic R2 버킷에서 `src.zip`을 직접 다운로드. 512,000줄 TypeScript 소스코드 전체가 노출됨. Anthropic이 유출 사실을 공식 확인. **이미지 출처: npm 유출 소스 분석 기반 커뮤니티 시각화 자료** (cc.storyfox.cz와 무관). Anthropic 공식 발표 아님 — 교육·리서치 참고용.

---

## 타임라인 개요

| 카테고리 | 수량 | 설명 |
|----------|------|------|
| **MAJOR** | 4 | 대형 아키텍처 변화·전략적 기능 — KAIROS, Coordinator 등 |
| **IN-FLIGHT** | 6 | 개발 진행 중·일부 코드 존재 — 브라우저 툴, SSH, 자율 에이전트 |
| **INFRASTRUCTURE** | 4 | 내부 기반 기술 강화 — 컨텍스트·메모리·권한 자동화 |
| **DEV TOOLING** | 6 | 개발자 생산성 도구 — 터미널, MCP 스킬, 커밋 추적 |
| **UNKNOWN / INTERNAL** | 3+1 | 플래그 존재·미연결 상태 — Anthropic 내부 전용 툴 포함 |

---

## 1. Major — 전략적 대형 기능 · 아키텍처 변화 수반

### KAIROS

- **EN:** Always-on background assistant with channels, push notifications, and GitHub webhook subscriptions.
- **KO:** **항상 켜져 있는 백그라운드 어시스턴트.** (그리스어 "적절한 시간" 어원, 소스 내 150회 이상 언급)

Claude Code가 터미널을 닫은 후에도 백그라운드 데몬으로 살아 있어 채널 메시지, 푸시 알림, GitHub 웹훅에 반응합니다. 핵심 메커니즘:

- **autoDream**: 사용자가 자리를 비운 야간 시간에 실행되는 메모리 통합 프로세스. 이전 세션의 관찰을 병합하고, 논리적 모순을 제거하고, 막연한 메모를 확정 사실로 변환함
- **append-only 일일 로그**: 관찰 내용을 날짜별로 누적 기록
- **Brief 출력 모드**: 상시 어시스턴트용 간결 응답 모드
- 사용자 복귀 시 컨텍스트가 깔끔하게 정리된 상태로 세션 재개

`daemon` `autoDream` `memory consolidation` `webhook` `150+ mentions`

### COORDINATOR_MODE

- **EN:** One Claude orchestrates N worker Claudes with a restricted toolset per worker.
- **KO:** **멀티-에이전트 오케스트레이션 모드.**

메인 Claude 인스턴스가 **메일박스 시스템**을 통해 여러 병렬 워커 에이전트를 조율합니다. 구조:

- **Coordinator**: 태스크 분해 → 워커 배정 → 결과 취합
- **Worker**: 제한된 툴셋만 허용, 각자 독립 서브태스크 처리
- 멀티스레딩이 아닌, 실제 팀처럼 역할 분리된 병렬 에이전트 집합

소스 내 연구→합성→구현 단계로 구조화된 것이 확인됨. `/batch`와 달리 중앙 컨트롤 타워가 지속적으로 조율.

`orchestration` `mailbox system` `multi-agent` `parallel` `toolset isolation`

### AGENT_TRIGGERS

- **EN:** Cron scheduling for agents — create, delete, list jobs. External webhook trigger variant included.
- **KO:** **에이전트용 크론 스케줄링 + 외부 웹훅 트리거.**

특정 시간 또는 외부 이벤트(웹훅)에 의해 Claude 에이전트가 자동 실행됩니다. 잡 생성·삭제·목록 조회 인터페이스 포함.

현재 `/loop [interval]`은 대화 내에서만 동작하지만, AGENT_TRIGGERS는 세션 외부에서도 독립적으로 에이전트를 깨울 수 있는 더 강력한 트리거 시스템입니다.

`cron` `webhook trigger` `job scheduling` `automation`

### VOICE_MODE

- **EN:** Full voice command interface with its own CLI entrypoint.
- **KO:** **독립 CLI 진입점을 가진 완전한 음성 명령 인터페이스.**

현재 `/voice` 명령어는 push-to-talk 딕테이션 수준이지만, VOICE_MODE는 별도의 CLI 엔트리포인트를 갖는 완전한 음성 제어 모드입니다.

*"claude-voice" 같은 별도 명령으로 실행될 가능성. 20개 언어 지원은 이미 확인됨.*

`voice` `CLI entrypoint` `speech-to-text` `multimodal`

---

## 2. In-Flight — 개발 진행 중 · 소스 내 일부 코드 존재 확인

### WEB_BROWSER_TOOL

- **EN:** Actual browser control (Playwright/CDP), not web_fetch.
- **KO:** **실제 브라우저 자동화 툴 (Playwright/Chrome DevTools Protocol).**

현재 `WebFetch`는 단순 HTTP 요청이지만, 이 툴은 실제 브라우저를 구동하여 JavaScript 렌더링, 클릭, 폼 입력, 스크린샷 등을 수행합니다.

이미 Chrome 익스텐션 베타(`--chrome`)가 존재하지만, 이는 내장 브라우저 툴로 Claude Code 단독 실행 시에도 브라우저 자동화가 가능해집니다.

`Playwright` `CDP` `browser automation` `web scraping`

### WORKFLOW_SCRIPTS

- **EN:** Pre-defined multi-step automation scripts the agent can invoke as a unit.
- **KO:** **에이전트가 단위로 호출할 수 있는 사전 정의 멀티스텝 자동화 스크립트.**

현재 Skills(슬래시 커맨드)보다 더 구조화된 워크플로우 레이어. "PR 리뷰 → 코드 수정 → 테스트 실행 → 커밋"과 같은 복합 작업을 하나의 워크플로우 단위로 묶어 재사용합니다.

*CI/CD 파이프라인을 Claude가 직접 정의·실행하는 방향으로 발전할 가능성.*

`workflow` `multi-step` `automation` `reusable`

### PROACTIVE

- **EN:** Agents can sleep, wait, and self-resume without user prompts.
- **KO:** **에이전트가 사용자 입력 없이 sleep → wait → 자기 재개 가능.**

현재 Claude는 사용자 입력을 기다려야 하지만, PROACTIVE 모드에서는 에이전트 스스로 "N분 후 다시 시도", "파일이 변경되면 재개" 같은 조건부 대기 후 자율 재개가 가능합니다.

`CwdChanged`, `FileChanged` 훅(v2.1.83)과 연계하면 파일 변경 감지 → 자동 분석 루프 구현 가능.

`autonomous` `self-resume` `sleep/wait` `event-driven`

### SSH_REMOTE + BRIDGE

- **EN:** SSH remote sessions and a cc:// URI protocol for direct agent connects.
- **KO:** **SSH 원격 세션 + `cc://` URI 프로토콜로 직접 에이전트 연결.**

원격 서버에 SSH로 접속한 상태에서도 Claude Code 에이전트를 직접 구동·연결할 수 있습니다. `cc://`는 Claude Code 전용 딥링크 URI 스킴으로, 에이전트 간 직접 통신 채널을 여는 데 사용됩니다.

원격 개발 환경(cloud dev boxes, Codespaces)에서 Claude를 완전히 통합하는 인프라.

`SSH` `cc:// URI` `remote session` `deep link`

### MONITOR_TOOL

- **EN:** Watch an MCP resource and trigger actions when its state changes.
- **KO:** **MCP 리소스를 감시하다 상태 변화 시 액션을 트리거.**

데이터베이스 쿼리 결과, API 엔드포인트, 파일 상태 등 MCP 리소스를 주기적으로 폴링·감시하고, 변화가 감지되면 자동으로 Claude가 지정된 작업을 수행합니다.

*예: "에러 로그가 증가하면 → 자동 분석 + Slack 알림 → 코드 수정 제안"*

`MCP resource` `polling` `state watch` `reactive`

### ULTRAPLAN

- **EN:** Enhanced planning pass, likely with plan verification built in.
- **KO:** **원격 Opus에 계획을 오프로드하는 강화 계획 패스.**

소스에서 확인된 실제 메커니즘:

- 복잡한 계획 태스크를 **원격 Cloud Container Runtime(CCR)**의 Opus 인스턴스에 전달
- 최대 **30분간** 심층 계획 수립
- 사용자가 **브라우저·폰**에서 계획 검토 후 승인
- 승인 시 `__ULTRAPLAN_TELEPORT_LOCAL__` 센티넬 값으로 결과를 로컬 터미널로 반환

*이미지 설명("plan verification built in")보다 훨씬 구체적인 원격 오프로드 아키텍처 확인됨.*

`remote CCR` `Opus offload` `30min planning` `teleport sentinel` `mobile approval`

---

## 3. Infrastructure — 내부 기반 기술 강화 · 사용자 직접 노출은 적음

### CONTEXT_COLLAPSE

- **EN:** Three compaction strategies: reactive, micro, and context inspection tool.
- **KO:** **3가지 컨텍스트 압축 전략 + 컨텍스트 검사 툴.**

현재 `/compact`는 단일 전략이지만, CONTEXT_COLLAPSE는 세 가지 방식을 제공합니다:

- **Reactive**: 95% 도달 시 자동 압축 (현재 auto-compact)
- **Micro**: 개별 툴 결과를 즉시 소형화
- **Context Inspection**: 컨텍스트 내용을 실시간 시각화·검사

*이미 일부는 `/context` 명령에 반영됨.*

`compaction` `reactive` `micro` `inspection`

### HISTORY_SNIP

- **EN:** Surgically remove specific parts of conversation history without a full compact.
- **KO:** **전체 압축 없이 대화 히스토리 특정 부분을 정밀 제거.**

현재는 `/compact`로 전체를 압축하거나 `/clear`로 초기화하는 것만 가능합니다. HISTORY_SNIP은 "이 특정 파일 읽기 결과만 제거", "10번~15번 턴만 삭제"처럼 외과적 편집을 지원합니다.

컨텍스트 오염 없이 정확한 히스토리 관리가 가능해집니다.

`history edit` `surgical removal` `context management` `no full compact`

### AGENT_MEMORY_SNAPSHOT

- **EN:** Persist agent memory state across sessions without external storage.
- **KO:** **외부 스토리지 없이 에이전트 메모리 상태를 세션 간 지속.**

현재 에이전트는 세션이 끝나면 상태를 잃습니다. AGENT_MEMORY_SNAPSHOT은 에이전트의 작업 상태·컨텍스트·진행도를 스냅샷으로 저장하고, 다음 세션에서 그대로 재개합니다.

CLAUDE.md의 자동 메모리(`~/.claude/projects/`)와 다르게 에이전트 특화 상태를 보존합니다.

`memory persistence` `snapshot` `cross-session` `stateful agent`

### TRANSCRIPT_CLASSIFIER

- **EN:** Auto-infer permission mode by reading what the session has been doing.
- **KO:** **세션에서 무슨 작업을 해왔는지 읽어 권한 모드를 자동 추론.**

사용자가 직접 권한 모드를 설정하지 않아도, 대화 맥락을 분석해 적절한 권한 수준을 자동 제안·적용합니다.

예: "테스트 작성 중" → `acceptEdits` 자동 제안 / "보안 감사 중" → `plan` 모드 제안. 이미 출시된 auto mode classifier의 확장 버전으로 보임.

`auto permission` `classifier` `context-aware` `adaptive mode`

---

## 4. Dev Tooling — 개발자 생산성 도구 · 워크플로우 통합

### TERMINAL_PANEL

- **EN:** Read the rendered terminal output buffer, not just bash stdout.
- **KO:** **bash stdout뿐 아니라 렌더링된 터미널 출력 버퍼 전체를 읽음.**

현재 Claude는 명령의 stdout/stderr만 받습니다. TERMINAL_PANEL은 터미널 화면 전체(스크롤백 포함, ANSI 색상 코드, 커서 위치 등)를 읽을 수 있게 됩니다.

TUI 애플리케이션, 대화형 프로그램(`vim`, `htop`, `python REPL`)의 상태를 Claude가 직접 파악 가능. computer-use 계열 기능과 연계 예상.

`terminal buffer` `TUI support` `ANSI` `screen read`

### CHICAGO_MCP

- **EN:** macOS-only system bridge (Spotlight, Accessibility, Notifications) via MCP.
- **KO:** **macOS 전용 시스템 브리지 — MCP를 통해 Spotlight·접근성·알림 연동.**

macOS 시스템 API를 MCP 서버로 래핑하여 Claude가 직접 접근 가능하게 합니다:

- **Spotlight**: 시스템 파일 검색
- **Accessibility API**: 화면의 UI 요소 읽기·제어
- **Notifications**: macOS 알림 센터 연동

*코드명 "Chicago"는 아마 내부 프로젝트명. Windows 버전은 별도 계획 가능성.*

`macOS only` `Spotlight` `Accessibility` `MCP bridge`

### SKILL_SEARCH + MCP_SKILLS

- **EN:** Local skill index + MCP-hosted skill libraries consumable like MCP servers.
- **KO:** **로컬 스킬 인덱스 + MCP로 호스팅된 스킬 라이브러리.**

두 가지 기능의 조합:

- **SKILL_SEARCH**: 설치된 스킬을 의미 기반으로 검색·발견
- **MCP_SKILLS**: 스킬을 MCP 서버처럼 원격 호스팅·공유 가능

팀 단위로 커스텀 스킬을 MCP 서버로 배포하고, 다른 개발자가 `/plugin install`처럼 설치하는 생태계 구축. 현재 `/skills` 명령의 대대적 확장.

`skill index` `MCP hosting` `semantic search` `skill sharing`

### UPLOAD_USER_SETTINGS

- **EN:** Sync local Claude Code config to remote on startup.
- **KO:** **시작 시 로컬 Claude Code 설정을 원격으로 동기화.**

`~/.claude/settings.json`, `~/.claude/CLAUDE.md` 등 개인 설정을 Anthropic 클라우드 또는 팀 서버에 자동 업로드·동기화합니다.

새 장비 셋업, 팀 표준 설정 배포, Claude Code on the Web과의 설정 동기화 시나리오에 활용 예상. 현재 Remote Control 기능의 설정 측면 확장.

`settings sync` `cloud backup` `remote config` `startup sync`

### COMMIT_ATTRIBUTION

- **EN:** Tag git commits with metadata identifying the Claude session that made them.
- **KO:** **git 커밋에 Claude 세션 식별 메타데이터를 태그.**

Claude가 작성한 코드가 커밋될 때 어떤 Claude 세션·모델·설정에서 생성됐는지 git trailers 또는 커밋 메시지에 자동 기록합니다.

예: `Claude-Session: sess_abc123`, `Claude-Model: claude-sonnet-4-6`

코드 감사(audit), AI 기여도 추적, 자동화된 코드 리뷰 시 출처 식별에 활용.

`git metadata` `attribution` `audit trail` `git trailers`

### TEMPLATES

- **EN:** Project scaffolding templates for /init — no tool wired yet.
- **KO:** **`/init` 용 프로젝트 스캐폴딩 템플릿 — 아직 툴 연결 없음.**

현재 `/init`은 CLAUDE.md를 자동 생성하는 수준이지만, TEMPLATES는 프로젝트 유형별 전체 스캐폴딩(파일 구조, 설정, CLAUDE.md, 스킬 세트)을 제공합니다.

예: "React TypeScript 프로젝트", "Python FastAPI 백엔드", "Next.js + Prisma" 템플릿으로 즉시 최적화된 환경 구성. *소스에 플래그만 존재, 미연결.*

`scaffolding` `/init` `project template` `unwired`

---

## 5. Unknown / Internal — 플래그 존재 · 미연결 상태 · Anthropic 내부 전용

### BUDDY

- **EN:** Flags compiled into the bundle. No tool or command wired to them yet.
- **KO:** **가상 반려 생물 동반 시스템.** 이미지 설명보다 훨씬 구체적인 구현 존재 확인.

- **18종**: duck, dragon, axolotl, capybara, mushroom, ghost 등
- **희귀도**: Common → Legendary(1% 확률) + shiny 변형
- **5가지 스탯**: DEBUGGING / PATIENCE / CHAOS / WISDOM / SNARK
- **결정론적 생성**: `userId` 해시 기반 → 같은 유저는 항상 같은 종 부화
- 입력창 옆 말풍선에 상주, 이름·성격은 Claude가 최초 부화 시 작성
- 코스메틱 모자 아이템 존재

*내부 주석: 4월 1~7일 티저, 2026년 5월 정식 출시 목표 (미확인). v2.1.89 changelog에 "/buddy" 만우절 기능으로 이미 노출됨.*

`18 species` `rarity tiers` `5 stats` `userId hash` `May 2026 target`

### LODESTONE · TORCH

- **EN:** Flags compiled into the bundle. No tool or command wired to them yet.
- **KO:** **번들에 컴파일된 플래그 · 툴·명령에 미연결 상태.**

- **LODESTONE**: 나침반(방향 제시)의 의미. 코드 네비게이션 또는 의존성 그래프 추적 기능 추정
- **TORCH**: 탐색 도구의 의미. 코드베이스 조명·딥서치 관련 가능성

*소스에 플래그만 존재, 구현 로직 미확인.*

`unwired` `flags only` `codenames`

### TOKEN_BUDGET

- **EN:** Per-session or per-agent token spend cap. Minimal wiring visible.
- **KO:** **세션 단위 또는 에이전트 단위 토큰 소비 상한 설정.**

현재 `--max-budget-usd` 플래그는 비용 기준 상한을 설정하지만, TOKEN_BUDGET은 토큰 수 기준으로 직접 제한합니다.

- 세션 전체 토큰 예산 설정
- 에이전트별 개별 토큰 예산 할당
- 예산 소진 시 자동 중단 또는 더 저렴한 모델로 전환

*소스에 최소한의 연결만 존재. 아직 초기 단계.*

`token budget` `spend cap` `per-agent` `minimal wiring`

### Ant-only tools

- **EN:** REPLTool, TungstenTool, ConfigTool — only load for Anthropic employees.
- **KO:** **Anthropic 직원 전용으로만 로드되는 내부 툴.**

세 가지 내부 전용 툴이 소스에 존재합니다:

- **REPLTool**: 인터랙티브 REPL 환경 — 코드 평가·실험용 내부 샌드박스
- **TungstenTool**: 텅스텐(고강도 금속)이라는 코드명 — 내부 인프라 또는 모델 접근 관련 추정
- **ConfigTool**: Anthropic 내부 설정 관리 툴 — 일반 사용자 `/config`와 다른 내부 레벨 설정

*직원 인증 시에만 활성화. 외부 공개 불가.*

`internal only` `REPLTool` `TungstenTool` `ConfigTool`

---

## 6. 이미지에 없는 유출 추가 발견 — src.zip 소스 분석에서만 확인된 항목

### UNDERCOVER MODE [논란]

- **EN:** USER_TYPE === 'ant' flag: when Anthropic employees work in public repos, system auto-enters undercover mode.
- **KO:** **Anthropic 직원이 공개 레포에서 작업 시 자동으로 "잠복 모드" 진입.**

소스에서 확인된 구체적 동작:

- `USER_TYPE === 'ant'` 플래그 감지 시 자동 활성화
- 시스템 프롬프트 주입: *"신분을 들키지 말 것"*, *"절대 AI라고 언급하지 말 것"*
- git 커밋의 **Co-Authored-By** 라인 자동 제거 (AI 기여 메타데이터 삭제)
- 내부 코드명을 응답에서 숨김
- 사용자 인터페이스에 **강제 해제 스위치 없음**

**윤리적 논란:** Co-Authored-By 삭제는 다른 개발자들이 AI 기여를 추적하는 신호를 제거함. "AI임을 밝히지 말라"는 지시는 공개 협업 환경에서의 공개 의무와 충돌 가능성.

`USER_TYPE=ant` `Co-Authored-By 삭제` `윤리 논란` `no force-off`

### 내부 모델 코드명 + 아키텍처

- **EN:** Internal model codenames, architecture scale, and silent behaviors found in leaked source.
- **KO:** **소스에서 확인된 내부 코드명 및 미문서화 동작:**

- **Fennec** = Opus 4.6 내부 코드명
- **Capybara** = Claude 4.6 변형 모델
- **Numbat** = 현재 테스트 중인 모델
- 전체 규모: 1,900개 파일, 512,000줄, main.tsx 단일 파일 785KB
- **44개** 컴파일 타임 피처 플래그 (일부 자료: 108개 게이팅 모듈)
- 컨텍스트 자동 압축 임계: **~167,000 토큰**에서 컨텍스트 파괴
- 파일 읽기 상한: **2,000줄** 초과 시 무음 할루시네이션 발생
- API 서버 오류 시 Opus → Sonnet **무음 다운그레이드**
- 런타임: Node 아닌 **Bun** · UI: React + Ink (CLI용 React)
- CHICAGO_MCP = Computer Use의 내부 코드명 (`@ant/computer-use-mcp`)

`Fennec=Opus4.6` `Capybara` `Bun runtime` `44 feature flags` `silent downgrade`

---

## 강의 활용 관점 분석 — brewnet 프로젝트 연계 포인트

### 단기 주목 기능

**COORDINATOR_MODE**는 brewnet 빌드 파이프라인에 직접 적용 가능 — 빌드/테스트/배포 워커 분리 시나리오로 강의 예시 구성 가능.

**COMMIT_ATTRIBUTION**은 AI 협업 코드 감사 워크플로우 챕터에 포함할 수 있는 실용적 기능.

### 중기 모니터링 기능

**WEB_BROWSER_TOOL**이 출시되면 brewnet E2E 테스트 자동화 챕터 추가 예정.

**SKILL_SEARCH + MCP_SKILLS**는 현재 Agent Skills 챕터(강의 레벨 4-5)의 연장선으로, 팀 스킬 공유 생태계 실습으로 발전 가능.

### 아키텍처 이해용

**KAIROS + AGENT_TRIGGERS**는 "Claude Code를 자율 시스템으로 운용"이라는 마지막 레벨 강의 주제와 직결.

**CONTEXT_COLLAPSE**의 세 가지 전략은 컨텍스트 관리 챕터에서 현재 auto-compact와 함께 비교 설명 가능.

---

## 출처

- **유출 경위:** 2026-03-31 · npm v2.1.88 소스맵(.map) 미제외 → Chaofan Shou 발견 → src.zip R2 버킷 직접 다운로드 → Anthropic 공식 확인 · 이 이미지는 커뮤니티 분석 시각화
- [GitHub CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
- [공식 Docs](https://code.claude.com/docs/en/overview)
- [WaveSpeed 분석](https://wavespeed.ai/blog/posts/claude-code-leaked-source-hidden-features/)
- [DEV.to 분석](https://dev.to/varshithvhegde/the-great-claude-code-leak-of-2026-accident-incompetence-or-the-best-pr-stunt-in-ai-history-3igm)
- [VentureBeat](https://venturebeat.com/technology/claude-codes-source-code-appears-to-have-leaked-heres-what-we-know)
