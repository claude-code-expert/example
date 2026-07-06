#!/usr/bin/env bash
# fable-parity 스킬을 대상 프로젝트에 설치한다.
#   1) .claude/skills/fable-parity/ 로 스킬 복사
#   2) .claude/settings.json 에 훅 4개 병합 (기존 훅 보존, 백업 생성)
#
# 사용법: install.sh <대상 프로젝트 경로>   (기본: 현재 디렉토리)
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
TARGET="$(cd "${1:-.}" && pwd)"
SKILL_DEST="$TARGET/.claude/skills/fable-parity"
SETTINGS="$TARGET/.claude/settings.json"

if [ "$SRC" = "$SKILL_DEST" ]; then
  echo "이미 설치 위치에서 실행 중 — 복사 생략, 훅 병합만 수행."
else
  mkdir -p "$SKILL_DEST"
  cp -r "$SRC/SKILL.md" "$SRC/reference.md" "$SRC/scripts" "$SRC/install.sh" "$SKILL_DEST/"
fi
chmod +x "$SKILL_DEST"/scripts/*.sh "$SKILL_DEST"/scripts/*.py "$SKILL_DEST/install.sh"

mkdir -p "$TARGET/.claude"
[ -f "$SETTINGS" ] && cp "$SETTINGS" "$SETTINGS.bak.$(date +%Y%m%d%H%M%S)"

python3 - "$SETTINGS" <<'PY'
import json, os, sys

settings_path = sys.argv[1]
base = "$CLAUDE_PROJECT_DIR/.claude/skills/fable-parity/scripts"

def cmd(script):
    return {"type": "command", "command": f"{base}/{script}"}

new_hooks = {
    "SessionStart":     [{"hooks": [cmd("hook-session-start.sh")]}],
    "UserPromptSubmit": [{"hooks": [cmd("hook-prompt-submit.sh")]}],
    "PreToolUse":       [{"matcher": "Edit|Write|MultiEdit|NotebookEdit",
                          "hooks": [cmd("hook-pretooluse.py")]}],
    "Stop":             [{"hooks": [cmd("hook-stop.py")]}],
}

settings = {}
if os.path.exists(settings_path):
    with open(settings_path) as f:
        settings = json.load(f)

hooks = settings.setdefault("hooks", {})
for event, entries in new_hooks.items():
    existing = hooks.setdefault(event, [])
    for entry in entries:
        marker = entry["hooks"][0]["command"]
        already = any(
            h.get("command") == marker
            for e in existing for h in e.get("hooks", [])
        )
        if not already:
            existing.append(entry)

with open(settings_path, "w") as f:
    json.dump(settings, f, ensure_ascii=False, indent=2)
    f.write("\n")

print(f"훅 병합 완료: {settings_path}")
PY

echo "설치 완료: $SKILL_DEST"
echo "다음 Claude Code 세션부터 SessionStart 훅이 파리티 지침을 주입한다."
echo "워크플로우 시작: bash .claude/skills/fable-parity/scripts/phase.sh start"
