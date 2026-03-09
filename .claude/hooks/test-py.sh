#!/bin/bash
# ============================================================
# [PostToolUse] Python 관련 테스트 자동 실행 훅
# - Write|Edit 후 실행
# - .py 소스 파일 변경 시 pytest로 관련 테스트 실행
# - test_*.py / *_test.py 패턴으로 테스트 파일을 자동 탐색
# ============================================================
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[[ -z "$FILE_PATH" ]] && exit 0

if echo "$FILE_PATH" | grep -qE '\.py$'; then
    # 테스트 파일이 아닌 경우에만
    if ! echo "$FILE_PATH" | grep -qE '(test_|_test\.py)'; then
        # 관련 테스트 파일 찾기
        BASE_NAME=$(basename "$FILE_PATH" .py)
        DIR_NAME=$(dirname "$FILE_PATH")

        # test_*.py 또는 *_test.py 패턴 검색
        TEST_FILE=$(find "$DIR_NAME" -name "test_${BASE_NAME}.py" -o -name "${BASE_NAME}_test.py" 2>/dev/null | head -1)

        if [[ -n "$TEST_FILE" ]]; then
            pytest "$TEST_FILE" -v --tb=short 2>/dev/null || true
        fi
    fi
fi

exit 0
