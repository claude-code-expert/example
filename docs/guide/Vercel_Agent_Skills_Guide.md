# Vercel Agent Skills 완벽 가이드

**Vercel Agent Skills**는 Vercel Labs에서 개발한 **AI 코딩 에이전트를 위한 기술 패키지 모음**입니다. npm처럼 명령어 하나로 설치할 수 있어 "AI 에이전트용 npm"이라고도 불립니다.

> 💡 **핵심 컨셉**: AI 코딩 에이전트에게 10년 이상의 React/Next.js 최적화 노하우와 베스트 프랙티스를 한 번에 학습시킬 수 있습니다.

---

## 1. Agent Skills란?

Agent Skills는 AI 코딩 에이전트의 기능을 확장하는 **재사용 가능한 지침 세트**입니다. 각 스킬은 `SKILL.md` 파일과 선택적 스크립트로 구성되며, 다양한 AI 도구가 동일한 포맷을 이해할 수 있도록 설계되었습니다.

### 스킬의 구조

```
{skill-name}/
├── SKILL.md           # 필수: 에이전트를 위한 자연어 지침
├── AGENTS.md          # 선택: 상세 규칙 및 가이드라인
└── scripts/           # 선택: 자동화 스크립트
    └── deploy.sh
```

### Agent Skills 명세

