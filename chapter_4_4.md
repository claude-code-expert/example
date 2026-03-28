# 4.4 명세서 작성과 설계하기

4.3절에서 PRD, TRD, REQUIREMENTS.md를 작성하고 TDD 개발 흐름을 정의했다. 이제 실제 개발에 들어가기 전 마지막 단계로, 4가지 명세 문서를 작성한다. 이 문서들이 Chapter 5(백엔드)와 Chapter 6(프론트엔드)에서 Claude Code에게 전달하는 **구현 기준**이 된다.

```
docs/
├── PRD.md              ← 4.3.2에서 작성 완료
├── TRD.md              ← 4.3.2에서 작성 완료
├── REQUIREMENTS.md     ← 4.3.2에서 작성 완료
├── DATA_MODEL.md       ← 4.4.1 데이터 설계
├── API_SPEC.md         ← 4.4.2 API 설계
├── COMPONENT_SPEC.md   ← 4.4.3 컴포넌트 설계
└── TEST_CASES.md       ← 4.4.4 테스트 케이스 정의
```

4.3절의 문서가 "무엇을, 왜" 만드는지를 정의했다면, 이번 절의 문서는 "구체적으로 어떤 형태로" 만드는지를 정의한다. Claude Code에게 "티켓 생성 API를 만들어줘"라고 요청할 때, AI가 참조할 수 있는 구체적인 필드 정의, 요청/응답 형식, 컴포넌트 Props, 테스트 시나리오가 여기에 담긴다.

