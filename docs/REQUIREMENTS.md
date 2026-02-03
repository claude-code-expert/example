<!--
REQUIREMENTS.md
- AI 코딩 도구로 하여금 어떤 요건을 근거로 기능을 개발할 것인가를 정의


REQUIREMENTS.md는 AI 코딩 도구의 작업 컨텍스트를 제공하는 문서입니다. 
AI가 기능을 구현할 때 참고해야 할 요건과, 현재 작업의 범위를 명확히 전달합니다.

필수 섹션

1. 프로젝트 개요 (간결하게)
2. 기술 스택 (버전 명시)
3. 디렉토리 구조
4. 코딩 컨벤션
5. 현재 작업 범위와 제약사항
6. 테스트 요구사항
7. 금지 사항

-->

# TODO 애플리케이션 요구사항

## 프로젝트 개요

단일 사용자를 위한 할 일 관리 웹 애플리케이션.
CRUD 기능과 필터링을 제공하며, 인증 없이 동작한다.

## 기술 스택

| 구분 | 기술 | 버전 |
|------|------|------|
| Framework | Next.js | 14.x |
| Language | TypeScript | 5.x |
| Styling | Tailwind CSS | 3.x |
| Database | PostgreSQL | 15.x |
| ORM | Prisma | 5.x |
| Testing | Jest, React Testing Library | 29.x |

## 디렉토리 구조
```
src/
├── app/                    # Next.js App Router
│   ├── api/todos/          # API Routes
│   ├── layout.tsx
│   └── page.tsx
├── components/
│   ├── ui/                 # 범용 UI 컴포넌트
│   └── todo/               # TODO 도메인 컴포넌트
├── hooks/                  # 커스텀 훅
├── lib/                    # 유틸리티, API 클라이언트
├── types/                  # TypeScript 타입 정의
└── __tests__/              # 테스트 파일
```

## 코딩 컨벤션

### 네이밍
- 컴포넌트: PascalCase (예: `TodoItem.tsx`)
- 함수/변수: camelCase (예: `createTodo`)
- 상수: UPPER_SNAKE_CASE (예: `MAX_TITLE_LENGTH`)
- 타입/인터페이스: PascalCase, `I` 접두사 금지 (예: `Todo`, `CreateTodoInput`)

### 파일 구조
- 컴포넌트당 하나의 파일
- 테스트 파일은 대상 파일과 같은 디렉토리에 `.test.ts(x)` 확장자로 위치
- index.ts를 통한 배럴 export 사용

### TypeScript
- `any` 타입 사용 금지
- 명시적 반환 타입 선언 권장
- strict 모드 활성화

### React
- 함수형 컴포넌트만 사용
- Props 타입은 컴포넌트 파일 내에서 정의
- 커스텀 훅은 `use` 접두사 사용

### API
- RESTful 규칙 준수
- 응답 형식: `{ data: T }` 또는 `{ error: { code, message } }`
- HTTP 상태 코드 적절히 사용

## 데이터 모델

### Todo
```typescript
interface Todo {
  id: string;           // UUID
  title: string;        // 1-100자
  completed: boolean;   // 기본값: false
  createdAt: Date;
  updatedAt: Date;
}
```

## API 엔드포인트

| Method | Endpoint | 설명 |
|--------|----------|------|
| GET | /api/todos | 전체 목록 조회 |
| POST | /api/todos | 새 TODO 생성 |
| GET | /api/todos/:id | 특정 TODO 조회 |
| PATCH | /api/todos/:id | TODO 수정 |
| DELETE | /api/todos/:id | TODO 삭제 |

## 테스트 요구사항

### 필수 테스트
1. **API 테스트**: 모든 엔드포인트의 성공/실패 케이스
2. **컴포넌트 테스트**: 사용자 인터랙션 테스트
3. **훅 테스트**: 상태 변화 검증

### 테스트 작성 규칙
- describe로 테스트 그룹화
- it/test 설명은 "~해야 한다" 형식
- AAA 패턴 (Arrange-Act-Assert) 준수
- Mock은 최소화, 실제 동작 테스트 우선

### 테스트 예시
```typescript
describe('TodoItem', () => {
  it('체크박스 클릭 시 완료 상태가 토글되어야 한다', async () => {
    // Arrange
    const onToggle = jest.fn();
    render(<TodoItem todo={mockTodo} onToggle={onToggle} />);
    
    // Act
    await userEvent.click(screen.getByRole('checkbox'));
    
    // Assert
    expect(onToggle).toHaveBeenCalledWith(mockTodo.id);
  });
});
```

## 현재 작업 범위

### Phase 1: 백엔드 API (현재)
- [ ] Prisma 스키마 정의
- [ ] API Routes 구현
- [ ] API 테스트 작성

### Phase 2: 프론트엔드 (다음)
- [ ] UI 컴포넌트 구현
- [ ] API 연동
- [ ] E2E 테스트

## 제약사항

### 이번 버전에서 구현하지 않음
- 사용자 인증
- 카테고리/태그 기능
- 드래그 앤 드롭 정렬
- 알림 기능

### 금지 사항
- `any` 타입 사용
- 인라인 스타일 (Tailwind 사용)
- console.log (logger 유틸 사용)
- 테스트 없는 기능 머지
- 하드코딩된 설정값 (환경 변수 사용)

## 환경 변수
```env
DATABASE_URL=          # PostgreSQL 연결 문자열 (필수)
NODE_ENV=              # development | production
```

## 참고 문서

- [PRD](./docs/PRD.md)
- [TRD](./docs/TRD.md)
- [API 문서](./docs/API.md)
```

---

## 5. 문서 간 연계와 활용

### AI 코딩 도구와의 협업 흐름
```
1. PRD 작성

   └─ Claude에게 PRD 검토 요청

   "이 PRD에서 누락된 요구사항이나 모호한 부분을 찾아줘"

2. TRD 작성

   └─ Claude에게 기술 설계 검토 요청

   "이 아키텍처에서 잠재적인 문제점을 분석해줘"

3. REQUIREMENTS.md 작성

   └─ 프로젝트 루트에 배치

   └─ Claude Code가 자동으로 참조

4. 개발 진행

   └─ "REQUIREMENTS.md를 참고해서 TodoItem 컴포넌트를 구현해줘"