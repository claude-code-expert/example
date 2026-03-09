#!/bin/bash
# ============================================================
# [Notification] Slack 알림 훅
# - Claude가 작업 완료 알림을 보낼 때 실행
# - Slack Incoming Webhook URL로 메시지를 전송
# - 환경변수 SLACK_WEBHOOK_URL 설정 필요
#   export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T.../B.../xxx"
# ============================================================
set -euo pipefail

INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Claude 작업이 완료되었습니다."')

# Webhook URL이 없으면 조용히 종료
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
[[ -z "$SLACK_WEBHOOK_URL" ]] && exit 0

# 현재 디렉터리와 브랜치 정보
PROJECT=$(basename "$(pwd)")
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Slack 메시지 전송
PAYLOAD=$(jq -n \
  --arg text "*[Claude Code]* 작업 완료 알림" \
  --arg project "$PROJECT" \
  --arg branch "$BRANCH" \
  --arg message "$MESSAGE" \
  --arg timestamp "$TIMESTAMP" \
  '{
    "blocks": [
      {
        "type": "header",
        "text": { "type": "plain_text", "text": "Claude Code 작업 완료" }
      },
      {
        "type": "section",
        "fields": [
          { "type": "mrkdwn", "text": ("*프로젝트:*\n" + $project) },
          { "type": "mrkdwn", "text": ("*브랜치:*\n" + $branch) }
        ]
      },
      {
        "type": "section",
        "text": { "type": "mrkdwn", "text": ("*내용:*\n" + $message) }
      },
      {
        "type": "context",
        "elements": [
          { "type": "mrkdwn", "text": $timestamp }
        ]
      }
    ]
  }')

curl -s -X POST "$SLACK_WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d "$PAYLOAD" \
  --max-time 5 2>/dev/null || true

exit 0
