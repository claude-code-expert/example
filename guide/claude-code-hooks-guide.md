

# Claude Code 유용한 개발 Hooks 가이드

> ⚠️ 버전이 바뀌면서 문법이나 명령어등이 변경되는 경우가 있으므로 항상 클로드 코드에게 확인 후 실행할것

> 📘 [github.com/claude-code-expert](https://github.com/claude-code-expert) — 클로드 코드 마스터 (한빛미디어 서적 공식 리포지토리) 
> ☕ [www.brewnet.dev](https://www.brewnet.dev) — 셀프 호스팅 홈서버 자동 구축 오픈소스


## Hooks 개요

Claude Code의 Hooks는 특정 이벤트 시점에 자동으로 명령어를 실행하는 기능입니다.
`.claude/settings.json`에 설정하며, 프로젝트 단위로 관리됩니다.

> **⚠️ 포맷 주의 (2025년 이후 버전)**
> 각 훅 항목은 `hook` (단수 객체)가 아니라 `hooks` **(복수 배열)**을 사용해야 합니다.
> 잘못된 포맷은 `Settings Error`가 발생하며 해당 파일 전체가 무시됩니다. 등록된 훅과 상태는 세션 내에서 `/hooks` 메뉴를 입력해 확인하세요.

---

### 주요 Hook 이벤트

| 이벤트         | 설명                    | 용도                            |
| -------------- | ----------------------- | ------------------------------- |
| `PreToolUse`   | 도구 실행 **전**        | 실행 차단, 사전 검증, 자동 백업 |
| `PostToolUse`  | 도구 실행 **후**        | 린트, 포맷팅, 자동 수정         |
| `Notification` | Claude가 알림을 보낼 때 | 데스크탑 알림, 슬랙 연동        |
| `Stop`         | 전체 응답 완료 시       | 타입 체크, 빌드 검증, 테스트    |

> 이 외에도 `SessionStart`, `SessionEnd`, `UserPromptSubmit`, `PreCompact`, `PostCompact`, `SubagentStart`, `SubagentStop`, `PermissionRequest` 등 다수의 이벤트가 있습니다(v2.1.x 기준 27종 이상). 전체 목록은 공식 문서를 참조하세요.

---

### stdin JSON 입력

훅 명령은 환경변수가 아니라 **stdin으로 JSON**을 전달받습니다. `jq`로 필요한 값을 추출해 사용합니다.

```json
{
  "session_id": "abc123",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/absolute/path/to/file.ts"
  }
}
```

- `tool_input`의 내용은 도구마다 다릅니다. `Write`/`Edit`는 `file_path`, `Bash`는 `command` 필드를 갖습니다.

```bash
# 예시: 수정된 파일 경로 추출
f=$(jq -r '.tool_input.file_path')
```

> 공식적으로 제공되는 환경변수는 `$CLAUDE_PROJECT_DIR`(프로젝트 루트 절대경로)입니다.
> `$CLAUDE_FILE_PATH`, `$CLAUDE_TOOL_NAME`, `$CLAUDE_TOOL_INPUT` 같은 환경변수는 존재하지 않습니다.

---

### matcher 규칙

matcher는 **문자열만** 지원하며, PascalCase 공식 도구명을 사용해야 합니다.

```
"matcher": "Bash"               // 정확한 도구명 하나
"matcher": "Write|Edit"         // |로 복수 도구 지정
"matcher": "mcp__memory__.*"    // 정규식 패턴 (MCP 도구 등)
"matcher": "*"                  // 모든 도구 매칭
"matcher": ""                   // 빈 문자열 = 모든 도구 매칭 (항상 실행)
```

> `{ "tools": ["BashTool"] }` 같은 객체 형식은 지원하지 않습니다.
> 정확한 도구명, `|` 목록(`Edit|Write`), 정규식(`mcp__memory__.*` 등), `*` 또는 빈 문자열(전체 매칭)만 사용할 수 있습니다.

---

### 올바른 훅 항목 구조

```jsonc
// ❌ 잘못된 포맷 (구버전 — 현재 에러 발생)
{
  "matcher": "Write|Edit",
  "hook": {                          // 단수 객체 → 인식 안 됨
    "type": "command",
    "command": "echo done"
  }
}

// ✅ 올바른 포맷 (현재 버전)
{
  "matcher": "Write|Edit",
  "hooks": [                         // 복수 배열
    {
      "type": "command",
      "command": "echo done"
    }
  ]
}
```

---

## 전체 설정 예시

> ⚠️ 아래 예시의 주석(//)과 트레일링 콤마는 설명용이다. 실제 settings.json은 엄격한 JSON만 허용하므로 복사 시 반드시 제거할 것.

```jsonc
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(npm run dev)",
      "Bash(npm run build)",
      "Bash(npm run lint)",
      "Bash(npm run lint:fix)",
      "Bash(npm run format)",
      "Bash(npm run test)",
      "Bash(npm run test:*)",
      "Bash(npm run db:*)",
      "Bash(npx tsc --noEmit*)",
      "Bash(npx prisma *)",
      "Bash(cat *)",
      "Bash(find *)",
      "Bash(grep *)",
      "Bash(wc *)",
    ],
    "deny": [
      "Bash(git push --force*)",
      "Bash(git reset --hard*)",
      "Bash(git commit --no-verify*)",
      "Bash(npm audit fix --force*)",
      "Bash(rm -rf /*)",
      "Bash(rm -rf .git*)",
    ],
  },
  "hooks": {
    // ─────────────────────────────────────
    // 🔒 PreToolUse: 도구 실행 전 사전 검증
    // ─────────────────────────────────────
    "PreToolUse": [
      // 1) 파일 수정 전 자동 백업
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(jq -r '.tool_input.file_path // \"\"'); [ -n \"$f\" ] && [ -f \"$f\" ] && cp \"$f\" \"$f.bak\" 2>/dev/null || true",
          },
        ],
      },

      // 2) 보호 파일 수정 차단 (.env, lock 파일 등)
      //    - exit 2를 반환하면 도구 실행이 차단됨
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(jq -r '.tool_input.file_path // \"\"'); case \"$f\" in *.env|*.env.*|*.lock|*package-lock.json|*pnpm-lock.yaml) echo '⛔ 보호된 파일입니다: '$f >&2; exit 2;; esac",
          },
        ],
      },
    ],

    // ─────────────────────────────────────
    // ✅ PostToolUse: 도구 실행 후 자동 처리
    // ─────────────────────────────────────
    "PostToolUse": [
      // 3) ESLint 자동 수정
      //    - 파일 수정 후 즉시 린트 + 자동 수정 적용
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(jq -r '.tool_input.file_path // \"\"'); [ -n \"$f\" ] && npx eslint --fix \"$f\" 2>/dev/null || true",
          },
        ],
      },

      // 4) Prettier 자동 포맷팅
      //    - 코드 스타일 자동 정리
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(jq -r '.tool_input.file_path // \"\"'); [ -n \"$f\" ] && npx prettier --write \"$f\" 2>/dev/null || true",
          },
        ],
      },

      // 5) Prisma 스키마 변경 시 자동 생성
      //    - schema.prisma 수정 후 prisma generate 자동 실행
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(jq -r '.tool_input.file_path // \"\"'); if echo \"$f\" | grep -q 'schema.prisma'; then npx prisma generate 2>/dev/null; fi || true",
          },
        ],
      },

      // 6) Tailwind CSS 클래스 자동 정렬
      //    - TSX/JSX 파일 수정 시 Tailwind 클래스 순서 정리
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(jq -r '.tool_input.file_path // \"\"'); if echo \"$f\" | grep -qE '\\.(tsx|jsx)$'; then npx prettier --plugin prettier-plugin-tailwindcss --write \"$f\" 2>/dev/null; fi || true",
          },
        ],
      },

      // 7) 수정된 파일 자동 Git 스테이징
      //    - 수정 사항을 바로 스테이징 (커밋은 수동)
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(jq -r '.tool_input.file_path // \"\"'); [ -n \"$f\" ] && git add \"$f\" 2>/dev/null || true",
          },
        ],
      },
    ],

    // ─────────────────────────────────────
    // 🏁 Stop: 전체 응답 완료 후 검증
    // ─────────────────────────────────────
    "Stop": [
      // 8) TypeScript 타입 체크
      //    - 전체 프로젝트의 타입 오류 확인
      //    - 타입 에러 발생 시 exit 2 + stderr로 에러 내용을 Claude에게 전달 (수정 유도)
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "npx tsc --noEmit > /tmp/tsc-out.txt 2>&1 || { tail -20 /tmp/tsc-out.txt >&2; exit 2; }",
          },
        ],
      },

      // 9) 빌드 검증
      //    - 응답 완료 후 빌드가 깨지지 않았는지 확인
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "npm run build 2>&1 | tail -20",
          },
        ],
      },

      // 10) 관련 테스트 자동 실행
      //     - 수정된 파일과 관련된 테스트만 실행
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "npx vitest run --changed 2>&1 | tail -30 || true",
          },
        ],
      },
    ],

    // ─────────────────────────────────────
    // 🔔 Notification: 알림 연동
    // ─────────────────────────────────────
    "Notification": [
      // 11) macOS 데스크탑 알림
      //     - 권한 승인 대기, 유휴(입력 대기) 상태 등 Claude가 알림을 보낼 때 표시
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude Code가 입력을 기다리고 있습니다\" with title \"Claude Code\"' 2>/dev/null || true",
          },
        ],
      },
    ],
  },
}
```

---

## 프레임워크별 추천 조합

### Next.js + Drizzle/Prisma 프로젝트

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(jq -r '.tool_input.file_path // \"\"'); [ -n \"$f\" ] && { npx eslint --fix \"$f\" 2>/dev/null; npx prettier --write \"$f\" 2>/dev/null; } || true"
          }
        ]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(jq -r '.tool_input.file_path // \"\"'); if echo \"$f\" | grep -q 'schema.prisma'; then npx prisma generate 2>/dev/null && npx prisma validate 2>/dev/null; fi || true"
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
            "command": "npx tsc --noEmit 2>&1 | tail -20"
          }
        ]
      }
    ]
  }
}
```

### Spring Boot + Kotlin/Java 프로젝트

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(jq -r '.tool_input.file_path // \"\"'); if echo \"$f\" | grep -qE '\\.(kt|java)$'; then ./gradlew spotlessApply 2>/dev/null; fi || true"
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
            "command": "./gradlew compileKotlin 2>&1 | tail -20 || ./gradlew compileJava 2>&1 | tail -20"
          }
        ]
      },
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "./gradlew test 2>&1 | tail -30 || true"
          }
        ]
      }
    ]
  }
}
```