> 이번 절에서는 각 명세의 **구조와 핵심 내용**을 설명한다. 전체 명세의 상세 내용은 GitHub 저장소에서 확인할 수 있다.
> 📎 [Tika 프로젝트 명세 문서 전체](https://github.com/example/tika/tree/main/docs)


## 4.4.1 데이터 설계

데이터 모델은 프로젝트의 기초 골격이다. 테이블 구조가 잘못되면 API도, 컴포넌트도, 테스트도 전부 꼬인다. 특히 AI와 작업할 때 데이터 모델이 명확하지 않으면, Claude Code가 필드명을 제멋대로 정하거나 없는 칼럼을 참조하는 코드를 생성하게 된다.

### DATA_MODEL.md에 포함해야 할 것

데이터 모델 문서는 크게 세 가지를 정의한다.

1. 엔티티와 필드 정의
2. 테이블의 연관관계
3. 비즈니스 규칙과 제약 조건

Tika 프로젝트에서는 연관관계가 별도로 없기 때문에 단일 테이블을 다음과 같이 설계해주면 된다. 각 테이블의 필드별 타입, 제약 조건, 기본값을 표로 정리한다. Tika의 핵심 엔티티는 `tickets` 하나다.

| 칼럼 | 타입 | 제약 조건 | 기본값 | 설명 |
|------|------|----------|--------|------|
| id | SERIAL | PK, auto-increment | — | 티켓 고유 식별자 |
| title | VARCHAR(200) | NOT NULL | — | 티켓 제목 |
| description | TEXT | NULLABLE | NULL | 티켓 상세 설명 |
| status | VARCHAR(20) | NOT NULL | 'BACKLOG' | 현재 상태 (칼럼) |
| priority | VARCHAR(10) | NOT NULL | 'MEDIUM' | 우선순위 |
| position | INTEGER | NOT NULL | 1 | 칼럼 내 표시 순서 |
| planned_start_date | DATE | NULLABLE | NULL | 시작예정일 (사용자 입력) |
| due_date | DATE | NULLABLE | NULL | 종료예정일 (사용자 입력) |
| started_at | TIMESTAMP | NULLABLE | NULL | 시작일 (TODO 이동 시 자동) |
| completed_at | TIMESTAMP | NULLABLE | NULL | 종료일 (Done 이동 시 자동) |
| created_at | TIMESTAMP | NOT NULL | now() | 생성 시각 |
| updated_at | TIMESTAMP | NOT NULL | now() | 수정 시각 |

여기서 사용자(User) 별 티켓 생성과 같은 기능이 추가된다면 사용자와 티켓의 관계가 1:N의 테이블 구조를 갖겠지만 현재는 MVP이므로 연관관계를 별도로 맺지 않고 단일 테이블 엔티티로 구현을 하도록 한다.

비즈니스 규칙은 데이터에 적용되는 값과 조건을 명시한다. 이 규칙이 없으면 Claude Code가 "완료 상태로 이동할 때 completedAt을 기록할까요?"처럼 개발자에게 되물어야 하는 상황이 생긴다.

- 신규 티켓 생성 시: status = BACKLOG, position = 1
- **TODO로 이동 시**: started_at = 현지시간 (최초 1회만, 이미 값이 있으면 유지)
- **Done으로 이동 시**: completed_at = 현재시간
- **Done에서 다른 칼럼으로 복귀 시**: completed_at = NULL
- 일정초과 판정: due_date < 오늘 AND status ≠ DONE
- 칼럼 내 순서 변경 시: 해당 칼럼의 position 값을 재계산

필수 필드만을 추가해주어야 한다. 설계 방향과 맞지 않는 필드들이 있으면 그만큼 복잡해지므로 항상 검토해서 눈으로 확인하는 습관을 들여야 오버 엔지니어링, 오동작을 방지할 수 있다. 또한 `status` 필드를 PostgreSQL의 ENUM 타입으로 정의하려는 경우가 있다. DB 레벨 ENUM은 값을 추가하거나 변경할 때 마이그레이션이 복잡해지므로, Tika에서는 varchar + 애플리케이션 레벨 검증(Zod)을 사용한다.

> 📎 DATA_MODEL.md 전체 내용: [GitHub - docs/DATA_MODEL.md](https://github.com/example/tika/blob/main/docs/DATA_MODEL.md)


## 4.4.2 API 설계

API 명세는 프론트엔드와 백엔드 사이의 **계약(Contract)**이다. 프론트엔드 개발자(또는 프론트엔드를 구현하는 AI)는 이 명세만 보고 API를 호출하는 코드를 작성할 수 있어야 하고, 백엔드 개발자(또는 백엔드를 구현하는 AI)는 이 명세대로 정확히 동작하는 API를 만들어야 한다.

### API_SPEC.md의 구조

Tika의 API는 티켓 CRUD와 상태/순서 변경, 총 8개 엔드포인트로 구성된다. 4.2.1 기능 요구사항 정의에서 이미 정의한 바 있다. 해당 정의의 URL과 HTTP API 스펙을 그대로 작성해달라고 요청한 뒤 응답에 대한 값만 정의해주면 API_SPEC.md 문서는 완성이다. 개발자는 다음과 같은 스펙에 대한 필드가 제대로 되었는지 검증을 해보면 된다.

### 엔드포인트별 명세 작성법

각 엔드포인트마다 요청 필드, 성공 응답, 에러 응답을 정의한다. 여기서는 티켓 생성 API를 예시로 본다.

**POST /api/tickets — 티켓 생성**

요청 본문:

| 필드 | 타입 | 필수 | 제약 조건 |
|------|------|------|----------|
| title | string | O | 1~200자 |
| description | string | X | 최대 1000자 |
| priority | string | X | LOW \| MEDIUM \| HIGH, 기본값 MEDIUM |
| plannedStartDate | string | X | YYYY-MM-DD |
| dueDate | string | X | YYYY-MM-DD |

성공 응답: `201 Created`

```json
{
  "id": 1,
  "title": "로그인 페이지 디자인",
  "description": null,
  "status": "BACKLOG",
  "priority": "MEDIUM",
  "position": 1,
  "plannedStartDate": null,
  "dueDate": null,
  "startedAt": null,
  "completedAt": null,
  "createdAt": "2026-01-15T09:00:00Z",
  "updatedAt": "2026-01-15T09:00:00Z"
}
```

에러 응답: 꼭 이와 같이 맞출 필요는 없지만 사용자 정의 에러 코드가 너무 복잡한 방식은 지양하는게 좋다.

| 상태 코드 | 조건 | 에러 메시지 |
|----------|------|------------|
| 400 | title 누락 | 제목을 입력해주세요 |
| 400 | title 200자 초과 | 제목은 200자 이내로 입력해주세요 |
| 400 | 과거 종료예정일 | 종료예정일은 오늘 이후여야 합니다 |
| 400 | 잘못된 priority 값 | 우선순위는 LOW, MEDIUM, HIGH 중 하나여야 합니다 |

나머지 7개 엔드포인트도 동일한 구조로 작성한다. 여기서 에러 메시지를 한국어로 정의한 점에 주목하자. REQUIREMENTS.md에서 "검증 에러 메시지는 한국어"로 정했으므로 API_SPEC.md도 이를 따른다. 문서 간 일관성이 깨지면 Claude Code가 영어 에러 메시지를 생성하거나, 코드마다 다른 메시지를 쓰게 된다.

### 공통 규칙 정의

개별 엔드포인트 명세 외에 모든 API에 적용되는 공통 규칙도 문서 상단에 정리한다.

**에러 응답 형식** — 모든 에러는 동일한 구조를 따른다.

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "제목을 입력해주세요"
  }
}
```

**상태 코드 규칙**: 200(조회/수정 성공), 201(생성 성공), 204(삭제 성공), 400(검증 실패), 404(리소스 없음), 500(서버 오류).

물론 편의에 따라 HTTP Status 코드를 별도로 내려준다거나 시스템의 에러 메시지 등 좀 더 복잡한 방식으로 처리해도 무방하지만 여기서는 작고 빠르게 완성해야 하므로 이 정도 응답 형태도 충분하다고 생각한다.

> 📎 API_SPEC.md 전체 내용: [GitHub - docs/API_SPEC.md](https://github.com/example/tika/blob/main/docs/API_SPEC.md)


## 4.4.3 컴포넌트 및 UseCase 설계

프론트엔드 개발에서는 UI 컴포넌트의 명세도 중요하다. 컴포넌트의 책임, 입출력, 상태를 정의한다. Claude Code에게 작업 요청을 했을 때 AI가 이 명세들을 바탕으로 Props와 상태 관리, 하위 컴포넌트 구조등을 작성하므로 가급적 작성해두는 것이 좋다.

### 컴포넌트 계층 구조

```
App (루트)
├── Header                    # 검색, 필터, "새 업무" 버튼
├── Board                     # 칸반 보드 컨테이너 (DnD 컨텍스트)
│   ├── Column (×4)           # Backlog, TODO, In Progress, Done
│   │   └── TicketCard (×N)   # 개별 티켓 카드
│   └── (DnD Overlay)         # 드래그 중 표시되는 카드 복제
├── TicketModal               # 티켓 상세/수정 모달
├── TicketForm                # 티켓 생성 폼
└── UI 공통
    ├── Button, Modal, Badge
    └── ConfirmDialog
