# 4.5 Claude Code와 함께 요건 문서 작성하기

4.2절부터 4.4절까지 Tika의 기능 요구사항(FR), 비기능 요구사항(NFR), 사용자 스토리(US)를 정의했다. 이제 이것들을 실제 프로젝트의 문서 체계로 구체화할 차례다. 이번 절에서는 Claude Code와 대화하며 프로젝트 구조를 잡고, 개발 문서를 작성하고, TDD 방식의 개발 흐름을 만들어가는 과정을 다룬다.

핵심은 **Claude Code에게 요청하기 전에 개발자가 먼저 판단하고 결정해야 할 것들**이 있다는 점이다. 프론트와 백을 어떤 방식으로 분리할 것인지, ORM은 무엇을 쓸 것인지, 배포는 어디에 할 것인지. 이런 결정을 AI에게 떠넘기면 매번 다른 답이 돌아오고, 프로젝트의 일관성이 무너진다. 개발자가 큰 방향을 잡고, Claude Code가 그 방향 안에서 구체적인 구현을 채워나가는 역할 분담이 가장 효과적이다.


## 4.5.1 프로젝트 구조 및 실제 개발 계획 수립하기

### 기술 스택 결정: 개발자가 먼저 판단할 것들

프로젝트를 시작하기 전에 개발자가 직접 결정해야 하는 핵심 사항들이 있다. Claude Code에게 "적당히 골라줘"라고 하면 대화할 때마다 다른 스택을 추천하거나, 과거 학습 데이터에 편향된 선택을 할 수 있다. 아래 표는 Tika 프로젝트에서 우리가 내린 기술적 결정과 그 근거다.

| 결정 사항 | 선택 | 근거 |
|-----------|------|------|
| 프로젝트 구조 | 프론트/백엔드 논리적 분리 | Next.js 안에서 디렉토리로 계층 분리. Chapter 6(백엔드), 7(프론트) 순서대로 개발 |
| 프론트엔드 | React 19 + TypeScript | 타입 안전성으로 AI 생성 코드의 오류를 컴파일 시점에 잡을 수 있음 |
| 스타일링 | Tailwind CSS 4 | 유틸리티 클래스 기반으로 AI가 일관된 스타일 코드를 생성하기 쉬움 |
| 백엔드 | Next.js API Routes (Route Handlers) | Vercel 네이티브 통합, 별도 서버 없이 API 구현, 프론트와 동일 프로젝트에서 관리 |
| ORM | Drizzle ORM | Vercel Postgres 공식 지원, 서버리스 최적화, 코드 생성 단계 불필요 |
| 데이터베이스 | Vercel Postgres (Neon) | Vercel 네이티브 통합, 서버리스 환경 최적화, 무료 티어 제공 |
| 드래그앤드롭 | @dnd-kit/core | React 19 호환, 접근성 지원, 경량 |
| 검증 | Zod | 프론트엔드와 백엔드에서 동일한 검증 스키마 공유 가능 |
| 테스트 | Jest + React Testing Library | TDD에 적합한 테스트 러너와 사용자 관점의 컴포넌트 테스트 |
| 배포 | Vercel | Next.js 최적 배포 환경, Git push로 자동 배포, DB까지 통합 관리 |

### 왜 Next.js API Routes를 선택하는가

Chapter 5.1에서 백엔드 기술 스택으로 Node.js + Express를 소개했다. Express는 가장 널리 사용되는 REST API 프레임워크이고, 학습 자료도 풍부하다. 그렇다면 왜 Tika에서는 Express 대신 Next.js API Routes를 선택했을까?

**첫째, 배포가 극적으로 단순해진다.** Express를 별도 서버로 운영하면 프론트엔드(Vercel)와 백엔드(Railway 등) 두 곳에 배포하고, CORS를 설정하고, 환경 변수로 API 주소를 관리해야 한다. Next.js API Routes를 쓰면 `git push` 한 번으로 프론트엔드와 백엔드가 함께 배포된다. DB도 Vercel Postgres를 쓰면 같은 대시보드에서 관리할 수 있다.

**둘째, 프론트엔드와 백엔드가 같은 프로젝트에 있으면서도 역할 분리가 가능하다.** Next.js의 `app/api/` 디렉토리에 있는 Route Handler는 서버에서만 실행되는 완전한 백엔드 코드다. 브라우저에는 절대 노출되지 않는다. 디렉토리를 `src/server/`와 `src/client/`로 나누면, Express에서 controllers/services를 분리하는 것과 동일한 계층 구조를 만들 수 있다.

**셋째, TypeScript 타입을 가장 자연스럽게 공유할 수 있다.** 같은 프로젝트이므로 별도의 shared 패키지나 workspace 설정 없이 `import { Ticket } from '@/shared/types'`로 바로 사용할 수 있다. Express를 분리하면 npm workspaces나 monorepo 도구가 필요해지는데, 프로젝트 초기에 이런 인프라 설정에 시간을 쓰는 것은 비효율적이다.

**넷째, API Routes는 서버리스 함수로 실행된다.** 각 API 엔드포인트가 독립된 서버리스 함수로 배포되므로, 사용하지 않는 API에는 비용이 발생하지 않는다. Express 서버는 항상 켜져 있어야 하므로 사이드 프로젝트에서는 비용 부담이 될 수 있다.

물론 Express가 더 적합한 상황도 있다. WebSocket이 필요하거나, 복잡한 미들웨어 체인을 구성해야 하거나, 백엔드를 여러 프론트엔드에서 공유해야 한다면 Express를 별도로 운영하는 것이 맞다. Part 3(챗봇 프로젝트)에서는 실시간 스트리밍이 필요하므로 별도 백엔드를 구성하고, 그때 Railway 배포를 다룬다. 하지만 Tika처럼 REST API 수준의 사이드 프로젝트라면 Next.js API Routes가 가장 효율적인 선택이다.

> **Express vs Next.js API Routes**: 
> Express로 별도 백엔드를 운영하면 배포 인프라가 2개, CORS 설정, API 주소 관리 등 부수적인 작업이 생긴다. Next.js API Routes는 이 모든 것을 제거하면서도, 디렉토리 수준에서 프론트/백엔드를 명확히 분리할 수 있다. 도구가 단순해지면 AI와의 협업에서 "진짜 중요한 것"—비즈니스 로직, 테스트, 설계—에 더 집중할 수 있다.

### 프론트/백엔드를 어떻게 분리하는가

"같은 Next.js 프로젝트인데 진짜 분리가 되는 건가?" 좋은 질문이다. 물리적으로 다른 저장소에 있어야만 분리인 것은 아니다. 핵심은 **코드 의존 방향이 명확한가**, **한쪽을 수정할 때 다른 쪽에 영향을 주지 않는가**다.

Tika에서는 디렉토리 구조로 이 분리를 강제한다.

- `app/api/` — 백엔드 진입점 (Route Handlers)
- `src/server/` — 백엔드 로직 (services, db, middleware)  
- `src/client/` — 프론트엔드 로직 (components, hooks, api 호출)
- `src/shared/` — 양쪽에서 사용하는 타입, 검증 스키마, 상수

