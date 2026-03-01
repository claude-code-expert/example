# Claude Code 모바일 권한 승인 시스템 (ntfy.sh)

> Permission Prompt가 뜰 때 폰으로 푸시 알림을 받고, Allow/Deny 버튼으로 원격 승인하는 방법.
> 터미널 앞에 앉아있지 않아도 Claude Code가 멈추지 않는다.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [방법 1: claude-push (자동 설치)](#3-방법-1-claude-push-자동-설치)
4. [방법 2: 직접 구현 (수동 설정)](#4-방법-2-직접-구현-수동-설정)
5. [방법 3: 알림만 받기 (승인은 터미널에서)](#5-방법-3-알림만-받기-승인은-터미널에서)
6. [보안 고려사항](#6-보안-고려사항)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. Overview

### 배경: Permission Prompt란?

Claude Code가 도구(Bash, Write, Read 등)를 실행하기 전에 사용자 승인을 요청하는 대화형 프롬프트다.

```
Claude wants to run: rm -rf dist && npm run build
Allow? (y/n)
```

이때 사용자가 터미널에 없으면 Claude Code는 무한정 대기한다.

### 해결 방법 비교

| 방법 | 장점 | 단점 |
|------|------|------|
| 터미널에서 수동 승인 | 안전 | 자리를 비울 수 없음 |
| allowlist에 전부 등록 | 편리 | 미등록 명령은 여전히 대기 |
| **ntfy.sh 모바일 승인** | **자리 비워도 OK + 안전** | 초기 설정 필요 |

### ntfy.sh란?

HTTP 기반 무료 푸시 알림 서비스. 계정 없이 토픽 이름만 알면 알림을 주고받을 수 있다. 단일 `curl` 명령으로 알림을 보낼 수 있어서 hook 스크립트와 궁합이 좋다.

- 웹사이트: https://ntfy.sh
- 앱: iOS App Store / Google Play Store에서 "ntfy" 검색

### Architecture

```
Claude Code (PermissionRequest hook)
    │  stdin: { tool_name, tool_input, ... }
    ▼
Hook Script (bash)
    │  jq로 tool_name, tool_input 파싱
    │  ntfy.sh에 Allow/Deny 버튼 포함 알림 전송
    ▼
ntfy.sh 서버
    │  → 폰에 푸시 알림 전달
    ▼
사용자의 폰 (ntfy 앱)
    │  Allow 또는 Deny 탭
    │  → 별도 response 토픽에 결과 POST
    ▼
Hook Script (SSE로 대기 중)
    │  응답 수신 → JSON 출력
    ▼
Claude Code
    │  allow → 실행 계속
    │  deny → 실행 취소
    │  timeout → 터미널 프롬프트로 fallback
```

### Hook 이벤트 정리

| Hook 이벤트 | 용도 | 알림 제어 가능 |
|-------------|------|---------------|
| `Notification` (matcher: `permission_prompt`) | 권한 요청 시 알림 | ❌ 알림만 (읽기 전용) |
| `PermissionRequest` | 권한 요청 가로채기 | ✅ allow/deny 결정 가능 |
| `Notification` (matcher: `idle_prompt`) | 60초 이상 입력 대기 시 | ❌ 알림만 |
| `Stop` | 응답 완료 시 | ❌ 알림만 |

**핵심**: `PermissionRequest` hook만이 allow/deny **결정권**을 가진다. `Notification`은 순수 알림용.

---

## 2. Prerequisites

| 도구 | 필수 | 확인 명령 |
|------|------|----------|
| Claude Code CLI | v2.0.45+ | `claude --version` |
| bash | any | `bash --version` |
| jq | any | `jq --version` |
| curl | any | `curl --version` |
| ntfy 앱 (폰) | iOS 또는 Android | App Store / Play Store |

```bash
# jq 설치 (macOS)
brew install jq

# jq 설치 (Ubuntu/Debian)
sudo apt-get install jq
```

---

## 3. 방법 1: claude-push (자동 설치)

[coa00/claude-push](https://github.com/coa00/claude-push) 오픈소스 프로젝트를 사용하면 3분 안에 설정이 끝난다.

### 3-1. 설치

```bash
git clone https://github.com/coa00/claude-push.git
cd claude-push
bash install.sh
```

설치 스크립트가 자동으로:

1. 의존성 확인 (`jq`, `curl`)
2. ntfy 토픽 이름 입력 (또는 랜덤 생성: `claude-push-a1b2c3d4`)
3. 설정 파일 생성: `~/.config/claude-push/config`
4. Hook 스크립트 배포: `~/.local/share/claude-push/hooks/claude-push.sh`
5. `~/.claude/settings.json`에 hook 등록
6. 테스트 알림 전송

### 3-2. ntfy 앱에서 토픽 구독

설치 완료 후, 폰의 ntfy 앱에서 설치 시 생성된 토픽을 구독한다.

### 3-3. 설정 커스터마이징

```bash
# ~/.config/claude-push/config
CLAUDE_PUSH_TOPIC="my-unique-topic"   # ntfy 토픽 이름
CLAUDE_PUSH_TIMEOUT=90                 # 응답 대기 시간 (초)
```

변경 즉시 반영 (재설치 불필요).

### 3-4. 테스트

```bash
# Allow/Deny 버튼 포함 테스트 알림 전송
bash scripts/test.sh test-notify

# 설치 상태 확인
bash scripts/test.sh status
```

정상 출력:

```
=== claude-push status ===
[OK] Config: ~/.config/claude-push/config
     Topic: my-unique-topic
     Timeout: 90s
[OK] Hook: ~/.local/share/claude-push/hooks/claude-push.sh
[OK] Settings: hook registered in ~/.claude/settings.json
[OK] Dependency: jq
[OK] Dependency: curl
```

### 3-5. 제거

```bash
bash uninstall.sh
```

---

## 4. 방법 2: 직접 구현 (수동 설정)

claude-push 없이 핵심 로직만 직접 구현하는 방법. 동작 원리를 이해하고 커스터마이징하고 싶을 때 적합하다.

### 4-1. 핵심 개념

1. **두 개의 ntfy 토픽**: 알림용 토픽과 응답용 토픽을 분리하여 SSE 스트림이 자신의 알림으로 오염되지 않게 한다.
2. **Request ID**: 타임스탬프 + PID로 생성. 동시에 여러 권한 요청이 발생해도 각 응답을 올바른 요청에 매칭한다.
3. **Timeout fallback**: 응답이 없으면 출력 없이 exit 0 → Claude Code가 터미널 프롬프트로 fallback.

### 4-2. Hook 스크립트 작성

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/permission-ntfy.sh << 'SCRIPT'
#!/bin/bash
# Claude Code PermissionRequest → ntfy.sh 모바일 승인
set -euo pipefail

# ── 설정 ──────────────────────────────────────────────
TOPIC="${CLAUDE_NTFY_TOPIC:-claude-permission}"
RESPONSE_TOPIC="${TOPIC}-response"
NTFY_URL="https://ntfy.sh"
WAIT_TIMEOUT=90

# ── stdin에서 JSON 파싱 ──────────────────────────────
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT
cat > "$TMPFILE"

# jq 필수
if ! command -v jq &>/dev/null; then
  exit 0
fi

# JSON 유효성 검사
if ! jq empty < "$TMPFILE" 2>/dev/null; then
  exit 0
fi

# tool_name, tool_input 추출
TOOL_NAME=$(jq -r '.tool_name // "Unknown"' < "$TMPFILE")
TOOL_INPUT=$(jq -r '
  if .tool_input.command then .tool_input.command
  elif .tool_input.file_path then .tool_input.file_path
  elif .tool_input then (.tool_input | tostring)
  else "No details"
  end' < "$TMPFILE")

# 프로젝트명 추출
PROJECT_DIR=$(jq -r '.cwd // empty' < "$TMPFILE")
PROJECT_NAME=$(basename "${PROJECT_DIR:-$(pwd)}" 2>/dev/null || echo "unknown")

# ── Request ID 생성 (동시 요청 매칭용) ────────────────
REQ_ID="$(date +%s)-$$"

# ── ntfy.sh에 Allow/Deny 버튼 포함 알림 전송 ─────────
# tool_input 길이 제한 (ntfy 메시지 최대 4096자)
TRUNCATED_INPUT=$(printf '%s' "$TOOL_INPUT" | cut -c 1-500)

curl -s -o /dev/null "$NTFY_URL/" \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg topic "$TOPIC" \
    --arg title "[$PROJECT_NAME] $TOOL_NAME" \
    --arg message "$TRUNCATED_INPUT" \
    --arg allow_url "${NTFY_URL}/${RESPONSE_TOPIC}" \
    --arg allow_body "allow|${REQ_ID}" \
    --arg deny_url "${NTFY_URL}/${RESPONSE_TOPIC}" \
    --arg deny_body "deny|${REQ_ID}" \
    '{
      topic: $topic,
      title: $title,
      message: $message,
      priority: 4,
      tags: ["lock"],
      actions: [
        {
          action: "http",
          label: "✅ Allow",
          url: $allow_url,
          method: "POST",
          body: $allow_body
        },
        {
          action: "http",
          label: "❌ Deny",
          url: $deny_url,
          method: "POST",
          body: $deny_body
        }
      ]
    }')"

# ── SSE로 응답 대기 ──────────────────────────────────
DECISION=""

while IFS= read -r line; do
  if [[ "$line" == data:* ]]; then
    DATA="${line#data: }"
    MSG=$(echo "$DATA" | jq -r '.message // empty' 2>/dev/null)
    if [[ "$MSG" == *"|${REQ_ID}" ]]; then
      DECISION="${MSG%%|*}"
      break
    fi
  fi
done < <(curl -s -N --max-time "$WAIT_TIMEOUT" \
  -H "Accept: text/event-stream" \
  "${NTFY_URL}/${RESPONSE_TOPIC}/sse")

# ── 결과 JSON 출력 ───────────────────────────────────
if [ "$DECISION" = "allow" ]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PermissionRequest",
      decision: {
        behavior: "allow"
      }
    }
  }'
elif [ "$DECISION" = "deny" ]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PermissionRequest",
      decision: {
        behavior: "deny"
      }
    }
  }'
fi
# timeout: 출력 없이 exit 0 → 터미널 프롬프트로 fallback
SCRIPT
```

### 4-3. 실행 권한 부여

```bash
chmod +x ~/.claude/hooks/permission-ntfy.sh
```

### 4-4. 환경변수 설정

```bash
# ~/.zshenv (non-interactive 환경에서도 인식되려면 필수)
echo 'export CLAUDE_NTFY_TOPIC="my-secret-topic-abc123"' >> ~/.zshenv

# ~/.zshrc (터미널용)
echo 'export CLAUDE_NTFY_TOPIC="my-secret-topic-abc123"' >> ~/.zshrc
source ~/.zshrc
```

### 4-5. Claude Code Hook 등록

`.claude/settings.local.json`에 추가:

```jsonc
{
  // ... 기존 설정 유지 ...
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "zsh ~/.claude/hooks/permission-ntfy.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "zsh ~/.claude/hooks/notify-slack.sh"
          }
        ]
      }
    ]
  }
}
```

### 4-6. ntfy 앱에서 토픽 구독

폰의 ntfy 앱에서 `CLAUDE_NTFY_TOPIC`에 설정한 토픽을 구독한다.

### 4-7. 테스트

```bash
# 1. Webhook 직접 테스트
curl -H "Title: Test" -d "Permission test" "https://ntfy.sh/my-secret-topic-abc123"