```

### 핵심 컴포넌트 명세

전체 컴포넌트를 상세히 기술하기보다, 가장 중요한 3개 컴포넌트의 명세 구조를 보여준다. 나머지는 동일한 패턴으로 작성하면 된다.

**Board — 칸반 보드 컨테이너**

| 항목 | 내용 |
|------|------|
| 책임 | 4개 칼럼을 렌더링하고, 칼럼 간/칼럼 내 드래그앤드롭을 관리 |
| Props | `tickets: Ticket[]`, `onReorder: (id, status, position) => void` |
| 내부 상태 | DnD 관련 상태 (@dnd-kit) |
| 핵심 동작 | 드래그 시작 → 오버레이 표시 → 드롭 → onReorder 호출 → 낙관적 업데이트 |
| 하위 컴포넌트 | Column × 4 |

**Column — 칼럼**

| 항목 | 내용 |
|------|------|
| 책임 | 해당 상태의 티켓 목록을 렌더링, 드롭 영역 제공 |
| Props | `status: TicketStatus`, `tickets: Ticket[]`, `title: string` |
| 핵심 동작 | 티켓을 position 순으로 정렬, 빈 칼럼 시 안내 메시지 |
| 하위 컴포넌트 | TicketCard × N |

**TicketCard — 티켓 카드**

| 항목 | 내용 |
|------|------|
| 책임 | 개별 티켓 정보 표시, 드래그 가능 |
| Props | `ticket: Ticket`, `onClick: () => void` |
| 핵심 동작 | 제목, 우선순위 뱃지, 종료예정일 표시. 오버듀 시 빨간색 강조. 클릭 시 상세 모달 |
| 접근성 | 키보드 네비게이션, aria-label, 드래그 핸들에 role="button" |

### 이벤트 흐름

컴포넌트 간에 데이터와 이벤트가 어떻게 흐르는지를 정리한다. 이 흐름이 명세에 있으면 Claude Code가 Props를 설계할 때 "누가 상태를 관리하고, 누가 이벤트를 발생시키는지"를 정확히 이해한다.

```
[드래그앤드롭]
TicketCard(드래그 시작) → Board(DnD 컨텍스트) → Column(드롭) 
→ Board.onReorder(id, newStatus, newPosition) → useTickets Hook
→ 낙관적 UI 업데이트 + PATCH /api/tickets/reorder

[티켓 생성]
Header("새 업무" 클릭) → TicketForm(모달 열림) → 폼 입력 → Zod 검증 
→ useTickets.create() → POST /api/tickets → 보드 갱신