이 구조에서 `src/server/`의 코드는 `src/client/`를 절대 import하지 않고, `src/client/`의 코드는 `src/server/`를 절대 import하지 않는다. 양쪽 모두 `src/shared/`만 참조한다. 이 규칙만 지켜지면, 논리적으로 Express를 별도 서버로 운영하는 것과 동일한 분리 효과를 얻는다.

Claude Code에게 작업을 요청할 때도 이 분리가 그대로 작동한다. "`src/server/services/`에 티켓 생성 로직을 만들어줘"와 "`src/client/components/`에 폼 컴포넌트를 만들어줘"처럼, 작업 범위가 디렉토리 수준에서 명확해진다.

### 프로젝트 초기 구조

```
tika/
├── app/                              # Next.js App Router
│   ├── api/                          # 백엔드: API Route Handlers
│   │   └── tickets/
│   │       ├── route.ts              # GET /api/tickets, POST /api/tickets
│   │       └── [id]/
│   │           └── route.ts          # GET, PATCH, DELETE /api/tickets/:id
│   │
│   ├── (board)/                      # 프론트엔드: 페이지 그룹
│   │   ├── page.tsx                  # 메인 칸반 보드 페이지
│   │   └── layout.tsx                # 보드 레이아웃
│   ├── layout.tsx                    # 루트 레이아웃
│   └── globals.css                   # 글로벌 스타일 + Tailwind
│
├── src/
│   ├── server/                       # 백엔드 로직 (서버에서만 실행)
│   │   ├── services/
│   │   │   └── ticketService.ts      # 비즈니스 로직
│   │   ├── db/
│   │   │   ├── index.ts              # Drizzle 클라이언트 초기화
│   │   │   ├── schema.ts             # DB 스키마 정의
│   │   │   └── seed.ts               # 시드 데이터
│   │   └── middleware/
│   │       ├── errorHandler.ts       # 에러 처리
│   │       └── validate.ts           # Zod 검증 유틸리티
│   │
│   ├── client/                       # 프론트엔드 로직 (브라우저에서 실행)
│   │   ├── components/
│   │   │   ├── board/
│   │   │   │   ├── Board.tsx         # 칸반 보드 컨테이너 (DnD 컨텍스트)
│   │   │   │   ├── Column.tsx        # 칼럼 (Backlog, TODO 등)
│   │   │   │   └── TicketCard.tsx    # 티켓 카드
│   │   │   ├── ticket/
│   │   │   │   ├── TicketModal.tsx   # 티켓 상세/수정 모달
│   │   │   │   └── TicketForm.tsx    # 티켓 생성 폼
│   │   │   └── ui/
│   │   │       ├── Button.tsx        # 공통 버튼
│   │   │       ├── Modal.tsx         # 공통 모달
│   │   │       ├── Badge.tsx         # 우선순위 뱃지
│   │   │       └── ConfirmDialog.tsx # 확인 다이얼로그
│   │   │
│   │   ├── hooks/
│   │   │   └── useTickets.ts         # 티켓 CRUD + DnD 상태 관리
│   │   └── api/
│   │       └── ticketApi.ts          # API 호출 함수 (fetch 래퍼)
│   │
│   └── shared/                       # 프론트/백엔드 공유 코드
│       ├── types/
│       │   └── index.ts              # Ticket, BoardData, ApiResponse 등
│       ├── validations/
│       │   └── ticket.ts             # Zod 스키마 (프론트 폼 + 백엔드 API 검증)
│       └── constants.ts              # 칼럼명, 우선순위 등 공유 상수
│
├── __tests__/                        # 테스트 코드
│   ├── api/                          # API Route 테스트 (백엔드)
│   │   └── tickets.test.ts
│   ├── services/                     # 서비스 단위 테스트 (백엔드)
│   │   └── ticketService.test.ts
│   ├── components/                   # 컴포넌트 테스트 (프론트엔드)
│   │   ├── Board.test.tsx
│   │   ├── Column.test.tsx
│   │   └── TicketCard.test.tsx
│   └── hooks/                        # Hook 테스트 (프론트엔드)
│       └── useTickets.test.ts
│
├── docs/                             # 프로젝트 문서
│   ├── PRD.md                        # 제품 요구사항
│   ├── TRD.md                        # 기술 요구사항
│   ├── REQUIREMENTS.md               # 상세 요구사항 명세 (FR + NFR + US)
│   ├── API_SPEC.md                   # API 엔드포인트 명세
│   ├── DATA_MODEL.md                 # DB 스키마, ERD, 비즈니스 규칙
│   ├── COMPONENT_SPEC.md             # 컴포넌트 계층, Props, 이벤트 흐름
│   └── TEST_CASES.md                 # TDD용 테스트 케이스 정의
│
├── drizzle/                          # Drizzle 마이그레이션
├── drizzle.config.ts
├── next.config.ts
├── tailwind.config.ts
├── jest.config.ts
├── tsconfig.json
├── package.json
├── CLAUDE.md                         # Claude Code 프로젝트 설정
└── .gitignore
```

이 구조에서 주목할 부분을 하나씩 짚어보자.

**`app/api/`와 `src/server/`의 역할 분리**: `app/api/`는 HTTP 요청을 받고 응답을 보내는 "진입점"이다. Express로 치면 라우터(routes) 역할만 한다. 실제 비즈니스 로직은 `src/server/services/`에 있다. 이렇게 분리하는 이유는 Route Handler를 얇게 유지하기 위해서다. 테스트할 때도 서비스 로직만 단독으로 테스트할 수 있어 테스트가 더 빠르고 명확해진다.

```
요청 흐름:
클라이언트 → app/api/tickets/route.ts (요청 파싱 + 응답)
            → src/server/services/ticketService.ts (비즈니스 로직)
            → src/server/db/schema.ts (Drizzle 쿼리)
```

이 계층 구조는 Express의 Router → Controller → Service → DB와 동일한 원칙이다. 다만 Next.js에서는 Route Handler가 Router와 Controller 역할을 합치고, 비즈니스 로직만 Service로 분리하는 것이 일반적이다.

**`src/shared/`의 중요성**: 프론트엔드와 백엔드가 같은 프로젝트에 있으므로, 타입과 검증 스키마를 자연스럽게 공유할 수 있다. `Ticket` 타입을 `src/shared/types/`에 한 번 정의하면, API Route에서도 컴포넌트에서도 동일한 타입을 사용한다. Zod 스키마도 마찬가지다. 폼 검증과 API 검증에 같은 스키마를 쓰면 프론트-백 간 검증 규칙이 어긋나는 일이 없다.

**`__tests__/`의 분리**: 테스트 디렉토리도 백엔드 테스트(`api/`, `services/`)와 프론트엔드 테스트(`components/`, `hooks/`)로 나뉜다. Chapter 6에서는 `__tests__/api/`와 `__tests__/services/`만 작업하고, Chapter 7에서는 `__tests__/components/`와 `__tests__/hooks/`만 작업한다.

