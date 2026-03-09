#!/usr/bin/env python3
# ============================================================
# [PreToolUse] 위험 명령어 및 보호 파일 차단 훅
# - 모든 도구 실행 전 검사
# - Bash: rm -rf, git push --force, DROP TABLE 등 위험 명령 차단
# - Edit|Write: .env, 키 파일, 락 파일 등 민감한 파일 수정 차단
# - exit(2)로 종료 시 명령이 차단되고 stderr 메시지가 Claude에 전달
# ============================================================
"""
위험한 명령어를 차단하는 PreToolUse Hook
exit code 2로 종료하면 명령이 차단되고 stderr 메시지가 Claude에게 전달된다.
"""
import json
import sys
import re

# stdin에서 Hook 입력 읽기
try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

tool_name = input_data.get('tool_name', '')
tool_input = input_data.get('tool_input', {})

# Bash 명령어 검사
if tool_name == 'Bash':
    command = tool_input.get('command', '')

    # 차단할 위험한 패턴들
    dangerous_patterns = [
        # 파일 시스템 위험 명령
        (r'\brm\s+(-[rRf]+\s+)*/', '루트 디렉터리 삭제 시도'),
        (r'\brm\s+-[rRf]*\s+\*', '와일드카드를 사용한 재귀 삭제'),
        (r'\brm\s+-[rRf]+', '재귀/강제 삭제 명령 (rm -rf)'),

        # Git 위험 명령
        (r'git\s+push\s+.*--force', 'Git 강제 푸시'),
        (r'git\s+push\s+-f\b', 'Git 강제 푸시'),
        (r'git\s+reset\s+--hard', 'Git 하드 리셋'),
        (r'git\s+clean\s+-[fd]+', 'Git clean (추적되지 않는 파일 삭제)'),
        (r'git\s+branch\s+-D', 'Git 브랜치 강제 삭제'),

        # 데이터베이스 위험 명령
        (r'\bDROP\s+(DATABASE|TABLE|SCHEMA)\b', 'DROP 명령 (DB/테이블 삭제)', re.IGNORECASE),
        (r'\bTRUNCATE\s+TABLE\b', 'TRUNCATE 명령 (테이블 전체 삭제)', re.IGNORECASE),
        (r'\bDELETE\s+FROM\s+\w+\s*;', 'WHERE 절 없는 DELETE (전체 삭제)', re.IGNORECASE),
        (r'\bDELETE\s+FROM\s+\w+\s*$', 'WHERE 절 없는 DELETE (전체 삭제)', re.IGNORECASE),

        # 시스템 위험 명령
        (r'\bsudo\s+rm\b', 'sudo를 사용한 삭제'),
        (r'\bchmod\s+777\b', '777 권한 설정 (보안 위험)'),
        (r'\bchown\s+-R\s+.*/', '루트 디렉터리 소유권 변경'),
        (r'>\s*/dev/sd[a-z]', '디스크 직접 쓰기'),
        (r'\bmkfs\b', '파일 시스템 포맷'),
        (r'\bdd\s+if=.*of=/dev/', 'dd로 디스크 직접 쓰기'),

        # 환경 변수/설정 위험
        (r'export\s+PATH\s*=\s*["\']?\s*["\']?$', 'PATH 초기화'),
        (r'unset\s+PATH', 'PATH 삭제'),
    ]

    for pattern in dangerous_patterns:
        if len(pattern) == 3:
            regex, reason, flags = pattern
            if re.search(regex, command, flags):
                print(f"차단됨: {reason}\n명령어: {command}", file=sys.stderr)
                sys.exit(2)
        else:
            regex, reason = pattern
            if re.search(regex, command):
                print(f"차단됨: {reason}\n명령어: {command}", file=sys.stderr)
                sys.exit(2)

# 파일 편집 검사 (Edit, Write 도구)
if tool_name in ('Edit', 'Write'):
    file_path = tool_input.get('file_path', '')

    # 보호할 파일 패턴
    protected_patterns = [
        (r'\.env($|\.)', '환경 변수 파일 (.env)'),
        (r'\.env\.local$', '로컬 환경 변수 파일'),
        (r'\.env\.production$', '프로덕션 환경 변수 파일'),
        (r'/\.git/', 'Git 내부 파일'),
        (r'package-lock\.json$', 'package-lock.json (자동 생성 파일)'),
        (r'yarn\.lock$', 'yarn.lock (자동 생성 파일)'),
        (r'pnpm-lock\.yaml$', 'pnpm-lock.yaml (자동 생성 파일)'),
        (r'poetry\.lock$', 'poetry.lock (자동 생성 파일)'),
        (r'Pipfile\.lock$', 'Pipfile.lock (자동 생성 파일)'),
        (r'id_rsa', 'SSH 개인 키'),
        (r'\.pem$', '인증서/키 파일'),
        (r'secrets?\.ya?ml$', 'Secrets 파일'),
        (r'credentials', '자격 증명 파일'),
    ]

    for regex, reason in protected_patterns:
        if re.search(regex, file_path, re.IGNORECASE):
            print(f"차단됨: {reason} 수정 불가\n파일: {file_path}", file=sys.stderr)
            sys.exit(2)

# 모든 검사 통과
sys.exit(0)
