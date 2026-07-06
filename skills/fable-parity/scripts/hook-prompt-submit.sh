#!/usr/bin/env bash
# UserPromptSubmit: 매 프롬프트마다 현재 단계를 짧게 주입 — 긴 세션에서 절차 이탈 방지.
ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PHASE_FILE="$ROOT/.claude/fable-parity/phase"
[ -f "$PHASE_FILE" ] || exit 0
P="$(cat "$PHASE_FILE")"
echo "[fable-parity] phase=$P — 코드 수정은 implement부터, 종료는 verify.md 증거 이후. 전환: phase.sh set <단계>"