**`docs/` 디렉토리의 역할**: 7개의 문서가 프로젝트의 "진실의 원천(Single Source of Truth)"이 된다. Claude Code에게 기능을 구현해달라고 요청할 때 "API_SPEC.md의 POST /api/tickets 명세를 따라 구현해줘"라고 하면, AI는 문서를 읽고 정확히 그 스펙대로 코드를 생성한다. 문서 없이 "티켓 생성 API 만들어줘"라고 하면 AI가 알아서 필드를 정하고 응답 형식을 결정하는데, 이것이 바로 **요청하지 않은 기능 추가**의 시작점이다.

특히 ORM 선택에서 Prisma 대신 Drizzle을 선택한 이유를 짚고 넘어가자. Prisma는 Node.js ORM의 사실상 표준이지만, `prisma generate`라는 코드 생성 단계가 필요하고 타입스크립트 네이티브가 아니다. Drizzle은 TypeScript로 직접 스키마를 정의하기 때문에 별도의 코드 생성 단계가 없다. 또한 Vercel Postgres와의 공식 통합을 지원하여 서버리스 환경에서 커넥션 풀 관리가 자동으로 처리된다. SQL과 유사한 API를 제공해서 SQL 자체를 이해하는 데도 도움이 된다.

> **실무 팁**: 기술 스택 결정은 Claude Code에게 "뭐가 좋아?"라고 묻기보다, "A와 B 중 우리 프로젝트 조건에서 어떤 것이 나은지 비교해줘"라고 요청하는 것이 훨씬 유용하다. 조건을 명확히 제시하면 AI도 더 정확한 분석을 제공한다.

### Claude Code에게 프로젝트 초기화 요청하기

디렉토리 구조와 기술 스택이 결정되었으면, Claude Code에게 프로젝트 뼈대를 만들도록 요청할 수 있다. Next.js 프로젝트에서는 초기화가 비교적 단순하지만, 디렉토리 구조의 규칙을 명확히 전달하는 것이 중요하다.

```
CLAUDE.md를 읽고 프로젝트 컨텍스트를 파악한 뒤, 
다음 순서로 프로젝트를 초기화해줘:

1. Next.js 프로젝트가 올바르게 설정되어 있는지 확인
2. src/shared/의 타입과 Zod 스키마가 DATA_MODEL.md와 일치하는지 확인
3. src/server/db/의 Drizzle 설정이 Vercel Postgres에 맞게 되어 있는지 확인
4. app/api/ 디렉토리에 tickets 라우트 구조가 API_SPEC.md와 일치하는지 확인
5. src/client/components/의 구조가 COMPONENT_SPEC.md와 일치하는지 확인
6. 테스트 환경(Jest)이 올바르게 설정되어 있는지 확인
7. 확인 결과를 보고해줘. 불일치하는 부분이 있으면 수정하지 말고 먼저 알려줘.
```

여기서 핵심은 마지막 문장이다. **"수정하지 말고 먼저 알려줘."** Claude Code는 기본적으로 문제를 발견하면 즉시 수정하려는 경향이 있다. 그런데 초기 설정 단계에서 AI가 알아서 수정하면 개발자가 무엇이 바뀌었는지 파악하기 어렵다. 특히 DB 스키마나 설정 파일은 한 번 잘못되면 나중에 전체 코드에 영향을 주므로, 반드시 개발자가 확인한 뒤 수정 여부를 결정해야 한다.

### CLAUDE.md 작성: AI에게 프로젝트 규칙 전달하기

CLAUDE.md는 Chapter 2.7에서 상세히 다루었지만, 실제 프로젝트에 적용할 때 어떤 내용을 넣어야 하는지 Tika 프로젝트를 예로 살펴보자. Next.js 프로젝트에서 프론트/백엔드를 논리적으로 분리할 때, 각 디렉토리의 역할과 경계를 명확히 기술하는 것이 핵심이다.

```markdown
# CLAUDE.md - Tika Project

## 프로젝트 개요
Tika는 티켓 기반 칸반 보드 TODO 앱이다.
Next.js App Router 기반으로, 프론트엔드와 백엔드를 디렉토리 수준에서 분리한다.
src/shared/에서 타입과 검증 스키마를 공유한다.

## 프로젝트 구조
- app/api/       : 백엔드 진입점 (Route Handlers, 요청 파싱 + 응답만)
- src/server/    : 백엔드 로직 (services, db, middleware)
- src/client/    : 프론트엔드 로직 (components, hooks, api 호출)
- src/shared/    : 공유 타입, Zod 스키마, 상수
- docs/          : 프로젝트 명세 문서

## 기술 스택
- Framework: Next.js 15 (App Router)
- Language: TypeScript (strict mode)
- Frontend: React 19
- Styling: Tailwind CSS 4
- Drag & Drop: @dnd-kit/core + @dnd-kit/sortable
- ORM: Drizzle ORM
- DB: Vercel Postgres (Neon)
- Validation: Zod
- Testing: Jest + React Testing Library
- Deployment: Vercel

## 프로젝트 문서 (반드시 참조)
- 제품 요구사항: /docs/PRD.md
- 기술 요구사항: /docs/TRD.md
- 상세 요구사항: /docs/REQUIREMENTS.md
- API 명세: /docs/API_SPEC.md
- 데이터 모델: /docs/DATA_MODEL.md
- 컴포넌트 명세: /docs/COMPONENT_SPEC.md
- 테스트 케이스: /docs/TEST_CASES.md

## 코딩 컨벤션

### TypeScript (공통)
- strict 모드 사용
- any 사용 금지, unknown 사용 후 타입 가드
- 인터페이스는 I 접두사 없이 명사로 (예: Ticket, BoardData)
- enum 대신 const 객체 + typeof 패턴 사용
- 공유 타입은 반드시 @/shared/types에서 import

### 백엔드 (app/api/ + src/server/)
- Route Handler는 얇게: 요청 파싱 → 서비스 호출 → 응답 반환
- 비즈니스 로직은 src/server/services/에 작성
- Zod로 요청 검증 (shared/validations에서 import)
- 에러 응답 형식 통일: { error: { code, message } }
- HTTP 상태 코드: 200, 201, 204, 400, 404, 500
- DB 쿼리는 Drizzle ORM으로만 작성 (raw SQL 금지)

### 프론트엔드 (src/client/)
- 함수 컴포넌트 + 화살표 함수
- Props 타입은 컴포넌트 파일 내 정의
- API 호출은 src/client/api/ticketApi.ts를 통해서만
- 파일명: PascalCase (예: TicketCard.tsx)

## 개발 규칙

### 반드시 지켜야 할 것
- 새 기능 구현 전 TEST_CASES.md의 해당 테스트부터 작성
- API 구현 시 API_SPEC.md의 명세를 정확히 따르기
- 컴포넌트 구현 시 COMPONENT_SPEC.md의 Props와 동작 준수
- 타입 변경 시 src/shared/types 먼저 수정

### 하지 말아야 할 것
- 명세에 없는 기능 임의 추가 금지
- 테스트 코드 삭제 또는 skip 금지
- any 타입 사용 금지
- console.log 커밋 금지 (디버깅 후 제거)
- src/client/에서 직접 DB 접근 금지
- src/server/에서 React 관련 코드 작성 금지

### 경계 규칙
- 백엔드 작업 시(app/api/, src/server/) 프론트엔드(src/client/) 코드 수정 금지
- 프론트엔드 작업 시(src/client/) 백엔드(app/api/, src/server/) 코드 수정 금지
- 양쪽에 영향을 주는 변경은 src/shared/ 먼저 수정 후 각각 반영
```

