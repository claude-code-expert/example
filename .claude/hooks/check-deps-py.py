#!/usr/bin/env python3
# ============================================================
# [PreToolUse] Python 의존성 검사 훅
# - Edit|Write 전 실행
# - .py 파일에 새로운 import가 추가될 때 설치 여부를 확인
# - 미설치 패키지 발견 시 stderr로 경고 (차단하지 않고 알림만)
# ============================================================
"""
Python 파일 수정 시 import된 패키지가 설치되어 있는지 검사하는 PreToolUse Hook.
미설치 패키지가 있으면 stderr로 경고 메시지를 출력한다.
"""
import json
import sys
import re
import importlib.util

# stdin에서 Hook 입력 읽기
try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

tool_name = input_data.get('tool_name', '')
tool_input = input_data.get('tool_input', {})

# Edit/Write 도구만 검사
if tool_name not in ('Edit', 'Write'):
    sys.exit(0)

file_path = tool_input.get('file_path', '')

# Python 파일만 처리
if not file_path.endswith('.py'):
    sys.exit(0)

# 새로 작성/수정되는 내용에서 import 추출
content = tool_input.get('content', '') or tool_input.get('new_string', '')
if not content:
    sys.exit(0)

# import 패턴 추출
import_patterns = [
    re.compile(r'^import\s+([\w.]+)', re.MULTILINE),
    re.compile(r'^from\s+([\w.]+)\s+import', re.MULTILINE),
]

# 표준 라이브러리 모듈 (주요 항목)
STDLIB_MODULES = {
    'abc', 'argparse', 'ast', 'asyncio', 'base64', 'bisect', 'calendar',
    'collections', 'concurrent', 'configparser', 'contextlib', 'copy',
    'csv', 'dataclasses', 'datetime', 'decimal', 'difflib', 'email',
    'enum', 'fileinput', 'fnmatch', 'fractions', 'functools', 'gc',
    'getpass', 'glob', 'gzip', 'hashlib', 'heapq', 'hmac', 'html',
    'http', 'importlib', 'inspect', 'io', 'itertools', 'json',
    'logging', 'math', 'multiprocessing', 'operator', 'os', 'pathlib',
    'pickle', 'platform', 'pprint', 're', 'secrets', 'shlex', 'shutil',
    'signal', 'socket', 'sqlite3', 'ssl', 'string', 'struct',
    'subprocess', 'sys', 'tempfile', 'textwrap', 'threading', 'time',
    'timeit', 'traceback', 'typing', 'unittest', 'urllib', 'uuid',
    'venv', 'warnings', 'weakref', 'xml', 'zipfile', 'zlib',
    # 자주 쓰이는 내부 모듈
    '__future__', 'types', 'array', 'queue', 'random', 'statistics',
}

found_imports = set()
for pattern in import_patterns:
    for match in pattern.finditer(content):
        # 최상위 패키지명만 추출 (예: "os.path" → "os")
        top_level = match.group(1).split('.')[0]
        found_imports.add(top_level)

# 미설치 패키지 검사
missing = []
for module_name in found_imports:
    # 표준 라이브러리 건너뛰기
    if module_name in STDLIB_MODULES:
        continue
    # 상대 import 건너뛰기
    if module_name.startswith('.'):
        continue
    # 설치 여부 확인
    spec = importlib.util.find_spec(module_name)
    if spec is None:
        missing.append(module_name)

if missing:
    missing_list = ', '.join(sorted(missing))
    print(
        f"경고: 미설치 패키지 발견 → {missing_list}\n"
        f"설치 명령: pip install {' '.join(sorted(missing))}",
        file=sys.stderr
    )
    # 경고만 출력하고 차단하지 않음 (exit 0)

sys.exit(0)
