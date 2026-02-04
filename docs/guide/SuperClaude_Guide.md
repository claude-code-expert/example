# SuperClaude Framework 완벽 가이드

**SuperClaude Framework**는 Anthropic의 **Claude Code(CLI)**를 단순한 코딩 도구에서 **체계적인 소프트웨어 개발 플랫폼**으로 업그레이드해 주는 오픈소스 설정 프레임워크입니다.

> ⚠️ **주의**: 이 프로젝트는 Anthropic과 제휴하거나 보증을 받은 것이 아닙니다. Claude Code는 Anthropic에서 개발 및 유지 관리하는 제품입니다.

---

## 1. 주요 용도 (Purpose)

순정 Claude Code는 코딩 능력은 뛰어나지만, 프로젝트의 거시적 흐름을 관리하는 데는 한계가 있습니다. SuperClaude는 다음 역할을 수행합니다:

- **구조화된 개발 프로세스 강제**: 기획 → 설계 → 구현 → 테스트 → 리뷰의 정석적인 SDLC를 따르도록 유도합니다.
- **전문가 페르소나(Persona) 부여**: **보안 전문가**, **DB 아키텍트**, **프론트엔드 리드** 등 16개의 특정 역할에 맞춰 심도 있는 답변을 제공합니다.
- **프로젝트 매니징(PM)**: 현재 진행 상황, 남은 작업, 우선순위를 시각화하고 관리합니다.
- **MCP 서버 통합**: Tavily, Context7 등 8개의 MCP 서버와 연동하여 성능을 향상시킵니다.

---

## 2. 프레임워크 통계

| **Commands** | **Agents** | **Modes** | **MCP Servers** |
|:------------:|:----------:|:---------:|:---------------:|
| **30** | **16** | **7** | **8** |
| 슬래시 명령어 | 특화 AI 에이전트 | 행동 모드 | 외부 통합 |

---

## 3. 설치 방법 (Installation)

### 사전 요구사항

- Claude Code CLI 설치 및 인증 완료
- Python 3.11+
- Git

### Option 1: pipx 설치 (권장)

```bash
# PyPI에서 설치
pipx install superclaude

# 명령어 설치 (30개 슬래시 명령어 설치)
superclaude install

# MCP 서버 설치 (선택사항, 성능 향상용)
superclaude mcp --list                              # 사용 가능한 MCP 서버 목록
superclaude mcp                                      # 대화형 설치
superclaude mcp --servers tavily --servers context7  # 특정 서버 설치

# 설치 확인
superclaude install --list
superclaude doctor
```

### Option 2: pip 설치

```bash
# 표준 설치
pip install superclaude

# 또는 사용자 설치
pip install --user superclaude

# 설치 실행
superclaude install
```

### Option 3: npm 설치

```bash
# 전역 설치
npm install -g @bifrost_inc/superclaude

# 설치 실행
superclaude install
```

### Option 4: Git 직접 설치

```bash
# 저장소 클론
git clone https://github.com/SuperClaude-Org/SuperClaude_Framework.git
cd SuperClaude_Framework

# 설치 스크립트 실행
./install.sh
```

### 설치 후 확인

```bash
# Claude Code를 재시작한 후 다음 명령어 테스트
/sc:brainstorm "test project"     # 구조화된 브레인스토밍
/sc:analyze README.md             # 구조화된 분석
/sc                               # 사용 가능한 모든 명령어 표시
```

---

## 4. 기본 워크플로 (Workflow Example)

"새로운 로그인 기능을 만들고 싶어"라고 가정할 때의 흐름:

### Step 1: 기획

```
/sc:brainstorm "로그인 기능 구현"
```
Claude가 보안 요건, 인증 방식(OAuth 등)을 역질문하며 요구사항을 구체화합니다.

### Step 2: 설계

```
/sc:design "JWT 기반 인증 아키텍처"
```
DB 스키마, API 명세, 시퀀스 다이어그램을 설계합니다.

### Step 3: 구현

```
/sc:implement "로그인 API 개발"
```
설계된 명세를 바탕으로 실제 코드를 작성합니다.

### Step 4: 검증

```
/sc:test "로그인 API 유닛 테스트"
```
테스트 코드를 작성하고 실행하여 버그를 검증합니다.

---