[티켓 수정]
TicketCard(클릭) → TicketModal(상세 보기) → 편집 모드 → Zod 검증
→ useTickets.update() → PATCH /api/tickets/:id → 보드 갱신

[티켓 완료 (Soft 삭제)]
Done 칼럼으로 드래그 → PATCH /api/tickets/:id/complete 
→ completed_at 자동 설정 → Done 칼럼에 표시

[티켓 영구 삭제]
TicketModal(삭제 클릭) → ConfirmDialog("정말 삭제하시겠습니까?")
→ 확인 → useTickets.remove() → DELETE /api/tickets/:id → 보드 갱신
```

### UseCase와 컴포넌트의 매핑

사용자 스토리(US)가 실제로 어떤 컴포넌트에서 실현되는지를 매핑한다. 이 매핑은 Chapter 6(프론트엔드)에서 어떤 순서로 컴포넌트를 구현할지 결정하는 근거가 된다. 여기서는 각 스토리와 주요 컴포넌트, 그리고 드래그 앤 드롭(DnD)가 어떤 Hook을 호출하는지를 매핑하였다.

| 사용자 스토리 | 주요 컴포넌트 | 사용하는 Hook |
|-------------|-------------|-------------|
| US-001: 새 할 일 등록 | TicketForm | useTickets.create |
| US-003: 칸반 보드 현황 파악 | Board, Column, TicketCard | useTickets (조회) |
| US-005: 드래그앤드롭 상태 변경 | Board, Column | useTickets.reorder |
| US-006: 티켓 완료 처리 | Board (Done 칼럼 드롭) | useTickets.complete |
| US-007: 할 일 수정 | TicketModal | useTickets.update |
| US-008: 할 일 삭제 | TicketModal, ConfirmDialog | useTickets.remove |

> 📎 COMPONENT_SPEC.md 전체 내용: [GitHub - docs/COMPONENT_SPEC.md](https://github.com/example/tika/blob/main/docs/COMPONENT_SPEC.md)


## 4.4.4 테스트 케이스 정의

테스트 케이스 문서는 TDD의 시작점이다. Chapter 5에서 Red 단계를 시작할 때, 이 문서의 시나리오를 기반으로 테스트 코드를 작성한다. 테스트 케이스가 없으면 Claude Code에게 "테스트를 작성해줘"라고 요청할 때 AI가 알아서 시나리오를 만들게 되는데, 이러면 중요한 엣지 케이스가 빠지거나 불필요한 테스트가 추가된다.

### TEST_CASES.md의 구조

테스트 케이스는 크게 세 카테고리로 나뉜다.

```
TEST_CASES.md
├── API 테스트 (TC-API-001 ~ 008)       ← Chapter 5 백엔드
├── 컴포넌트 테스트 (TC-COMP-001 ~ 006)  ← Chapter 6 프론트엔드
└── 통합 테스트 (TC-INT-001 ~ 002)       ← Chapter 6 프론트엔드
```

### API 테스트 케이스 예시

각 테스트 케이스는 **정상 케이스 + 예외 케이스**로 구성한다. 티켓 생성(TC-API-001)을 예시로 본다.

**TC-API-001: 티켓 생성 API**

| # | 시나리오 | 입력 | 기대 결과 |
|---|---------|------|----------|
| 1 | 모든 필드 포함 생성 | title, description, priority, plannedStartDate, dueDate | 201, 생성된 티켓 반환 |
| 2 | 최소 필드 생성 | title만 | 201, priority=MEDIUM, status=BACKLOG |
| 3 | 제목 누락 | title 없음 | 400, "제목을 입력해주세요" |
| 4 | 제목 200자 초과 | 201자 title | 400, "제목은 200자 이내로 입력해주세요" |
| 5 | 과거 종료예정일 | dueDate = 어제 | 400, "종료예정일은 오늘 이후여야 합니다" |
| 6 | 잘못된 우선순위 | priority = "URGENT" | 400, 검증 에러 |

### 컴포넌트 테스트 케이스 예시

컴포넌트 테스트는 **사용자 관점**에서 작성한다. 내부 구현이 아니라 "사용자가 보는 것"과 "사용자가 하는 행동"에 초점을 맞춘다.

**TC-COMP-001: TicketCard 컴포넌트**

| # | 시나리오 | 조건 | 기대 결과 |
|---|---------|------|----------|
| 1 | 기본 렌더링 | 티켓 데이터 전달 | 제목, 우선순위 뱃지, 종료예정일 표시 |
| 2 | 오버듀 표시 | due_date < 오늘, status ≠ DONE | 종료예정일 빨간색, "기한 초과" 표시 |
| 3 | 완료 상태 | status = DONE | 완료 스타일 적용 |
| 4 | 카드 클릭 | 카드 영역 클릭 | onClick 핸들러 호출 |
| 5 | 종료예정일 없음 | due_date = null | 종료예정일 영역 미표시 |

### 통합 테스트 케이스

**TC-INT-001: 드래그앤드롭**

| # | 시나리오 | 동작 | 기대 결과 |
|---|---------|------|----------|
| 1 | 칼럼 간 이동 (→TODO) | BACKLOG → TODO로 드래그 | reorder API 호출, started_at 자동 설정 |
| 2 | 칼럼 간 이동 (→Done) | IN_PROGRESS → Done으로 드래그 | complete API 호출, completed_at 자동 설정 |
| 3 | 칼럼 내 순서 변경 | 같은 칼럼에서 위치 변경 | reorder API 호출, position 재계산 |
| 4 | 네트워크 오류 시 롤백 | 드래그 후 API 실패 | 원래 위치로 복원 |

**TC-INT-002: Soft 삭제 → 영구 삭제**

| # | 시나리오 | 동작 | 기대 결과 |
|---|---------|------|----------|
| 1 | Done 이동 후 표시 | 티켓을 Done으로 이동 | Done 칼럼에 표시, completed_at 설정 |
| 2 | Done 상태에서 수동 삭제 | 삭제 버튼 클릭 | 확인 다이얼로그 → DELETE API → 보드에서 제거 |
| 3 | 24시간 경과 후 자동 삭제 | Done 상태 24시간 유지 | 조회 시 목록에서 제외 |

### 추적 매트릭스와의 연결

모든 테스트 케이스는 REQUIREMENTS.md의 추적 매트릭스(US ↔ FR ↔ TC)와 연결된다. 이 연결이 끊어지지 않도록 TEST_CASES.md 상단에 매핑 표를 둔다.

| TC ID | 관련 FR | 관련 US | 테스트 대상 |
|-------|---------|---------|-----------|
| TC-API-001 | FR-001 | US-001 | 티켓 생성 API |
| TC-API-002 | FR-002 | US-003 | 보드 조회 API |
| TC-API-003 | FR-003 | US-003 | 티켓 상세 조회 API |
| TC-API-004 | FR-004 | US-007 | 티켓 수정 API |
| TC-API-005 | FR-005 | US-006 | 티켓 완료 (Soft 삭제) API |
| TC-API-006 | FR-006 | US-008 | 티켓 영구 삭제 API |
| TC-API-007 | FR-007 | US-005 | 상태/순서 변경 (reorder) API |
| TC-API-008 | FR-008 | US-003 | isOverdue 필드 계산 |
| TC-COMP-001 | — | US-003 | TicketCard 컴포넌트 |
| TC-COMP-003 | — | US-003 | Board 컴포넌트 |
| TC-INT-001 | FR-007 | US-005 | 드래그앤드롭 통합 |
| TC-INT-002 | FR-005, FR-006 | US-006, US-008 | Soft 삭제 → 영구 삭제 |

이 표가 있으면 "US-005가 제대로 구현되었는지 어떻게 확인하지?"라는 질문에 "TC-API-007과 TC-INT-001이 통과하면 된다"고 바로 답할 수 있다. Claude Code에게 특정 사용자 스토리의 구현을 요청할 때도 관련 테스트 케이스를 함께 전달하면 작업 범위가 명확해진다.

> 📎 TEST_CASES.md 전체 내용: [GitHub - docs/TEST_CASES.md](https://github.com/example/tika/blob/main/docs/TEST_CASES.md)

---

지금까지 설계한 API, 컴포넌트, 데이터 모델, 테스트 케이스는 각각 개별적으로 동작하는게 아니라 서로 참조하고 의존하는 관계에 있다.

그 근본 동작에는 기본적으로 철저하게 작성한 FR, NFR, US와 같은 Requirement 정의와 잘 모델링된 데이터베이스, 개발 프로젝트의 전체 흐름과 기능을 정의해두어야 나머지 기능들은 Claude Code와 함께 보완하면서 완성해나갈 수 있을 것이다.

다음 장부터는 이 명세들을 기반으로 실제 코드를 작성한다. Chapter 5에서 백엔드를, Chapter 6에서 프론트엔드를 TDD로 구현하며, 매 단계에서 이 문서들이 (어느 정도는 수정이 되겠지만) Claude Code의 작업 기준이 된다.
