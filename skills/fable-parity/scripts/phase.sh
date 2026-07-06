#!/usr/bin/env bash
# fable-parity 단계 상태머신.
# 산출물 파일이 없으면 다음 단계로 전환할 수 없다 — 절차 강제의 핵심.
#
# 사용법:
#   phase.sh start            # 워크플로우 시작 (phase=spec, 게이트 활성화)
#   phase.sh status           # 현재 단계 + 다음 전환 조건
#   phase.sh set <단계>       # 전환 (전제조건 검사 후 성공/실패)
#   phase.sh off              # 게이트 해제 (상태 삭제)
set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
DIR="$ROOT/.claude/fable-parity"
PHASE_FILE="$DIR/phase"

PHASES=(spec analyze design implement verify done)

usage_next() {
  case "$1" in
    spec)      echo "다음: phase.sh set analyze  (전제: $DIR/spec.md — 목표·제약·완료 기준)" ;;
    analyze)   echo "다음: phase.sh set design   (전제: $DIR/analysis.md — 영향 범위 맵)" ;;
    design)    echo "다음: phase.sh set implement (전제: $DIR/design.md + 사용자 설계 승인)" ;;
    implement) echo "다음: phase.sh set verify" ;;
    verify)    echo "다음: phase.sh set done     (전제: $DIR/verify.md — 완료 기준별 도구 출력 증거)" ;;
    done)      echo "워크플로우 완료. 새 작업은 phase.sh start" ;;
  esac
}

require() { # require <파일> <설명>
  if [ ! -s "$1" ]; then
    echo "차단: $1 없음 — $2 를 먼저 작성하라." >&2
    exit 1
  fi
}

case "${1:-status}" in
  start)
    mkdir -p "$DIR"
    echo "spec" > "$PHASE_FILE"
    echo "fable-parity 시작. phase=spec"
    echo "먼저 $DIR/spec.md 에 목표/제약/완료 기준을 작성하고 사용자 확인을 받아라."
    usage_next spec
    ;;
  status)
    if [ ! -f "$PHASE_FILE" ]; then echo "비활성 (phase.sh start 로 시작)"; exit 0; fi
    P="$(cat "$PHASE_FILE")"
    echo "phase=$P"
    usage_next "$P"
    ;;
  set)
    TARGET="${2:?사용법: phase.sh set <spec|analyze|design|implement|verify|done>}"
    [ -f "$PHASE_FILE" ] || { echo "차단: 워크플로우 미시작 — phase.sh start 먼저." >&2; exit 1; }
    CUR="$(cat "$PHASE_FILE")"
    # 순방향 한 칸씩만 허용 (되돌리기는 자유)
    cur_i=-1; tgt_i=-1
    for i in "${!PHASES[@]}"; do
      [ "${PHASES[$i]}" = "$CUR" ] && cur_i=$i
      [ "${PHASES[$i]}" = "$TARGET" ] && tgt_i=$i
    done
    [ "$tgt_i" -ge 0 ] || { echo "차단: 알 수 없는 단계 '$TARGET'" >&2; exit 1; }
    if [ "$tgt_i" -gt "$((cur_i + 1))" ]; then
      echo "차단: $CUR → $TARGET 건너뛰기 금지. 한 단계씩 진행하라." >&2; exit 1
    fi
    case "$TARGET" in
      analyze)   require "$DIR/spec.md"     "목표·제약·완료 기준 명세" ;;
      design)    require "$DIR/analysis.md" "영향 범위 맵 (파일:라인, 호출자 추적)" ;;
      implement)
        require "$DIR/design.md" "변경 목록·순서·리스크·완료 기준 매핑 설계서"
        # ponytail: 승인은 파일 존재 + 선언으로 강제 — 사용자가 승인 안 했으면 이 플래그를 넘기면 안 된다
        if [ "${3:-}" != "--user-approved" ]; then
          echo "차단: 설계 승인 필요. 사용자에게 $DIR/design.md 승인을 받은 뒤" >&2
          echo "  phase.sh set implement --user-approved  로 재시도하라." >&2
          exit 1
        fi
        ;;
      verify)    : ;;
      done)
        require "$DIR/verify.md" "완료 기준별 검증 증거 (명령 + 출력)"
        if ! grep -qE '\b(PASS|OK|passed|통과)\b' "$DIR/verify.md"; then
          echo "차단: $DIR/verify.md 에 통과 증거(PASS/통과 등)가 없다. 검증을 실제로 실행하고 출력을 기록하라." >&2
          exit 1
        fi
        ;;
    esac
    echo "$TARGET" > "$PHASE_FILE"
    echo "phase=$TARGET"
    usage_next "$TARGET"
    ;;
  off)
    rm -rf "$DIR"
    echo "fable-parity 게이트 해제됨."
    ;;
  *)
    echo "사용법: phase.sh {start|status|set <단계> [--user-approved]|off}" >&2
    exit 1
    ;;
esac