기존 CLAUDE.md에서 추가된 핵심은 **경계 규칙** 섹션이다. 같은 Next.js 프로젝트 안에 있으므로 물리적으로는 아무 파일이나 import할 수 있다. 그래서 Claude Code가 "백엔드 API의 응답 형식을 바꿨으니 프론트엔드도 함께 수정했습니다" 같은 행동을 하기 쉽다. 의도는 좋지만, 한 번에 두 계층을 수정하면 문제가 생겼을 때 원인을 찾기 어렵다. 반드시 한 쪽을 완료하고, 다른 쪽을 별도로 수정해야 한다.


## 4.5.2 개발 문서 작성: PRD, TRD, REQUIREMENTS.md 작성하기

AI와 협업하는 개발에서 문서는 단순한 기록이 아니다. **Claude Code가 참조하는 명세서**이자, **코드 생성의 기준점**이다. 문서가 없으면 AI는 매번 새로운 맥락에서 코드를 생성하고, 개발자는 그 결과가 이전 코드와 일관성이 있는지 일일이 확인해야 한다. 문서가 있으면 AI는 항상 같은 기준을 따르고, 개발자는 문서와의 일치 여부만 확인하면 된다.

Tika 프로젝트에서 사용하는 문서 체계를 살펴보자.

### 문서 체계 구성

```
docs/
├── PRD.md              # 제품 요구사항: "무엇을" 만드는가
├── TRD.md              # 기술 요구사항: "어떻게" 만드는가
├── REQUIREMENTS.md     # 상세 요구사항: FR + NFR + US 통합 명세
├── API_SPEC.md         # API 엔드포인트 명세
├── DATA_MODEL.md       # DB 스키마, ERD, 비즈니스 규칙
├── COMPONENT_SPEC.md   # 컴포넌트 계층, Props, 이벤트 흐름
└── TEST_CASES.md       # TDD용 테스트 케이스 정의
```

각 문서의 역할과 Claude Code가 이를 어떻게 활용하는지를 표로 정리하면 다음과 같다.

| 문서 | 역할 | Claude Code 활용 |
|------|------|-----------------|
| PRD.md | 제품이 "무엇"을 해야 하는지 정의 | 기능 구현 시 목적과 맥락 이해 |
| TRD.md | "어떻게" 구현할지 기술적 명세 | 아키텍처 결정, 기술 스택 확인 |
| REQUIREMENTS.md | FR, NFR, US를 한곳에 통합 | 구현 범위와 제약 조건 확인 |
| API_SPEC.md | REST API 엔드포인트 상세 명세 | 백엔드 API 구현의 기준 |
| DATA_MODEL.md | DB 스키마, 관계, 비즈니스 규칙 | 쿼리 작성과 데이터 구조 이해 |
| COMPONENT_SPEC.md | UI 컴포넌트 계층과 Props 정의 | 프론트엔드 구현 가이드 |
| TEST_CASES.md | 테스트 시나리오와 기대 결과 | TDD 사이클의 시작점 |

### PRD (Product Requirements Document) 작성

PRD는 제품이 "무엇을" 해야 하는지를 정의한다. Claude Code에게 PRD를 작성하도록 요청할 때, 다음과 같은 프롬프트가 효과적이다.

```
Tika 프로젝트의 PRD를 작성해줘. 다음 정보를 포함해야 해:

1. 제품 개요: Tika는 티켓 기반 칸반 보드 TODO 앱
2. MVP 범위: 단일 사용자, 고정 4칼럼(Backlog/TODO/In Progress/Done), 
   티켓 CRUD, 드래그앤드롭
3. 2차 제외 범위: 인증, 커스텀 칼럼, 멀티사용자, 라벨/코멘트
4. 사용자 시나리오: 할 일 등록 → 상태 이동 → 수정/삭제 → 완료 확인
5. 핵심 기능 목록: FR-001~007과 대응하는 기능 설명
6. 기술 스택 요약표: 선정 이유 포함
7. 와이어프레임 참고: 좌측 Backlog 사이드바 + 우측 3칼럼 보드 레이아웃

형식은 마크다운으로, /docs/PRD.md에 저장해줘.
```

Claude Code가 생성한 PRD를 검토할 때 확인해야 할 핵심 포인트는 다음과 같다.

**범위가 명확한가?** "포함/제외" 표가 있어야 한다. 이것이 없으면 나중에 AI가 2차 기능(인증, 라벨 등)을 슬그머니 구현하는 상황이 생긴다.

**사용자 시나리오가 구체적인가?** "사용자가 할 일을 추가한다"처럼 추상적이면 안 된다. "보드 상단의 '새 티켓' 버튼을 클릭 → 제목 입력 → '생성' 클릭 → Backlog 칼럼에 카드 추가"처럼 단계별로 기술해야 한다.

**기술 스택에 "선정 이유"가 있는가?** 단순히 "Drizzle ORM 사용"이 아니라 "TypeScript 네이티브, 코드 생성 불필요, Vercel Postgres 공식 지원"처럼 이유가 명시되어야 나중에 기술 변경 여부를 판단할 수 있다.

### TRD (Technical Requirements Document) 작성

TRD는 "어떻게" 구현할지 기술적으로 명세한다. 시스템 아키텍처, 디렉토리 구조, 데이터 흐름, 성능 기준 등을 담는다. PRD가 "이런 기능이 필요하다"고 정의했다면, TRD는 "그 기능을 이 구조로 만든다"를 정의한다.

TRD의 핵심은 **아키텍처와 데이터 흐름**이다. Tika의 아키텍처를 한눈에 보면 다음과 같다.

```
┌──────────────────────────────────────────────────┐
│                     Vercel                        │
│                                                   │
│  ┌─────────────────┐   ┌──────────────────────┐  │
│  │                 │   │                      │  │
│  │  Next.js App    │   │   API Routes         │  │
│  │  (React 19)     │──▶│   (Route Handlers)   │  │
│  │  - 페이지       │   │   - /api/tickets     │  │
│  │  - 컴포넌트     │   │   - /api/tickets/:id │  │
│  │                 │   │                      │  │
│  └─────────────────┘   └──────────┬───────────┘  │
│                                   │               │
│                        ┌──────────▼───────────┐  │
│                        │  Drizzle ORM         │  │
│                        └──────────┬───────────┘  │
│                                   │               │
│                        ┌──────────▼───────────┐  │
│                        │  Vercel Postgres      │  │
│                        │  (Neon)               │  │
│                        └──────────────────────┘  │
│                                                   │
└──────────────────────────────────────────────────┘
```

