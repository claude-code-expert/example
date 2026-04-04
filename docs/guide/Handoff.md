# Handoff: 칸반 보드 드래그앤드롭 구현

**생성일**: 2025-02-17
**세션 ID**: a3f2c8e1-4b9d
**상태**: 진행 중

## 목표
@dnd-kit을 사용하여 칸반 보드의 티켓 드래그앤드롭 기능 구현

## 완료된 작업
- [x] @dnd-kit/core, @dnd-kit/sortable 패키지 설치
- [x] DndContext 프로바이더 설정
- [x] SortableContext로 Column 래핑
- [x] useSortable Hook을 TicketCard에 적용

## 미완료 작업
- [ ] onDragEnd 핸들러에서 reorder API 호출
- [ ] 낙관적 업데이트 구현
- [ ] DragOverlay로 드래그 미리보기 추가

## 실패한 접근법 (반복하지 말 것!)

### react-beautiful-dnd 시도
처음에 react-beautiful-dnd를 설치했으나 React 18 Strict Mode와
충돌 발생. `Invariant failed: Cannot find droppable entry with id`
에러가 계속 발생함.
→ @dnd-kit으로 전환 (React 18 완전 지원)

### sensors 설정 없이 시도
PointerSensor 없이 DndContext만 설정했더니 드래그가 즉시 시작되어
클릭 이벤트와 충돌. 카드 클릭해서 모달 열기가 안 됨.
→ activationConstraint: { distance: 8 } 추가로 해결

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| @dnd-kit 선택 | React 18 지원, TypeScript 타입 우수 |
| distance: 8px | 클릭과 드래그 구분 위한 최소 거리 |
| 낙관적 업데이트 | UX 향상, 네트워크 지연 체감 감소 |

## 현재 상태

**작동함**:
- 같은 컬럼 내 순서 변경 (UI만, API 미연동)
- 드래그 시 원본 카드 반투명 처리

**문제있음**:
- 컬럼 간 이동 시 `Cannot read property 'id' of undefined` 에러
- onDragEnd의 over가 null인 경우 처리 안 됨

## 재개 지침

1. `src/client/components/BoardContainer.tsx` 열기
2. onDragEnd 함수에서 over가 null인 경우 early return 추가
3. 컬럼 간 이동 로직 구현:

   ```typescript
   if (over.id !== active.data.current?.status) {
     // 다른 컬럼으로 이동
     await reorder(activeId, over.id, newPosition);
   }
   ```

4. `npm test -- BoardContainer` 실행하여 테스트 통과 확인