#!/bin/bash
# ============================================================
# [PostToolUse] TS/JS 관련 테스트 자동 실행 훅
# - Write|Edit 후 실행
# - .ts/.tsx/.js/.jsx 소스 파일 변경 시 Jest로 관련 테스트 실행
# - 테스트 파일(.test/.spec) 자체 수정 시에는 건너뜀
# ============================================================
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[[ -z "$FILE_PATH" ]] && exit 0

# 테스트 파일이나 소스 파일 변경 시
if echo "$FILE_PATH" | grep -qE '\.(ts|tsx|js|jsx)$'; then
    # 테스트 파일 자체가 아닌 경우에만 관련 테스트 실행
    if ! echo "$FILE_PATH" | grep -qE '\.(test|spec)\.(ts|tsx|js|jsx)$'; then
        npm test -- --findRelatedTests "$FILE_PATH" --passWithNoTests 2>/dev/null || true
    fi
fi

exit 0