### Python (FastAPI / Django) 프로젝트

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(jq -r '.tool_input.file_path // \"\"'); if echo \"$f\" | grep -qE '\\.py$'; then ruff check --fix \"$f\" 2>/dev/null && ruff format \"$f\" 2>/dev/null; fi || true"
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
            "command": "mypy . --ignore-missing-imports 2>&1 | tail -20 || true"
          }
        ]
      },
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "pytest --tb=short -q 2>&1 | tail -20 || true"
          }
        ]
      }
    ]
  }
}
```

---

## 핵심 팁

### exit 코드 규칙

| exit 코드            | 동작                                                                                                                  |
| -------------------- | --------------------------------------------------------------------------------------------------------------------- |
| `0`                  | 성공, 정상 진행                                                                                                        |
| `1` 등 기타 non-zero | 비차단 오류 — stderr는 사용자에게만 표시되고 실행은 계속됨 (Claude에게 전달되지 않음)                                   |
| `2`                  | **차단 오류** — stderr가 Claude에게 전달됨. PreToolUse에서는 도구 실행을 차단하며, Stop·PostToolUse 등에서도 차단 의미로 동작 |

### 성능 고려사항

- `PostToolUse`는 **매 파일 수정마다** 실행되므로 가볍게 유지
- 무거운 검증(빌드, 전체 테스트)은 `Stop`에 배치
- 항상 `|| true`나 `2>/dev/null`로 실패 시 흐름이 끊기지 않도록 처리
- `tail -N`으로 출력량을 제한해 컨텍스트 낭비 방지

### 디버깅

- **`/hooks` 메뉴 (권장)**: 세션 내에서 `/hooks`를 입력하면 등록된 훅과 상태를 확인할 수 있습니다.
- **직접 테스트**: 훅 명령의 stdin에 샘플 JSON을 넣어 수동으로 실행해 봅니다.

```bash
# 훅 명령을 stdin 샘플 JSON으로 직접 테스트
echo '{"tool_name":"Edit","tool_input":{"file_path":"src/index.ts"}}' \
  | sh -c 'f=$(jq -r ".tool_input.file_path"); npx eslint --fix "$f"'
```

### 흔한 실수

| 실수                                      | 원인                                      | 해결                                     |
| ----------------------------------------- | ----------------------------------------- | ---------------------------------------- |
| Settings Error — `hooks: Expected array`  | `hook` (단수) 사용                        | `hooks: [...]` (복수 배열)로 변경        |
| Settings Error — `$schema: Invalid value` | `$schema`가 빈 문자열                     | 올바른 URL로 교체하거나 키 자체를 삭제   |
| 훅 파일 전체 무시                         | 위 에러 중 하나라도 있으면 파일 전체 스킵 | `/hooks` 메뉴로 에러 확인 후 수정        |
