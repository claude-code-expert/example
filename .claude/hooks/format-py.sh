#!/bin/bash
# ============================================================
# [PostToolUse] Python 자동 포맷 훅
# - Write|Edit 후 실행
# - .py 파일에 Black(포맷터) + isort(import 정렬)를 적용
# ============================================================
set -euo pipefail

# stdin에서 Hook 입력 읽기
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# 파일 경로가 없으면 종료
[[ -z "$FILE_PATH" ]] && exit 0

# Python 파일만 처리
if echo "$FILE_PATH" | grep -qE '\.py$'; then
    # Black + isort 실행
    black "$FILE_PATH" 2>/dev/null || true
    isort "$FILE_PATH" 2>/dev/null || true
fi

exit 0