# 2. Hook 스크립트 테스트
echo '{"tool_name":"Bash","tool_input":{"command":"npm run build"},"cwd":"/Users/me/project"}' \
  | zsh ~/.claude/hooks/permission-ntfy.sh

# 3. Claude Code 재시작 후 실제 작업 테스트
claude
```

---

## 5. 방법 3: 알림만 받기 (승인은 터미널에서)

원격 승인까지는 필요 없고, Permission Prompt가 뜰 때 **폰 알림만** 받고 싶은 경우.

### 5-1. 간단 스크립트

```bash
cat > ~/.claude/hooks/notify-permission.sh << 'SCRIPT'
#!/bin/bash
set -euo pipefail

TOPIC="${CLAUDE_NTFY_TOPIC:-claude-notify}"

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT
cat > "$TMPFILE"

if ! command -v jq &>/dev/null; then exit 0; fi
if ! jq empty < "$TMPFILE" 2>/dev/null; then exit 0; fi

MESSAGE=$(jq -r '.message // "Permission needed"' < "$TMPFILE")
PROJECT_DIR=$(jq -r '.cwd // empty' < "$TMPFILE")
PROJECT_NAME=$(basename "${PROJECT_DIR:-$(pwd)}" 2>/dev/null || echo "unknown")

# 알림 전송 (버튼 없이)
curl -s -o /dev/null \
  -H "Title: [$PROJECT_NAME] 권한 요청" \
  -H "Priority: 4" \
  -H "Tags: bell" \
  -d "$MESSAGE" \
  "https://ntfy.sh/${TOPIC}" &