## 5. 핵심 특징

### 💡 핵심 메시지

> "Claude Code는 뛰어난 신입 개발자이고, SuperClaude는 그를 이끌어주는 노련한 사수(Senior) 역할을 한다."

### 🔑 주요 기능

#### 자동 페르소나 감지 (16개 전문 에이전트)

- `.tsx` 파일을 수정하면 '프론트엔드 전문가'로 자동 전환
- 보안 로직을 다루면 '보안 엔지니어'로 자동 전환
- PM Agent가 지속적 학습을 통해 문서화 개선
- Deep Research Agent로 자율적 웹 리서치

#### MCP(Model Context Protocol) 시너지 (8개 서버)

| 서버 | 용도 |
|------|------|
| **Tavily** | 웹 검색 (Deep Research) |
| **Context7** | 공식 문서 조회 |
| **Sequential-Thinking** | 다단계 추론 |
| **Serena** | 세션 지속성 및 메모리 |
| **Playwright** | 크로스 브라우저 자동화 |
| **Magic** | UI 컴포넌트 생성 |
| **Morphllm-Fast-Apply** | 컨텍스트 인식 코드 수정 |
| **Chrome DevTools** | 성능 분석 |

#### 7개 행동 모드

- **Brainstorming** → 적절한 질문 유도
- **Business Panel** → 다중 전문가 전략 분석
- **Deep Research** → 자율적 웹 리서치
- **Orchestration** → 효율적 도구 조정
- **Token-Efficiency** → 30-50% 컨텍스트 절약
- **Task Management** → 체계적 조직화
- **Introspection** → 메타인지 분석

#### 체계적인 버그 수정 (3단계)

바로 고치지 않고 **분석**(`/sc:analyze`) → **계획**(`/sc:design`) → **수정**(`/sc:implement`) 단계를 거쳐 사이드 이펙트를 최소화합니다.

### ⚠️ Trade-off

- 체계적인 처리를 위해 프롬프트가 길어져 토큰 비용이 상승할 수 있음
- MCP 없이도 완전히 작동하지만, MCP와 함께 사용 시 2-3배 빠른 실행, 30-50% 적은 토큰 사용

---

## 6. 명령어 전체 정리 (30개 Command Reference)

### 🧠 기획 및 설계 (Planning & Design) - 4개

| 명령어 | 설명 |
|--------|------|
| `/sc:brainstorm` | 아이디어 구체화, 요구사항 도출, 기능 정의 (프로젝트 초기 단계 필수) |
| `/sc:design` | 시스템 아키텍처, DB 스키마, 인터페이스 설계 및 문서화 |
| `/sc:spec-panel` | 요구사항 명세서(Spec) 분석 및 검토 |
| `/sc:estimate` | 작업 소요 시간 및 난이도 산정 (Story Point 등) |

### 💻 개발 및 구현 (Development) - 5개

| 명령어 | 설명 |
|--------|------|
| `/sc:implement` | (핵심) 설계된 내용을 바탕으로 실제 코드 작성 및 구현 |
| `/sc:build` | 빌드 스크립트 실행 및 빌드 오류 해결 |
| `/sc:improve` | 기존 코드의 품질 개선, 최적화 수행 |
| `/sc:cleanup` | 코드 리팩토링, 불필요한 주석 제거, 포맷팅 정리 |
| `/sc:explain` | 복잡한 코드나 로직을 알기 쉽게 설명 |

### 🧪 테스트 및 품질 (Testing & Quality) - 4개

| 명령어 | 설명 |
|--------|------|
| `/sc:test` | 유닛 테스트, 통합 테스트 코드 생성 및 실행 |
| `/sc:analyze` | 코드 품질, 보안 취약점, 잠재적 버그 분석 보고서 생성 |
| `/sc:troubleshoot` | 발생한 에러의 원인을 분석하고 디버깅 가이드 제공 |
| `/sc:reflect` | 작업 완료 후 회고(Retrospective) 및 개선점 도출 |

### 🔍 리서치 및 분석 (Research & Analysis) - 2개

| 명령어 | 설명 |
|--------|------|
| `/sc:research` | (Deep Research) 웹 검색을 통해 심층 기술 조사 및 시장 조사 수행 |
| `/sc:business-panel` | 비즈니스 관점(수익성, 시장성)에서의 분석 및 조언 |

