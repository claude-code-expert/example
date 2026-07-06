#!/usr/bin/env python3
"""Stop 게이트: implement/verify 단계에서 검증 증거 없이 턴을 끝내려 하면 한 번 차단한다.

exit 2 + stderr → Claude가 멈추지 못하고 stderr 지시를 이어서 수행.
stop_hook_active=True(이미 이 훅 때문에 계속 중)면 무한 루프 방지를 위해 통과.
"""
import json
import os
import sys

data = json.load(sys.stdin)
if data.get("stop_hook_active"):
    sys.exit(0)  # 루프 가드: 차단은 스톱 체인당 1회

root = os.environ.get("CLAUDE_PROJECT_DIR") or data.get("cwd") or os.getcwd()
state_dir = os.path.join(root, ".claude", "fable-parity")
phase_file = os.path.join(state_dir, "phase")

if not os.path.exists(phase_file):
    sys.exit(0)

phase = open(phase_file).read().strip()
verify_md = os.path.join(state_dir, "verify.md")

if phase == "implement":
    print(
        "[fable-parity] 종료 차단: implement 단계에서 검증 없이 끝낼 수 없다.\n"
        "테스트 + 실제 실행으로 완료 기준을 확인하고, 증거(명령과 출력)를 "
        ".claude/fable-parity/verify.md 에 기록한 뒤 phase.sh set verify → set done 으로 진행하라.\n"
        "사용자 입력 대기가 필요한 상황이면 그 이유를 사용자에게 설명하고 끝내라.",
        file=sys.stderr,
    )
    sys.exit(2)

if phase == "verify" and not os.path.exists(verify_md):
    print(
        "[fable-parity] 종료 차단: verify 단계인데 .claude/fable-parity/verify.md 가 없다.\n"
        "완료 기준별 검증 증거(명령 + 출력)를 기록하라.",
        file=sys.stderr,
    )
    sys.exit(2)

sys.exit(0)
