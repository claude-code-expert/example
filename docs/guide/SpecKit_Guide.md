# GitHub Spec Kit 완벽 가이드

**GitHub Spec Kit**은 GitHub에서 공식 출시한 오픈소스 툴킷으로, **Spec-Driven Development (명세 주도 개발, SDD)**를 위한 프레임워크입니다. AI에게 막연하게 코딩을 시키는 "Vibe Coding"에서 벗어나, 명확한 설계도(Spec)를 먼저 작성하여 고품질의 코드를 얻어내는 것이 목적입니다.

> 💡 **핵심 철학**: "코드가 명세를 따르는 것이 아니라, 명세가 코드를 생성한다."

---

## 1. Spec Kit이 필요한 이유

- **Vibe Coding 방지**: "대충 이렇게 해줘"라고 말해서 발생하는 엉뚱한 결과물을 방지합니다.
- **맥락 유지**: 대화가 길어져도 AI가 프로젝트의 핵심 목표와 제약 조건을 잊지 않게 합니다.
- **협업 표준화**: 팀원 누구나 AI를 사용해도 동일한 품질과 스타일의 코드가 나오도록 규제합니다.
- **의도 중심 개발**: 코드가 아닌 "의도(Intent)"가 진실의 원천(Source of Truth)이 됩니다.

---

## 2. 설치 방법 (Installation)

### CLI 설치 (권장: uv 사용)

```bash
# uv를 사용한 영구 설치 (권장)
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# 설치 확인
specify --version

# 시스템 요구사항 체크
specify check
```

### 일회성 실행

```bash
uvx --from git+https://github.com/github/spec-kit.git specify init <PROJECT_NAME>
```

### 업그레이드

```bash
uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git
```

---

## 3. 핵심 구성 요소

### 📜 Constitution (헌법)

프로젝트의 불변의 법칙을 정의한 문서입니다. AI는 모든 작업을 할 때 이 파일을 최우선으로 참조합니다.

**예시 항목:**
- "코드는 무조건 TypeScript Strict 모드를 준수할 것"
- "UI 라이브러리는 Shadcn/UI만 사용할 것"
- "모든 비즈니스 로직은 Service 레이어에 분리할 것"
- "테스트 커버리지 90% 필수"

### 📋 Spec & Plan (명세와 계획)

| 구분 | 역할 | 내용 |
|------|------|------|
| **Spec** | *무엇(What)*을 만들 것인가? | 사용자 관점 요구사항, 유저 스토리 |
| **Plan** | *어떻게(How)* 만들 것인가? | 기술적 구현 설계, 아키텍처 선택 |

---

## 4. 프로젝트 초기화

### 새 프로젝트 생성

```bash
# 기본 프로젝트 초기화
specify init my-project

# 특정 AI 에이전트 지정
specify init my-project --ai claude
specify init my-project --ai copilot
specify init my-project --ai gemini
specify init my-project --ai cursor-agent

# 현재 디렉토리에서 초기화
specify init . --ai claude
# 또는
specify init --here --ai claude

# 기존 파일이 있는 디렉토리에 강제 초기화
specify init . --force --ai claude
```

### 생성되는 프로젝트 구조

```
└── .specify
    ├── memory
    │   └── constitution.md
    ├── scripts
    │   ├── check-prerequisites.sh
    │   ├── common.sh
    │   ├── create-new-feature.sh
    │   ├── setup-plan.sh
    │   └── update-claude-md.sh
    ├── specs
    │   └── [feature-name]
    │       └── spec.md
    └── templates
        ├── plan-template.md
        ├── spec-template.md
        └── tasks-template.md
```

---

## 5. 명령어 레퍼런스 (Slash Commands)

### 핵심 명령어 (Core Commands)

| 명령어 | 역할 | 사용 시점 |
|--------|------|----------|
| `/speckit.constitution` | 프로젝트 원칙 및 개발 가이드라인 정의 | 프로젝트 최초 세팅 시 |
| `/speckit.specify` | 요구사항 정의 및 명세서 작성 | 새로운 기능 개발 시작 전 |
| `/speckit.plan` | 기술적 구현 계획 수립 | 명세 확정 후 구현 전 |
| `/speckit.tasks` | 구현 작업을 할 일 목록으로 분해 | 계획 수립 후 코딩 직전 |
| `/speckit.implement` | 모든 태스크 실행하여 기능 구현 | 태스크 분해 완료 후 |

### 선택 명령어 (Optional Commands)

| 명령어 | 역할 | 사용 시점 |
|--------|------|----------|
| `/speckit.clarify` | 명세의 모호함 제거 (AI의 역질문) | `/speckit.plan` 전 검증 단계 |
| `/speckit.analyze` | 아티팩트 간 정합성 및 커버리지 분석 | `/speckit.tasks` 후, `/speckit.implement` 전 |
| `/speckit.checklist` | 요구사항 완전성, 명확성, 일관성 검증 체크리스트 생성 | 품질 검증 시 |

