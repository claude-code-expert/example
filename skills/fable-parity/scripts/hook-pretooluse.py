#!/usr/bin/env python3
"""PreToolUse 게이트: implement 단계 전에는 코드 파일 Edit/Write를 차단한다.

exit 2 + stderr → Claude Code가 도구 호출을 거부하고 stderr를 모델에게 전달.
상태 파일이 없으면(워크플로우 미시작) 아무것도 하지 않는다.
"""
import json
import os
import sys

data = json.load(sys.stdin)
root = os.environ.get("CLAUDE_PROJECT_DIR") or data.get("cwd") or os.getcwd()
state_dir = os.path.join(root, ".claude", "fable-parity")
phase_file = os.path.join(state_dir, "phase")

if not os.path.exists(phase_file):
    sys.exit(0)  # 게이트 비활성

phase = open(phase_file).read().strip()
if phase in ("implement", "verify", "done"):
    sys.exit(0)  # 구현 허용 단계

tool = data.get("tool_name", "")
if tool not in ("Edit", "Write", "MultiEdit", "NotebookEdit"):
    sys.exit(0)

path = os.path.abspath(data.get("tool_input", {}).get("file_path", ""))

# 허용: 파리티 산출물, .claude 설정, 문서(.md/.txt) — 분석/설계 단계의 정상 산출물
if path.startswith(os.path.abspath(state_dir)) or "/.claude/" in path or path.endswith((".md", ".txt")):
    sys.exit(0)

print(
    f"[fable-parity] 차단: 현재 단계 '{phase}' — 코드 수정은 implement 단계부터 가능하다.\n"
    f"절차: spec.md → analysis.md → design.md 작성 후 사용자 승인을 받고\n"
    f"  bash .claude/skills/fable-parity/scripts/phase.sh set implement --user-approved\n"
    f"로 전환하라. 현재 상태: phase.sh status",
    file=sys.stderr,
)
sys.exit(2)
