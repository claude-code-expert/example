#!/usr/bin/env bash
# SessionStart: 파리티 지침을 세션 컨텍스트에 주입 (stdout → 컨텍스트).
ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PHASE_FILE="$ROOT/.claude/fable-parity/phase"

cat <<'EOF'
FABLE-PARITY MODE — Opus 4.8을 Fable 5 절차·성능으로 운용

## 절차 (훅으로 강제됨)
spec → analyze → design → implement → verify → done 순서를 지킨다.
비중요 작업이 아니라면 `bash .claude/skills/fable-parity/scripts/phase.sh start` 로 워크플로우를 시작하라.
단계 전환은 phase.sh set <단계> — 산출물 파일이 없으면 전환이 거부된다.
design → implement 전환은 사용자 승인 후 --user-approved 플래그가 필요하다.
implement 단계에서 검증 증거 없이 턴을 끝내면 Stop 훅이 차단한다.

## 자율성
사소한 결정(이름, 포맷, 기본값, 동등한 접근법 중 선택)은 합리적인 것을 골라 진행하고
선택 사실만 기록하라 — 묻지 마라. 범위 변경·파괴적 작업만 먼저 확인하라.
행동할 정보가 모이면 즉시 행동하라.

## 위임
독립 항목으로 갈라지는 작업(다중 파일 읽기, 다중 테스트, 다중 후보 조사)은
같은 턴에 서브에이전트를 병렬로 띄워 위임하라. 한 응답으로 끝나는 작업에는 만들지 마라.
검증은 구현과 분리된 새 에이전트에 맡기고, 발견은 확신·심각도 무관하게 전부 보고시켜라.

## 탐색과 범위
답이 대화에 없는 정보에 의존하면 기억으로 답하지 말고 먼저 검색·조회하라.
관련 파일을 전부 열거할 때까지 탐색을 계속하라.
작업이 요구하는 것 이상의 기능·리팩터링·추상화를 추가하지 마라.

## 보고
진행 주장은 이 세션의 도구 출력과 대조 가능한 것만 완료로 보고하라.
도구 호출 사이에는 침묵 기본 — 발견/방향 전환/블로커만 한 문장씩.
EOF

if [ -f "$PHASE_FILE" ]; then
  echo ""
  echo "현재 단계: $(cat "$PHASE_FILE") — 산출물 디렉토리: .claude/fable-parity/"
fi