**모든 것이 Vercel 하나에서 실행된다.** 프론트엔드는 Edge Network에서 정적 파일로 서빙되고, API Routes는 서버리스 함수로 실행되며, 데이터베이스도 Vercel Postgres(Neon 기반)를 사용한다. `git push` 한 번으로 전체가 배포되고, CORS 설정이나 별도 서버 관리가 필요 없다.

TRD에서 특히 중요한 섹션은 **데이터 흐름**과 **DB 연결 방식**이다.

**데이터 흐름**: 프론트엔드 컴포넌트가 `src/client/api/ticketApi.ts`를 통해 `/api/tickets`를 호출하면, Next.js가 이를 `app/api/tickets/route.ts`의 Route Handler로 라우팅한다. Route Handler는 `src/server/services/ticketService.ts`를 호출하고, 서비스는 Drizzle ORM을 통해 Vercel Postgres에 쿼리를 실행한다. 같은 프로젝트 내부이므로 CORS 설정이 필요 없고, 프론트-백 간 통신이 자연스럽다.

```typescript
// src/client/api/ticketApi.ts
export const fetchTickets = async () => {
  const res = await fetch('/api/tickets');
  return res.json();
};
```

```typescript
// app/api/tickets/route.ts
import { NextResponse } from 'next/server';
import { ticketService } from '@/server/services/ticketService';

export async function GET() {
  const tickets = await ticketService.getAll();
  return NextResponse.json(tickets);
}
```

**DB 연결**: Drizzle과 Vercel Postgres를 연결한다. `@vercel/postgres` 패키지가 서버리스 환경에서의 커넥션 풀을 자동으로 관리해준다.

```typescript
// src/server/db/index.ts
import { drizzle } from 'drizzle-orm/vercel-postgres';
import { sql } from '@vercel/postgres';

export const db = drizzle(sql);
```

로컬 개발 환경에서는 `.env.development.local`에 Vercel Postgres 연결 문자열을 설정한다. `vercel env pull` 명령으로 Vercel에 설정된 환경 변수를 로컬로 가져올 수 있다.

### TRD (Technical Requirements Document) 프롬프트와 검토

TRD를 Claude Code와 함께 작성할 때는 PRD와 접근법이 다르다. PRD는 "무엇을"에 집중하므로 기능 목록과 사용자 시나리오를 전달하면 되지만, TRD는 "어떻게"에 집중하므로 **개발자가 이미 내린 기술적 결정**을 명확히 전달해야 한다. 기술 선택을 AI에게 맡기면 대화할 때마다 다른 아키텍처가 나올 수 있다.

```
Tika 프로젝트의 TRD를 작성해줘. 다음 정보를 포함해야 해:

1. 시스템 아키텍처
   - 전체 구조: Vercel 단일 배포 (Next.js App Router + API Routes + Vercel Postgres)
   - 아키텍처 다이어그램: 프론트엔드 → Route Handler → Service → Drizzle → DB 흐름
   - 디렉토리 구조: app/api/(진입점), src/server/(백엔드 로직), 
     src/client/(프론트 로직), src/shared/(공유 타입)

2. 기술 스택 상세
   - 각 기술의 버전, 선정 이유, 대안 비교 (예: Drizzle vs Prisma)
   - 프레임워크: Next.js 15 (App Router)
   - 런타임: Node.js (Vercel Serverless Functions)
   - ORM: Drizzle ORM (Vercel Postgres 공식 지원, 코드 생성 불필요)
   - DB: Vercel Postgres (Neon 기반, 서버리스 커넥션 풀 자동 관리)

3. 데이터 흐름
   - 읽기 흐름: 컴포넌트 → ticketApi.ts → /api/tickets → ticketService → DB
   - 쓰기 흐름: 폼 → Zod 검증 → ticketApi.ts → /api/tickets → ticketService → DB
   - 드래그앤드롭: 낙관적 업데이트 → PATCH /api/tickets/:id → position 재계산

4. 계층 간 경계 규칙
   - src/server/ ↔ src/client/ 상호 import 금지
   - src/shared/만 양쪽에서 참조 가능
   - Route Handler는 얇게 유지: 요청 파싱 → 서비스 호출 → 응답 반환

5. 개발 환경 설정
   - 로컬 DB: vercel env pull로 환경 변수 가져오기
   - 테스트: Jest + React Testing Library
   - Lint: ESLint + Prettier

6. 배포 전략
   - Vercel 자동 배포 (main 브랜치 push)
   - Preview 배포 (PR 생성 시)
   - 환경 변수: Vercel Dashboard에서 관리

형식은 마크다운으로, /docs/TRD.md에 저장해줘.
PRD.md의 기능 목록 및 기술 스택 요약표와 일치하는지 확인해줘.
```

Claude Code가 생성한 TRD를 검토할 때 확인해야 할 핵심 포인트는 다음과 같다.

**아키텍처 다이어그램이 실제 디렉토리 구조와 일치하는가?** 다이어그램에서 "Service Layer"라고 표시했으면 실제로 `src/server/services/` 디렉토리가 존재해야 한다. AI가 다이어그램을 그릴 때 실제 프로젝트에 없는 계층을 추가하는 경우가 있다. "API Gateway"나 "Cache Layer" 같은 것이 슬그머니 들어가 있으면 제거해야 한다.

**데이터 흐름에 빠진 단계가 없는가?** 특히 Zod 검증 단계가 누락되기 쉽다. 프론트엔드 폼에서의 클라이언트 검증과 Route Handler에서의 서버 검증, 이 두 단계가 모두 명시되어야 한다. 검증 스키마가 `src/shared/validations/`에서 공유된다는 점도 기술되어야 한다.

**경계 규칙이 구체적인가?** "프론트와 백엔드를 분리한다"처럼 추상적이면 안 된다. "src/server/에서 src/client/를 import하면 안 된다", "Route Handler 안에 비즈니스 로직을 넣지 않는다"처럼 검증 가능한 수준으로 기술해야 한다. 이 규칙은 CLAUDE.md의 경계 규칙과도 일치해야 한다.

**배포 구성이 현실적인가?** AI가 "Docker + Kubernetes + CI/CD 파이프라인"처럼 과도한 인프라를 제안하는 경우가 있다. Tika는 사이드 프로젝트이므로 Vercel 자동 배포 하나면 충분하다. 복잡한 인프라는 Part 3에서 다룬다.

> **PRD와 TRD의 관계**: PRD가 "이 제품은 무엇을 하는가"라면, TRD는 "그것을 어떤 구조로 만드는가"다. 두 문서를 분리하는 이유는 Claude Code에게 작업을 요청할 때 "지금 필요한 맥락"만 전달하기 위해서다. 기능을 구현할 때는 PRD와 API_SPEC.md를, 아키텍처를 검토할 때는 TRD를 참조하도록 하면 컨텍스트 윈도우를 효율적으로 사용할 수 있다.