# 로컬 사운드도 같이 울림 (macOS)
afplay /System/Library/Sounds/Glass.aiff &

exit 0
SCRIPT

chmod +x ~/.claude/hooks/notify-permission.sh
```

### 5-2. Hook 등록

```jsonc
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "zsh ~/.claude/hooks/notify-permission.sh"
          }
        ]
      },
      {
        "matcher": "idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Ping.aiff &"
          }
        ]
      }
    ]
  }
}
```

이 방식은 `Notification` 이벤트를 사용하므로 Claude Code 동작에 영향을 주지 않는다 (알림만 전송).

---

## 6. 보안 고려사항

### ntfy 토픽 = 공유 비밀

ntfy.sh 토픽 이름을 아는 사람은 누구나 알림을 보내거나 응답을 위조할 수 있다.

**권장 사항:**

- 랜덤하고 추측 불가능한 토픽 이름 사용 (예: `claude-perm-x8k2m9q4z1`)
- 위험한 명령 (`rm -rf`, `git push --force` 등)은 allowlist가 아닌 denylist에 등록
- 민감한 환경에서는 [ntfy.sh access control](https://docs.ntfy.sh/config/#access-control) 설정
- 또는 ntfy를 셀프 호스팅 (Docker로 가능)

### 환경변수 관리

```bash
# ✅ 토픽 이름은 환경변수로 관리
export CLAUDE_NTFY_TOPIC="my-secret-topic"