Skills는 [Agent Skills 명세](https://agentskills.io)를 따르며, 이를 통해 다양한 AI 코딩 도구들이 동일한 스킬 레이아웃을 사용할 수 있습니다.

---

## 2. 설치 방법

### 빠른 시작

```bash
# Vercel의 모든 스킬 설치
npx skills add vercel-labs/agent-skills
```

### 설치 옵션

```bash
# 저장소의 스킬 목록 확인
npx skills add vercel-labs/agent-skills --list

# 특정 스킬만 설치
npx skills add vercel-labs/agent-skills --skill react-best-practices

# 여러 스킬 설치
npx skills add vercel-labs/agent-skills --skill react-best-practices --skill web-design-guidelines

# 특정 에이전트에만 설치
npx skills add vercel-labs/agent-skills -a claude-code -a cursor

# 전역 설치 (모든 프로젝트에서 사용)
npx skills add vercel-labs/agent-skills -g

# CI/CD용 비대화형 설치
npx skills add vercel-labs/agent-skills --skill react-best-practices -g -a claude-code -y
```

> 구 add-skill CLI는 skills CLI로 통합되었다 (2026-06 기준 vercel-labs/skills v1.5.x).

### CLI 옵션

| 옵션 | 설명 |
|------|------|
| `-g, --global` | 프로젝트가 아닌 사용자 디렉토리에 설치 |
| `-a, --agent <agents...>` | 대상 에이전트 지정 |
| `-s, --skill <skills...>` | 특정 스킬만 설치 |
| `-l, --list` | 설치 없이 스킬 목록만 표시 |
| `-y, --yes` | 모든 확인 프롬프트 건너뛰기 |

---

## 3. 지원 에이전트

### 호환 에이전트 목록

주요 에이전트 예시 (전체 목록은 vercel-labs/skills README 참조):

| 에이전트 | 프로젝트 경로 | 전역 경로 |
|---------|-------------|----------|
| **Claude Code** | `.claude/skills/<n>/` | `~/.claude/skills/<n>/` |
| **Cursor** | `.cursor/skills/<n>/` | `~/.cursor/skills/<n>/` |
| **OpenCode** | `.opencode/skill/<n>/` | `~/.config/opencode/skill/<n>/` |
| **Codex** | `.codex/skills/<n>/` | `~/.codex/skills/<n>/` |
| **GitHub Copilot** | 지원 | 지원 |
| **Windsurf** | 지원 | 지원 |
| **Gemini CLI** | 지원 | 지원 |
| **Amp** | 지원 | 지원 |
| **Kiro CLI** | 지원 | 지원 |
| **Goose** | 지원 | 지원 |

### 에이전트 자동 감지

CLI가 설정 디렉토리를 확인하여 설치된 코딩 에이전트를 자동으로 감지합니다. 감지되지 않으면 설치할 에이전트를 선택하라는 메시지가 표시됩니다.

---

## 4. 제공 스킬

### 📊 react-best-practices

Vercel Engineering의 **React 및 Next.js 성능 최적화 가이드라인**입니다.

**특징:**
- 10년 이상의 React/Next.js 최적화 노하우 집약
- 8개 카테고리에 걸친 **40개 이상의 규칙**
- 영향도에 따른 우선순위 분류

**카테고리 (영향도 순):**

| 우선순위 | 카테고리 | 설명 |
|---------|---------|------|
| **Critical** | Eliminating Waterfalls | 요청 워터폴 제거 (가장 큰 성능 향상) |
| **Critical** | Bundle Size Optimization | 번들 크기 최적화 |
| **High** | Server-side Performance | 서버 사이드 성능 |
| **Medium-High** | Client-side Data Fetching | 클라이언트 데이터 페칭 |
| **Medium** | Re-render Optimization | 리렌더링 최적화 |
| **Medium** | Rendering Performance | 렌더링 성능 |
| **Low-Medium** | JavaScript Micro-optimizations | JS 마이크로 최적화 |

**트리거 조건:**
- React 컴포넌트나 Next.js 페이지 작성 시
- 데이터 페칭 구현 시 (클라이언트/서버)
- 성능 이슈 코드 리뷰 시
- 번들 크기나 로드 시간 최적화 시

**사용 예시:**
```
"Review this React component for performance issues"
"Help me optimize this Next.js page"
"Check for waterfalls in my data fetching"
```

---

### 🎨 web-design-guidelines

웹 인터페이스 베스트 프랙티스 준수 여부를 검토하는 **UI 감사 스킬**입니다.

**특징:**
- 접근성, 성능, UX를 포괄하는 **100개 이상의 규칙**
- 체계적인 UI 품질 검사 가능

**카테고리:**
- **Accessibility**: aria-labels, 시맨틱 HTML, 키보드 핸들러
- **Focus States**: visible focus, focus-visible 패턴
- **Forms**: autocomplete, validation, labels
- **Animation**: prefers-reduced-motion, 성능
- **Typography**: 가독성, 반응형 타이포그래피
- **Images**: alt 텍스트, lazy loading, 최적화
- **Performance**: Core Web Vitals, 로딩 전략
- **Navigation**: 키보드 내비게이션, skip links
- **Dark Mode**: 색상 대비, 테마 전환
- **Touch**: 터치 타겟, 제스처
- **i18n**: RTL 지원, 번역 준비

**트리거 조건:**
```
"Review my UI"
"Check accessibility"
"Audit design"
"Review UX"
"Check my site against best practices"
```

---

### 🚀 vercel-deploy (vercel-deploy-claimable)

대화에서 직접 **Vercel로 배포**할 수 있는 스킬입니다.

**특징:**
- **인증 불필요** - 즉시 작동
- `package.json`에서 **40개 이상의 프레임워크 자동 감지**
- Preview URL과 Claim URL 반환
- `node_modules`와 `.git` 자동 제외
- 정적 HTML 프로젝트 지원

**지원 프레임워크:**
- **React 계열**: Next.js, Gatsby, Create React App, Remix, React Router
- **Vue 계열**: Nuxt, Vue CLI, Vite
- **기타**: Astro, SvelteKit, Blitz, Hydrogen, RedwoodJS, Storybook, Sanity 등

**트리거 조건:**
```
"Deploy my app"
"Deploy this to production"
"Create a preview deployment"
"Deploy and give me the link"
"Push this live"
```

**작동 방식:**
1. 프로젝트를 tarball로 패키징
2. 프레임워크 감지 (Next.js, Vite, Astro 등)
3. 배포 서비스에 업로드
4. Preview URL과 Claim URL 반환

**출력 예시:**
```
✓ Deployment successful!

Preview URL: https://skill-deploy-abc123.vercel.app
Claim URL:   https://vercel.com/claim-deployment?code=...
```

**JSON 출력 (프로그래매틱 사용):**
```json
{
  "previewUrl": "https://skill-deploy-abc123.vercel.app",
  "claimUrl": "https://vercel.com/claim-deployment?code=...",
  "deploymentId": "dpl_...",
  "projectId": "prj_..."
}
```

> 💡 **Claim URL**: 배포된 프로젝트를 자신의 Vercel 계정으로 이전할 수 있는 링크입니다. 자격 증명 공유 없이 소유권 이전이 가능합니다.

---

## 5. 설치 경로

### 프로젝트 레벨 (기본값)

현재 작업 디렉토리에 설치됩니다. 팀과 공유하려면 커밋하세요.

```
.claude/skills/react-best-practices/
.cursor/skills/react-best-practices/
```

### 전역 레벨 (`--global`)

홈 디렉토리에 설치됩니다. 모든 프로젝트에서 사용 가능합니다.

```
~/.claude/skills/react-best-practices/
~/.cursor/skills/react-best-practices/
```

---

## 6. 사용법

### 설치 후 사용

스킬이 설치되면 자동으로 사용 가능합니다. 관련 작업이 감지되면 에이전트가 자동으로 스킬을 활성화합니다.

```bash
# Claude Code에서
> Review this React component for performance issues
# → react-best-practices 스킬 자동 활성화

> Check this page for accessibility problems  
# → web-design-guidelines 스킬 자동 활성화

> Deploy my app
# → vercel-deploy 스킬 자동 활성화
```

### claude.ai에서 사용

1. 프로젝트 knowledge에 스킬 추가
2. 또는 `SKILL.md` 내용을 대화에 붙여넣기

### 네트워크 설정 (vercel-deploy)

배포 스킬 사용 시 네트워크 제한으로 실패하면:

1. [claude.ai/admin-settings/capabilities](https://claude.ai/admin-settings/capabilities) 접속
2. 허용 도메인에 `*.vercel.com` 추가

---

## 7. 커스텀 스킬 만들기

### SKILL.md 구조

```markdown
---
name: my-skill
description: 이 스킬이 무엇을 하고 언제 사용하는지 설명
---

# My Skill

에이전트가 이 스킬이 활성화될 때 따를 지침.

## When to Use

이 스킬이 사용되어야 하는 시나리오 설명.

## Steps

1. 첫째, 이것을 수행
2. 그 다음, 저것을 수행
```

### 필수 필드

- `name`: 고유 식별자 (소문자, 하이픈 허용)
- `description`: 스킬 기능에 대한 간단한 설명

### 스킬 작성 가이드라인

- **SKILL.md는 500줄 이하로 유지** — 상세 참조 자료는 별도 파일에
- **구체적인 설명 작성** — 에이전트가 정확히 언제 활성화할지 알 수 있도록
- **점진적 공개 사용** — 필요할 때만 읽히는 지원 파일 참조
- **인라인 코드보다 스크립트 선호** — 스크립트 실행은 컨텍스트를 소비하지 않음 (출력만 소비)

---

## 8. 호환성

스킬은 공유된 Agent Skills 명세를 따르므로 에이전트 간 일반적으로 호환됩니다.

| 기능 | OpenCode | Claude Code | Codex | Cursor |
|------|:--------:|:-----------:|:-----:|:------:|
| Basic skills | ✅ | ✅ | ✅ | ✅ |
| `allowed-tools` | ✅ | ✅ | ✅ | ✅ |
| `context: fork` | ❌ | ✅ | ❌ | ❌ |
| Hooks | ❌ | ✅ | ❌ | ❌ |

---

## 9. 트러블슈팅

### "No skills found" 오류

저장소에 `name`과 `description`이 포함된 유효한 `SKILL.md` 파일이 있는지 확인하세요.

### 에이전트에서 스킬이 로드되지 않음

- 스킬이 올바른 경로에 설치되었는지 확인
- 에이전트의 스킬 로딩 요구사항 문서 확인
- `SKILL.md` frontmatter가 유효한 YAML인지 확인

### 권한 오류

대상 디렉토리에 쓰기 권한이 있는지 확인하세요.

---

## 10. 참고 자료

### 공식 링크

| 구분 | 링크 |
|------|------|
| **Agent Skills 저장소** | https://github.com/vercel-labs/agent-skills |
| **skills CLI (구 add-skill)** | https://github.com/vercel-labs/skills |
| **Skills 디렉토리** | https://skills.sh |
| **Agent Skills 명세** | https://agentskills.io |
| **Vercel 공식 발표** | https://vercel.com/changelog/introducing-skills-the-open-agent-skills-ecosystem |
| **React Best Practices 블로그** | https://vercel.com/blog/introducing-react-best-practices |

### 에이전트별 문서

- [OpenCode Skills Documentation](https://opencode.ai/docs/skills/)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Codex Skills Documentation](https://developers.openai.com/codex/skills/)
- [Cursor Skills Documentation](https://cursor.com/docs/context/skills)

---

## 11. 요약

| 항목 | 내용 |
|------|------|
| **개발사** | Vercel Labs |
| **릴리스** | 2026년 1월 20일 |
| **라이선스** | MIT |
| **제공 스킬** | react-best-practices, web-design-guidelines, vercel-deploy |
| **지원 에이전트** | Claude Code, Cursor, OpenCode, Codex, GitHub Copilot, Windsurf 등 70개 이상 (2026년 6월, vercel-labs/skills 기준 — 발표 시점인 2026년 1월에는 17개) |
| **설치 명령** | `npx skills add vercel-labs/agent-skills` |

---

*Based on Vercel Agent Skills (2026년 1월 기준)*