### REQUIREMENTS.md: 모든 요구사항의 통합 명세

REQUIREMENTS.md는 4.2절~4.4절에서 정의한 FR, NFR, US를 하나의 문서로 통합한 것이다. 이 문서가 CLAUDE.md에서 참조되면, Claude Code는 어떤 기능을 구현하든 이 명세를 기준으로 작업한다.

REQUIREMENTS.md의 핵심 구조는 다음과 같다.

```markdown
# Tika - 요구사항 명세

## 1. 기능 요구사항 (Functional Requirements)
### FR-001: 티켓 생성
- 입력 필드 테이블 (타입, 필수 여부, 제약 조건, 기본값)
- 처리 규칙 (초기 상태, position 계산 방식)
- API 매핑: POST /api/tickets
- 검증 에러 메시지 (한국어)

### FR-002: 티켓 목록 조회 (보드 뷰)
...

## 2. 비기능 요구사항 (Non-Functional Requirements)
### NFR-001: 성능
- API 응답 시간: p95 200ms 이하
- 보드 초기 로드: 2초 이내
...

## 3. 사용자 스토리 (User Stories)
### US-001: 새 할 일 등록
> 사용자로서, 떠오른 할 일을 빠르게 등록할 수 있다.
> 그래서 아이디어가 떠오르는 즉시 기록하여 잊어버리지 않는다.
- 인수 조건 (Acceptance Criteria) 체크리스트
- 관련 FR 매핑
...

## 4. 추적 매트릭스 (US ↔ FR ↔ TC 매핑)
```

여기서 **추적 매트릭스(Traceability Matrix)**가 특히 중요하다. 사용자 스토리, 기능 요구사항, 테스트 케이스가 어떻게 연결되는지를 한눈에 보여주는 표다.

| 사용자 스토리 | 관련 FR | 관련 테스트 케이스 |
|--------------|---------|-------------------|
| US-001: 새 할 일 등록 | FR-001 | TC-API-001, TC-COMP-004 |
| US-002: 상세 정보 설정 | FR-001 | TC-API-001 |
| US-003: 칸반 보드 현황 파악 | FR-002 | TC-API-002, TC-COMP-002, TC-COMP-003 |
| US-004: 마감 초과 인지 | FR-007 | TC-API-002, TC-COMP-001 |
| US-005: 드래그앤드롭 상태 변경 | FR-006 | TC-API-006, TC-INT-001 |
| US-006: 할 일 완료 처리 | FR-006 | TC-API-006, TC-INT-001 |
| US-007: 할 일 수정 | FR-003, FR-004 | TC-API-003, TC-API-004, TC-COMP-005 |
| US-008: 할 일 삭제 | FR-005 | TC-API-005, TC-COMP-006 |

이 매핑이 있으면 "US-005(드래그앤드롭)를 구현해줘"라고 요청했을 때, Claude Code는 FR-006의 명세를 따르고 TC-API-006과 TC-INT-001의 테스트를 통과하는 코드를 작성해야 한다는 것을 알 수 있다. 문서 간의 연결 고리가 AI의 작업 범위를 정확히 한정한다.

### Claude Code와 함께 문서 작성하기: 대화 예시

문서를 처음부터 끝까지 AI에게 맡기는 것은 위험하다. 대신, 개발자가 뼈대를 잡고 AI가 살을 붙이는 방식이 효과적이다. 실제 대화 흐름을 보자.

**1단계: 뼈대 전달**

```
REQUIREMENTS.md를 작성하려고 해. 아래 구조로 작성해줘.

기능 요구사항:
- FR-001: 티켓 생성 (title 필수 1~200자, description 선택 1000자, 
  priority LOW/MEDIUM/HIGH 기본 MEDIUM, dueDate 오늘 이후)
- FR-002: 보드 조회 (4칼럼별 티켓 목록, position 정렬)
- FR-003: 티켓 상세 조회
- FR-004: 티켓 수정
- FR-005: 티켓 삭제 (확인 후 hard delete)
- FR-006: 드래그앤드롭 상태/순서 변경 (낙관적 업데이트)
- FR-007: 오버듀 판정 (마감일 초과 + Done 아닌 경우)

각 FR에 입력 필드 테이블, 처리 규칙, API 매핑, 검증 에러 메시지를 포함해줘.
검증 에러 메시지는 한국어로 작성해줘.
```

**2단계: 결과 검토 후 수정 요청**

```
FR-006의 position 재계산 로직이 빠졌어.
두 카드 사이에 삽입할 때 (prev + next) / 2로 계산하고,
간격이 1 미만이면 해당 칼럼 전체를 1024 간격으로 재정렬하는 규칙을 추가해줘.
```

**3단계: 다른 문서와의 정합성 확인**

```
지금 작성한 REQUIREMENTS.md의 FR-001 필드 정의가 
API_SPEC.md의 POST /api/tickets 요청 바디와 일치하는지 확인해줘.
불일치하는 부분이 있으면 어떤 문서를 수정해야 하는지 제안해줘.
```

이런 식으로 3단계를 거치면 문서 간의 일관성이 유지된다. 특히 3단계가 중요한데, 문서가 여러 개이다 보면 A 문서를 수정하면서 B 문서와 어긋나는 경우가 빈번하다. Claude Code에게 "교차 검증"을 요청하는 습관을 들이면 이런 문제를 사전에 방지할 수 있다.


## 4.5.3 TDD 방식의 개발 흐름

문서 체계가 갖춰졌으면 이제 실제 개발을 시작할 차례다. Tika 프로젝트에서는 TDD(Test-Driven Development) 방식을 따른다. 왜 AI 시대에 TDD가 더 중요해졌는지는 Chapter 3.6에서 상세히 다루었으므로, 여기서는 실제로 Claude Code와 TDD 사이클을 돌리는 구체적인 흐름에 집중한다.

### Red-Green-Refactor 사이클

TDD의 핵심은 세 단계의 반복이다.

```
Red   → 실패하는 테스트 작성
  ↓
Green → 테스트를 통과하는 최소 구현
  ↓
Refactor → 코드 개선 (테스트는 유지)
  ↓
반복
```

각 사이클은 **5~10분 이내**로 짧게 가져가야 한다. 한 번에 하나의 기능에 집중해서 완성하는 것이 원칙이다. AI와 함께할 때도 이 원칙은 동일하다. 오히려 AI가 한 번에 많은 코드를 생성하려는 경향이 있기 때문에, 개발자가 더 의식적으로 사이클을 짧게 끊어야 한다.

### 실제 개발 흐름: 티켓 생성 API 예시

Tika의 첫 번째 기능으로 티켓 생성 API(FR-001)를 TDD로 구현하는 과정을 따라가보자. Next.js 프로젝트에서도 **백엔드 API부터 시작**하는 것은 동일하다.

