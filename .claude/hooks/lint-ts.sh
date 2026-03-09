#!/bin/bash
# ============================================================
# [PostToolUse] TS/JS 자동 린트 훅
# - Write|Edit 후 실행
# - .ts/.tsx/.js/.jsx 파일에 ESLint --fix를 적용
# - 에러 발견 시 stderr로 피드백 출력
# ============================================================
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[[ -z "$FILE_PATH" ]] && exit 0

if echo "$FILE_PATH" | grep -qE '\.(ts|tsx|js|jsx)$'; then
    # ESLint 실행 (자동 수정 포함)
    RESULT=$(npx eslint --fix "$FILE_PATH" 2>&1) || true

    # 에러가 있으면 Claude에게 피드백
    if echo "$RESULT" | grep -q "error"; then
        echo "린트 에러 발견: $RESULT" >&2
    fi
fi

exit 0