# ❌ 절대 Git에 커밋하지 않기
# .gitignore에 .claude/settings.local.json 추가
```

---

## 7. Troubleshooting

| 증상 | 원인 | 해결 |
|------|------|------|
| 알림이 안 옴 | ntfy 앱에서 토픽 미구독 | 앱에서 토픽 구독 확인 |
| 알림이 안 옴 | 환경변수 미설정 | `zsh -c 'echo $CLAUDE_NTFY_TOPIC'` 확인 |
| 알림이 안 옴 | `~/.zshrc`에만 설정 | `~/.zshenv`에 export 추가 |
| Allow 눌렀는데 반응 없음 | Request ID 불일치 (timeout) | timeout 값 늘리기 (기본 90초) |
| Allow 눌렀는데 반응 없음 | 네트워크 문제로 SSE 끊김 | `curl` 타임아웃/재연결 확인 |
| 동시에 여러 알림 올 때 혼란 | 정상 동작 | 각 알림에 Request ID가 있어 자동 매칭됨 |
| Hook이 실행 안 됨 | Claude Code 버전 구형 | `claude --version` → v2.0.45+ 필요 |
| VS Code에서 안 됨 | 알려진 버그 | CLI 환경에서만 정상 동작 (2026.02 기준) |
| timeout 후 터미널 프롬프트 안 뜸 | Hook이 비정상 종료 | 스크립트에 `set -euo pipefail` + `trap` 확인 |

### 디버그

```bash
# Hook 스크립트 직접 실행 (trace 모드)
echo '{"tool_name":"Bash","tool_input":{"command":"echo test"},"cwd":"/tmp/test"}' \
  | zsh -x ~/.claude/hooks/permission-ntfy.sh

# ntfy 토픽 모니터링 (터미널에서 실시간 확인)
curl -s "https://ntfy.sh/my-secret-topic/sse"
```

---

## 참고 자료

- [Claude Code Hooks 공식 문서](https://code.claude.com/docs/en/hooks)
- [ntfy.sh](https://ntfy.sh) — HTTP 기반 푸시 알림 서비스
- [ntfy.sh Action Buttons](https://docs.ntfy.sh/publish/#action-buttons) — 알림에 버튼 추가
- [coa00/claude-push](https://github.com/coa00/claude-push) — macOS/Linux + bash + PermissionRequest hook
- [konsti-web/claude_push](https://github.com/konsti-web/claude_push) — Windows/PowerShell 버전

---

*Last updated: 2026-03-01*