**Step 1: 명세 확인**

개발을 시작하기 전에 관련 문서를 확인한다. Claude Code에게 이렇게 요청한다.

```
FR-001(티켓 생성)을 구현하려고 해.
API_SPEC.md에서 POST /api/tickets의 명세를 확인하고,
TEST_CASES.md에서 TC-API-001의 테스트 시나리오를 읽어줘.
구현에 필요한 핵심 사항을 정리해줘.
```

Claude Code는 두 문서를 교차 참조하여 다음과 같은 핵심 사항을 정리해줄 것이다.

- 요청 필드: title(필수, 1~200자), description(선택, 1000자), priority(LOW/MEDIUM/HIGH, 기본 MEDIUM), dueDate(오늘 이후)
- 성공 응답: 201 Created + 생성된 티켓 데이터
- 검증 실패: 400 Bad Request + 에러 메시지
- 테스트 시나리오: 정상 생성, 제목 누락, 200자 초과, 과거 마감일 등 6개 케이스

**Step 2: Red — 실패하는 테스트 작성**

```
TC-API-001의 테스트 시나리오를 기반으로
__tests__/api/tickets.test.ts에 티켓 생성 API 테스트를 작성해줘.

조건:
- 아직 API가 구현되지 않았으므로 테스트는 전부 실패해야 함
- 테스트 케이스 목록:
  1. 모든 필드를 포함한 정상 생성 → 201
  2. 제목만으로 최소 생성 → 201, priority가 MEDIUM
  3. 제목 누락 → 400, "제목을 입력해주세요"
  4. 제목 200자 초과 → 400
  5. 과거 마감일 → 400
  6. 잘못된 우선순위 값 → 400
- API_SPEC.md의 요청/응답 형식을 정확히 따라줘
- 테스트 코드만 작성하고, 구현 코드는 건드리지 마
- 작업 범위: __tests__/api/ 디렉토리만
```

마지막 두 줄이 핵심이다. **"테스트 코드만 작성하고, 구현 코드는 건드리지 마"**와 **"작업 범위: __tests__/api/ 디렉토리만"**. Claude Code는 테스트를 작성하면서 동시에 구현 코드도 만들려는 경향이 있다. TDD의 Red 단계에서는 테스트만 있어야 하므로 이를 명시적으로 제한한다.

테스트를 실행하면 당연히 전부 실패한다.

```bash
npm test -- __tests__/api/tickets.test.ts

# 결과: 6 failed, 0 passed
```

이것이 정상이다. Red 단계에서 테스트가 통과하면 오히려 문제가 있는 것이다.

**Step 3: Green — 테스트를 통과하는 최소 구현**

```
방금 작성한 티켓 생성 API 테스트를 모두 통과하도록 구현해줘.

구현 위치:
- Route Handler: app/api/tickets/route.ts의 POST 함수
- 서비스: src/server/services/ticketService.ts의 create 함수
- 검증: src/shared/validations/ticket.ts의 createTicketSchema (Zod)
- DB 스키마: src/server/db/schema.ts의 tickets 테이블

조건:
- 테스트가 통과하는 최소한의 코드만 작성해줘
- 에러 핸들링이나 로깅 같은 추가 기능은 넣지 마
- 테스트 코드는 수정하지 마
- 작업 범위: app/api/, src/server/, src/shared/ 디렉토리만
```

"최소한의 코드만 작성해줘"와 "테스트 코드는 수정하지 마"가 Green 단계의 핵심 원칙이다. AI는 "더 나은" 코드를 만들려고 불필요한 에러 핸들링을 추가하거나, 테스트가 통과하도록 테스트 자체를 수정하는 경우가 있다. 이 두 가지를 명시적으로 차단한다.

"작업 범위"도 중요하다. 이 단계에서는 API Route, 서비스 로직, 공유 스키마만 작업하고, 프론트엔드 코드(`src/client/`)는 건드리지 않는다.

```bash
npm test -- __tests__/api/tickets.test.ts

# 결과: 6 passed, 0 failed ✅
```

모든 테스트가 통과하면 Green 단계 완료다.

**Step 4: Refactor — 코드 개선**

```
티켓 생성 API의 구현 코드를 리뷰하고, 
다음 관점에서 개선할 부분이 있으면 제안해줘:

1. 코드 중복이 있는가?
2. 네이밍이 명확한가?
3. 에러 메시지가 REQUIREMENTS.md의 명세와 일치하는가?
4. TypeScript 타입이 올바르게 적용되어 있는가?
5. Route Handler가 얇은가? (비즈니스 로직이 서비스에 분리되어 있는가)

단, 테스트는 수정하지 마. 리팩토링 후에도 테스트가 통과해야 해.
```

5번이 Next.js 프로젝트에서 중요한 리뷰 포인트다. Route Handler 안에 모든 로직을 넣어버리면 테스트하기 어렵고, 코드가 비대해진다. Route Handler는 요청 파싱과 응답 반환만 담당하고, 비즈니스 로직은 반드시 `src/server/services/`에 분리되어야 한다. AI가 Route Handler 안에 모든 것을 넣으려는 경향이 있는데, 이 단계에서 잡아야 한다.

### 전체 개발 사이클 요약

하나의 기능을 완성하는 전체 흐름을 정리하면 다음과 같다.

```
1. 명세 확인     → API_SPEC.md + TEST_CASES.md 교차 확인
2. Red           → 테스트 작성 (구현 코드 없음)
3. 테스트 실행    → 전부 실패 확인
4. Green         → 최소 구현 (테스트 코드 수정 금지)
5. 테스트 실행    → 전부 통과 확인
6. Refactor      → 코드 개선 (테스트 통과 유지)
7. 테스트 실행    → 전부 통과 재확인
8. 다음 기능으로  → Step 1로 돌아감
```

이 사이클을 Tika의 주요 기능에 적용하면 다음과 같은 순서로 개발이 진행된다. **Chapter 6(백엔드)**에서 1~6번을, **Chapter 7(프론트엔드)**에서 7~12번을 다룬다.

| 순서 | 기능 | 관련 FR | 테스트 케이스 | 작업 범위 |
|------|------|---------|--------------|-----------|
| 1 | 티켓 생성 API | FR-001 | TC-API-001 | app/api/, src/server/ |
| 2 | 보드 조회 API | FR-002 | TC-API-002 | app/api/, src/server/ |
| 3 | 티켓 상세 조회 API | FR-003 | TC-API-003 | app/api/, src/server/ |
| 4 | 티켓 수정 API | FR-004 | TC-API-004 | app/api/, src/server/ |
| 5 | 티켓 삭제 API | FR-005 | TC-API-005 | app/api/, src/server/ |
| 6 | 순서/상태 변경 API | FR-006 | TC-API-006 | app/api/, src/server/ |
| 7 | TicketCard 컴포넌트 | — | TC-COMP-001 | src/client/ |
| 8 | Column 컴포넌트 | — | TC-COMP-002 | src/client/ |
| 9 | Board 컴포넌트 | — | TC-COMP-003 | src/client/ |
| 10 | TicketForm 컴포넌트 | — | TC-COMP-004 | src/client/ |
| 11 | TicketModal 컴포넌트 | — | TC-COMP-005 | src/client/ |
| 12 | 드래그앤드롭 통합 | FR-006 | TC-INT-001 | src/client/ |

