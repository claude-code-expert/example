#!/bin/bash
# ============================================================
# [PostToolUse] TS/JS 자동 포맷 훅
# - Write|Edit 후 실행
# - .ts/.tsx/.js/.jsx 파일에 Prettier를 적용하여 코드 스타일 통일
# ============================================================
set -euo pipefail

# stdin에서 Hook 입력 읽기
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# 파일 경로가 없으면 종료
[[ -z "$FILE_PATH" ]] && exit 0

# TypeScript/JavaScript 파일만 처리
if echo "$FILE_PATH" | grep -qE '\.(ts|tsx|js|jsx)$'; then
    # Prettier 실행 (실패해도 계속 진행)
    npx prettier --write "$FILE_PATH" 2>/dev/null || true
fi

exit 0