---

## 6. 지원 AI 에이전트

| 에이전트 | 지원 | 비고 |
|----------|:----:|------|
| Claude Code | ✅ | |
| GitHub Copilot | ✅ | |
| Cursor | ✅ | |
| Gemini CLI | ✅ | |
| Windsurf | ✅ | |
| Codex CLI | ✅ | |
| Qwen Code | ✅ | |
| opencode | ✅ | |
| Kilo Code | ✅ | |
| Roo Code | ✅ | |
| Amp | ✅ | |
| Amazon Q Developer CLI | ⚠️ | 커스텀 슬래시 명령어 인자 미지원 |

---

## 7. 추천 워크플로 (Best Practice)

### 예시: "마이페이지 프로필 이미지 업로드 기능" 개발

#### Step 1: 프로젝트 원칙 설정

```
/speckit.constitution 코드 품질, 테스트 표준, UX 일관성, 성능 요구사항에 초점을 맞춘 원칙을 생성해줘
```

#### Step 2: 명세 작성

```
/speckit.specify 마이페이지에서 프로필 이미지 업로드 기능을 만들어줘. 
사용자는 자신의 프로필 사진을 업로드하고 미리보기를 볼 수 있어야 해.
```

#### Step 3: 명세 구체화

```
/speckit.clarify
```

AI가 역질문합니다:
- "이미지 용량 제한은 몇 MB인가요?"
- "리사이징 처리는 프론트에서 하나요, 서버에서 하나요?"
- "지원하는 이미지 포맷은 무엇인가요?"

답변 후 명세가 업데이트됩니다.

#### Step 4: 기술 설계

```
/speckit.plan S3 버킷을 사용하고, Sharp 라이브러리로 서버에서 리사이징 처리해줘.
API 엔드포인트는 POST /api/user/image로 설계해줘.
```

#### Step 5: 태스크 분해

```
/speckit.tasks
```

생성되는 체크리스트:
- [ ] Prisma 스키마 변경 (User 모델에 profileImage 필드 추가)
- [ ] S3 업로드 서비스 구현
- [ ] 이미지 리사이징 서비스 구현
- [ ] API 엔드포인트 구현
- [ ] 프론트엔드 업로드 컴포넌트 제작
- [ ] 테스트 코드 작성

#### Step 6: 구현 실행

```
/speckit.implement
```

---

## 8. SuperClaude와의 차이점

| 구분 | SuperClaude | Spec Kit |
|------|-------------|----------|
| **범위** | Claude Code 전용 확장팩 | 모든 AI 에이전트 지원 |
| **목적** | Claude Code 성능 극대화 | 개발 절차 자체를 표준화 |
| **접근법** | 전문가 페르소나 부여 | 명세 기반 워크플로 강제 |
| **사용처** | Claude Code CLI | Copilot, Cursor, Windsurf 등 어디서든 |

> 💡 **요약**: SuperClaude가 Claude Code를 위한 '사수'라면, Spec Kit은 **모든 AI 에이전트를 위한 '표준 작업 지시서'**를 만드는 도구입니다.

---

## 9. CLI 옵션 레퍼런스

### specify init 옵션

| 옵션 | 설명 |
|------|------|
| `--ai` | 사용할 AI 에이전트 지정 (claude, gemini, copilot, cursor-agent 등) |
| `--script` | 스크립트 타입 선택: `sh` (bash/zsh) 또는 `ps` (PowerShell) |
| `--here` | 현재 디렉토리에서 초기화 |
| `--force` | 기존 파일 덮어쓰기 (확인 생략) |
| `--no-git` | Git 저장소 초기화 건너뛰기 |
| `--ignore-agent-tools` | AI 에이전트 도구 설치 체크 건너뛰기 |
| `--debug` | 디버그 출력 활성화 |
| `--github-token` | GitHub API 요청용 토큰 |

### 환경 변수

| 변수 | 설명 |
|------|------|
| `SPECIFY_FEATURE` | Git 브랜치 미사용 시 특정 기능 디렉토리 지정 |
| `GH_TOKEN` / `GITHUB_TOKEN` | GitHub API 인증 토큰 |

---

## 10. 주요 참고 자료

- **공식 저장소**: https://github.com/github/spec-kit
- **공식 문서 사이트**: https://speckit.org/
- **GitHub 블로그 소개글**: https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/
- **방법론 상세 문서**: https://github.com/github/spec-kit/blob/main/spec-driven.md

---

*Based on GitHub Spec Kit v0.0.90 (2025년 12월 기준)*