백엔드 API를 먼저 완성한 후 프론트엔드 컴포넌트를 개발하는 순서다. "작업 범위" 칼럼이 보여주듯, 각 작업이 어떤 디렉토리에서 이루어지는지가 명확하다. 1~6번은 `app/api/`와 `src/server/`만, 7~12번은 `src/client/`만 건드린다. 이 경계를 지키면 한쪽 작업이 다른 쪽에 영향을 주는 일을 방지할 수 있다.

### AI가 TDD 사이클을 무시할 때

Claude Code와 TDD를 진행하다 보면, AI가 사이클을 깨뜨리는 상황이 종종 발생한다. 대표적인 패턴과 대응법을 알아두면 유용하다.

**패턴 1: 테스트와 구현을 동시에 작성하려 함**

```
# AI의 응답: "테스트와 함께 구현 코드도 작성했습니다."

# 대응:
구현 코드는 되돌려줘. Red 단계에서는 테스트만 있어야 해.
테스트가 실패하는 것을 먼저 확인하고 싶어.
```

**패턴 2: 테스트를 통과시키기 위해 테스트를 수정함**

```
# AI의 응답: "테스트의 기대값이 명세와 맞지 않아 수정했습니다."

# 대응:
테스트가 맞는지 명세가 맞는지 먼저 확인하자.
TEST_CASES.md의 TC-API-001-3 시나리오와 비교해봐.
테스트가 틀렸으면 테스트를 수정하고,
명세가 틀렸으면 REQUIREMENTS.md를 먼저 수정한 후 테스트를 다시 작성해.
```

**패턴 3: "더 나은" 코드를 위해 불필요한 기능을 추가함**

```
# AI의 응답: "로깅과 에러 추적 미들웨어도 함께 추가했습니다."

# 대응:
로깅과 미들웨어는 제거해줘. 
Green 단계에서는 테스트를 통과하는 최소 코드만 필요해.
추가 기능은 별도 사이클에서 다룰 거야.
```

**패턴 4: 다른 계층의 코드를 함께 수정함**

```
# AI의 응답: "API 응답 형식을 변경하면서 
# src/client/api/ticketApi.ts도 함께 업데이트했습니다."

# 대응:
프론트엔드 변경은 되돌려줘. 
지금은 백엔드(app/api/, src/server/) 작업만 하고 있어.
프론트엔드는 백엔드 API가 완성된 후 별도로 작업할 거야.
```

패턴 4는 특히 같은 프로젝트 안에 코드가 있을 때 발생하기 쉽다. 물리적으로 분리된 저장소라면 아예 접근이 불가능하지만, Next.js 프로젝트에서는 `import`만 바꾸면 아무 파일이나 수정할 수 있다. 그래서 CLAUDE.md의 "경계 규칙"이 더 중요하다. 논리적 분리는 도구가 아니라 **규칙**으로 강제하는 것이다.

이런 대응이 귀찮게 느껴질 수 있지만, 초기에 이 습관을 잡아두면 프로젝트가 커져도 코드가 관리 가능한 상태로 유지된다. AI가 생성하는 코드의 양이 많아질수록 TDD의 가치는 더 커진다. 테스트가 없으면 AI의 코드가 기존 기능을 깨뜨렸는지 알 방법이 없기 때문이다.

### 화면 구성과 개발 계획

다음 장에서 본격적인 개발에 들어가기 전에, Tika의 화면 구성을 확인해두자. 아래 와이어프레임은 칸반 보드의 전체 레이아웃을 보여준다.

[그림 4-1] Tika 칸반 보드 와이어프레임

화면은 크게 세 영역으로 구성된다.

**상단 영역**: 검색창과 "새 업무" 버튼이 위치한다. "이번주 업무"와 "일정이 초과된 업무" 필터 버튼도 여기에 배치된다.

**좌측 사이드바 — 할일 목록 영역(Backlog)**: 아직 일정이 잡히지 않은 할 일 카드가 쌓인다. 각 카드에는 제목, 설명, 중요도 뱃지, 완료표기일이 표시된다. 이 영역은 "내 할 일 저장소" 역할을 한다.

**우측 메인 보드 — TODO / In Progress / Done**: 세 개의 칼럼이 나란히 배치된다. Backlog에서 카드를 드래그해 TODO로 옮기면 "이번 주 할 일"이 되고, In Progress로 옮기면 "지금 진행 중", Done으로 옮기면 "완료"가 된다. 각 칼럼의 카드에도 중요도와 완료표기일이 표시된다.

이 와이어프레임이 실제 컴포넌트 구조로 어떻게 매핑되는지는 Chapter 6(백엔드 개발)과 Chapter 7(프론트엔드 개발)에서 하나씩 구현해 나갈 것이다. 지금 중요한 것은 **와이어프레임이 곧 COMPONENT_SPEC.md의 근거**가 된다는 점이다. 화면의 각 영역이 어떤 컴포넌트에 대응하는지, 각 컴포넌트가 어떤 데이터를 받고 어떤 이벤트를 발생시키는지가 명세의 출발점이다.

---

이번 절에서 다룬 내용을 정리하면 다음과 같다.

**4.5.1**: 기술 스택은 개발자가 먼저 결정하고, Claude Code는 그 결정 안에서 구체적인 구현을 채운다. Next.js App Router를 기반으로 프론트엔드(`src/client/`)와 백엔드(`app/api/`, `src/server/`)를 디렉토리 수준에서 분리하고, `src/shared/`로 타입과 검증 스키마를 공유하며, `docs/` 문서 체계와 `CLAUDE.md`를 중심으로 프로젝트 구조를 잡는다. 배포는 Vercel 하나로 통합하여 인프라 복잡도를 최소화한다.

**4.5.2**: PRD → TRD → REQUIREMENTS.md 순으로 문서를 작성하되, Claude Code와 대화하며 뼈대(개발자) → 살(AI) → 교차 검증(개발자+AI) 3단계로 진행한다.

**4.5.3**: TDD의 Red-Green-Refactor 사이클을 Claude Code와 함께 돌리되, AI가 사이클을 깨뜨리려 할 때 명시적으로 제한한다. 같은 프로젝트 안에서도 디렉토리 경계 규칙을 지켜 한 번에 한 계층만 작업하는 원칙을 유지한다. 문서 간의 매핑(US → FR → TC)이 AI의 작업 범위를 한정하는 핵심 도구다.

다음 절에서는 이 문서 체계를 기반으로 데이터 설계, API 설계, 컴포넌트 설계, 테스트 케이스 정의를 진행하여 본격적인 개발 준비를 마무리한다.
