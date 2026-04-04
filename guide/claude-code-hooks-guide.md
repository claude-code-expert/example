

# Claude Code 유용한 개발 Hooks 가이드

> ⚠️ 버전이 바뀌면서 문법이나 명령어등이 변경되는 경우가 있으므로 항상 클로드 코드에게 확인 후 실행할것

> 📘 [github.com/claude-code-expert](https://github.com/claude-code-expert) — 클로드 코드 마스터 (한빛미디어 서적 공식 리포지토리) 
> ☕ [www.brewnet.dev](https://www.brewnet.dev) — 셀프 호스팅 홈서버 자동 구축 오픈소스


## Hooks 개요

Claude Code의 Hooks는 특정 이벤트 시점에 자동으로 명령어를 실행하는 기능입니다.
`.claude/settings.json`에 설정하며, 프로젝트 단위로 관리됩니다.

> **⚠️ 포맷 주의 (2025년 이후 버전)**
> 각 훅 항목은 `hook` (단수 객체)가 아니라 `hooks` **(복수 배열)**을 사용해야 합니다.
> 잘못된 포맷은 `claude config list` 실행 시 `Settings Error`가 발생하며 해당 파일 전체가 무시됩니다.

---

### Hook 타이밍

| 타이밍         | 설명                    | 용도                            |
| -------------- | ----------------------- | ------------------------------- |
| `PreToolUse`   | 도구 실행 **전**        | 실행 차단, 사전 검증, 자동 백업 |
| `PostToolUse`  | 도구 실행 **후**        | 린트, 포맷팅, 자동 수정         |
| `Notification` | Claude가 알림을 보낼 때 | 데스크탑 알림, 슬랙 연동        |
| `Stop`         | 전체 응답 완료 시       | 타입 체크, 빌드 검증, 테스트    |

---

### 사용 가능한 환경변수

| 변수                 | 설명                                           | 주요 사용 타이밍        |
| -------------------- | ---------------------------------------------- | ----------------------- |
| `$CLAUDE_FILE_PATH`  | 수정된 파일의 절대 경로                        | PostToolUse, PreToolUse |
| `$CLAUDE_TOOL_NAME`  | 실행된 도구 이름 (예: `Write`, `Edit`, `Bash`) | 모든 타이밍             |
| `$CLAUDE_TOOL_INPUT` | 도구에 전달된 입력 JSON (문자열)               | PreToolUse, PostToolUse |

---

### matcher 규칙

두 가지 형식을 지원합니다.

**① 문자열 패턴 (정규식)**

도구 내부 이름을 정규식으로 매칭합니다.

```
"matcher": "write_file|edit_file|multiedit_file"   // 파일 수정 도구만
"matcher": "bash"                                   // Bash 도구만
"matcher": ""                                       // 모든 도구 (항상 실행)
```

**② 객체 형식 (tools 배열)**

```json
"matcher": { "tools": ["BashTool"] }
```

> `claude config list`의 에러 메시지 예시에서 확인된 공식 포맷입니다.
> 복수 도구 지정이나 더 명확한 매칭이 필요할 때 사용합니다.

---

### 올바른 훅 항목 구조

```jsonc
// ❌ 잘못된 포맷 (구버전 — 현재 에러 발생)
{
  "matcher": "write_file|edit_file",
  "hook": {                          // 단수 객체 → 인식 안 됨
    "type": "command",
    "command": "echo done"
  }
}

// ✅ 올바른 포맷 (현재 버전)
{
  "matcher": "write_file|edit_file",
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
        "matcher": "write_file|edit_file|multiedit_file",
        "hooks": [
          {
            "type": "command",
            "command": "if [ -f \"$CLAUDE_FILE_PATH\" ]; then cp \"$CLAUDE_FILE_PATH\" \"$CLAUDE_FILE_PATH.bak\" 2>/dev/null; fi || true",
          },
        ],
      },

      // 2) 보호 파일 수정 차단 (.env, lock 파일 등)
      //    - exit 2를 반환하면 도구 실행이 차단됨
      {
        "matcher": "write_file|edit_file|multiedit_file",
        "hooks": [
          {
            "type": "command",
            "command": "case \"$CLAUDE_FILE_PATH\" in *.env|*.env.*|*.lock|package-lock.json|pnpm-lock.yaml) echo '⛔ 보호된 파일입니다: '$CLAUDE_FILE_PATH; exit 2;; esac || true",
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
        "matcher": "write_file|edit_file|multiedit_file",
        "hooks": [
          {
            "type": "command",
            "command": "npx eslint --fix \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
          },
        ],
      },

      // 4) Prettier 자동 포맷팅
      //    - 코드 스타일 자동 정리
      {
        "matcher": "write_file|edit_file|multiedit_file",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
          },
        ],
      },

      // 5) Prisma 스키마 변경 시 자동 생성
      //    - schema.prisma 수정 후 prisma generate 자동 실행
      {
        "matcher": "write_file|edit_file|multiedit_file",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_FILE_PATH\" | grep -q 'schema.prisma'; then npx prisma generate 2>/dev/null; fi || true",
          },
        ],
      },

      // 6) Tailwind CSS 클래스 자동 정렬
      //    - TSX/JSX 파일 수정 시 Tailwind 클래스 순서 정리
      {
        "matcher": "write_file|edit_file|multiedit_file",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.(tsx|jsx)$'; then npx prettier --plugin prettier-plugin-tailwindcss --write \"$CLAUDE_FILE_PATH\" 2>/dev/null; fi || true",
          },
        ],
      },

      // 7) 수정된 파일 자동 Git 스테이징
      //    - 수정 사항을 바로 스테이징 (커밋은 수동)
      {
        "matcher": "write_file|edit_file|multiedit_file",
        "hooks": [
          {
            "type": "command",
            "command": "git add \"$CLAUDE_FILE_PATH\" 2>/dev/null || true",
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
      //    - 오류가 있으면 Claude가 인식하고 다음 턴에서 수정 시도
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "npx tsc --noEmit 2>&1 | tail -30",
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
      //     - 긴 작업 중 Claude 응답 완료 시 알림
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude Code 작업이 완료되었습니다\" with title \"Claude Code\"' 2>/dev/null || true",
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
        "matcher": "write_file|edit_file|multiedit_file",
        "hooks": [
          {
            "type": "command",
            "command": "npx eslint --fix \"$CLAUDE_FILE_PATH\" 2>/dev/null; npx prettier --write \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
          }
        ]
      },
      {
        "matcher": "write_file|edit_file|multiedit_file",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_FILE_PATH\" | grep -q 'schema.prisma'; then npx prisma generate 2>/dev/null && npx prisma validate 2>/dev/null; fi || true"
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
        "matcher": "write_file|edit_file|multiedit_file",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.(kt|java)$'; then ./gradlew spotlessApply 2>/dev/null; fi || true"
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
        "matcher": "write_file|edit_file|multiedit_file",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.py$'; then ruff check --fix \"$CLAUDE_FILE_PATH\" 2>/dev/null && ruff format \"$CLAUDE_FILE_PATH\" 2>/dev/null; fi || true"
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

| exit 코드 | 동작                                        |
| --------- | ------------------------------------------- |
| `0`       | 성공, 정상 진행                             |
| `1`       | 오류 출력이 Claude에게 전달됨 (수정 유도)   |
| `2`       | **도구 실행 자체를 차단** (PreToolUse 전용) |

### 성능 고려사항

- `PostToolUse`는 **매 파일 수정마다** 실행되므로 가볍게 유지
- 무거운 검증(빌드, 전체 테스트)은 `Stop`에 배치
- 항상 `|| true`나 `2>/dev/null`로 실패 시 흐름이 끊기지 않도록 처리
- `tail -N`으로 출력량을 제한해 컨텍스트 낭비 방지

### 디버깅

```bash
# 훅 설정 및 유효성 확인
claude config list

# 특정 훅 명령어를 직접 테스트
CLAUDE_FILE_PATH="src/index.ts" npx eslint --fix "$CLAUDE_FILE_PATH"
```

### 흔한 실수

| 실수                                      | 원인                                      | 해결                                     |
| ----------------------------------------- | ----------------------------------------- | ---------------------------------------- |
| Settings Error — `hooks: Expected array`  | `hook` (단수) 사용                        | `hooks: [...]` (복수 배열)로 변경        |
| Settings Error — `$schema: Invalid value` | `$schema`가 빈 문자열                     | 올바른 URL로 교체하거나 키 자체를 삭제   |
| 훅 파일 전체 무시                         | 위 에러 중 하나라도 있으면 파일 전체 스킵 | `claude config list`로 에러 확인 후 수정 |