### 📚 문서화 (Documentation) - 2개

| 명령어 | 설명 |
|--------|------|
| `/sc:document` | 코드에 대한 주석 및 문서(README 등) 자동 생성 |
| `/sc:help` | 특정 명령어에 대한 상세 도움말 표시 |

### 📊 프로젝트 관리 (Project Management) - 3개

| 명령어 | 설명 |
|--------|------|
| `/sc:pm` | 프로젝트 진행 상황 점검, 마일스톤 관리 |
| `/sc:task` | 세부 할 일(Task) 관리 및 우선순위 조정 |
| `/sc:workflow` | 현재 작업 단계에 맞는 다음 행동 가이드 (워크플로 자동화) |

### 🔧 버전 관리 (Version Control) - 1개

| 명령어 | 설명 |
|--------|------|
| `/sc:git` | Git 커밋, 브랜치 관리 등 버전 관리 작업 수행 |

### 🎯 유틸리티 (Utilities) - 9개

| 명령어 | 설명 |
|--------|------|
| `/sc` | 사용 가능한 모든 SuperClaude 명령어 목록 표시 |
| `/sc:agent` | 특정 작업을 위한 AI 에이전트(Sub-agent) 호출 |
| `/sc:index-repo` | 프로젝트 전체 파일 인덱싱 (컨텍스트 확보용) |
| `/sc:index` | 인덱싱 별칭 |
| `/sc:recommend` | 명령어 추천 |
| `/sc:select-tool` | 도구 선택 |
| `/sc:spawn` | 병렬 태스크 실행 |
| `/sc:save` | 현재 세션 상태 저장 |
| `/sc:load` | 저장된 세션 상태 불러오기 |

---

## 7. Deep Research 기능

### 자율적 웹 리서치 기능

SuperClaude v4.2는 포괄적인 Deep Research 기능을 제공합니다.

#### 리서치 깊이 레벨

| 깊이 | 소스 수 | 홉 수 | 시간 | 용도 |
|------|--------|------|------|------|
| **Quick** | 5-10 | 1 | ~2분 | 빠른 팩트, 간단한 쿼리 |
| **Standard** | 10-20 | 3 | ~5분 | 일반 리서치 (기본값) |
| **Deep** | 20-40 | 4 | ~8분 | 포괄적 분석 |
| **Exhaustive** | 40+ | 5 | ~10분 | 학술 수준 리서치 |

#### 사용 예시

```bash
# 기본 리서치
/sc:research "latest AI developments 2024"

# 특정 도메인 필터링 (Tavily MCP 연동)
/sc:research "React patterns"  # domains: reactjs.org,github.com
```

---

## 8. 참고 자료

### 공식 링크

| 구분 | 링크 |
|------|------|
| **공식 GitHub 저장소** | https://github.com/SuperClaude-Org/SuperClaude_Framework |
| **공식 웹사이트** | https://superclaude.netlify.app/ |
| **PyPI** | https://pypi.org/project/superclaude/ |
| **npm** | https://www.npmjs.com/package/@bifrost_inc/superclaude |
| **Commands Reference** | https://github.com/SuperClaude-Org/SuperClaude_Framework/blob/master/docs/user-guide/commands.md |
| **Quick Start Guide** | https://github.com/SuperClaude-Org/SuperClaude_Framework/blob/master/docs/getting-started/quick-start.md |
| **Installation Guide** | https://github.com/SuperClaude-Org/SuperClaude_Framework/blob/master/docs/getting-started/installation.md |

### 커뮤니티

- **GitHub Discussions**: https://github.com/SuperClaude-Org/SuperClaude_Framework/discussions
- **Ko-fi**: https://ko-fi.com/superclaude
- **Patreon**: https://patreon.com/superclaude

---

## 9. 버전 정보

- **현재 안정 버전**: v4.2.0
- **라이선스**: MIT
- **GitHub Stars**: 20.4k+
- **개발자**: SuperClaude-Org (NomenAK)

> ⚠️ **참고**: TypeScript 플러그인 시스템은 v5.0에서 계획 중이며 아직 사용할 수 없습니다.

---

*Based on SuperClaude Framework v4.2.0 (2026년 1월 기준)*
