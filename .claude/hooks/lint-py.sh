#!/bin/bash
# ============================================================
# [PostToolUse] Python 자동 린트 훅
# - Write|Edit 후 실행
# - .py 파일에 Ruff를 적용하여 린트 + 자동 수정
# - mypy 타입 체크는 선택적으로 활성화 가능
# ============================================================
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[[ -z "$FILE_PATH" ]] && exit 0

if echo "$FILE_PATH" | grep -qE '\.py$'; then
    # Ruff로 린트 + 자동 수정
    ruff check --fix "$FILE_PATH" 2>/dev/null || true

    # mypy 타입 체크 (선택적)
    # mypy "$FILE_PATH" 2>/dev/null || true
fi

exit 0
