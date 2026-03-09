#!/bin/bash
# ============================================================
# [Notification] Telegram 알림 훅
# - Claude가 작업 완료/입력 대기 시 Telegram으로 알림 전송
# - hook_event_name에 따라 메시지를 분기 (Stop / Notification)
# - 환경변수 설정 필요:
#   export TELEGRAM_BOT_TOKEN="123456:ABC-DEF..."
#   export TELEGRAM_CHAT_ID="123456789"
# ============================================================
set -euo pipefail

# Telegram 설정 (환경 변수로 설정)
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"

if [[ -z "$TELEGRAM_BOT_TOKEN" || -z "$TELEGRAM_CHAT_ID" ]]; then
    exit 0
fi

INPUT=$(cat)
PROJECT_DIR=$(basename "${CLAUDE_PROJECT_DIR:-$(pwd)}")
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')

# 메시지 내용 결정
case "$HOOK_EVENT" in
    "Stop")
        MESSAGE="✅ 클로드 코드 작업 완료%0A프로젝트: ${PROJECT_DIR}"
        ;;
    "Notification")
        MESSAGE="⏳ 클로드 코드가 입력을 기다리고 있습니다%0A프로젝트: ${PROJECT_DIR}"
        ;;
    *)
        MESSAGE="📢 클로드 코드 알림%0A이벤트: ${HOOK_EVENT}"
        ;;
esac

# Telegram 메시지 전송
curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${TELEGRAM_CHAT_ID}" \
    -d "text=${MESSAGE}" \
    -d "parse_mode=HTML" \
    --max-time 5 2>/dev/null || true

exit 0
