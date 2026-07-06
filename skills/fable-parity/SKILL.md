---
name: fable-parity
description: >
  Opus 4.8을 Fable 5의 절차·성능으로 운용하는 강제형 워크플로우.
  spec→analyze→design→implement→verify→done 단계를 훅과 상태머신으로 강제한다.
  트리거: "fable parity", "파리티 모드", "분석-설계-구현 절차로", 새 기능·리팩터링 등
  비자명한 개발 작업 시작 시.
---

# fable-parity — Fable 5 패리티 워크플로우

이 스킬은 지침이 아니라 **강제 장치**다. 프롬프트만으로는 절차 이탈을 막을 수 없으므로
세 겹으로 강제한다:

1. **상태머신** (`scripts/phase.sh`) — 산출물 파일 없으면 단계 전환 자체가 실패 (exit 1)
2. **PreToolUse 훅** — implement 단계 전 코드 Edit/Write를 도구 수준에서 차단 (exit 2)
3. **Stop 훅** — 검증 증거(`verify.md`) 없이 턴 종료 시도를 차단

훅 설치는 `install.sh` (아래 §설치). 훅이 없어도 phase.sh 단독으로 상태머신은 동작한다.

## 실행 절차 (스킬 발동 시 이 순서를 따른다)

```bash
bash .claude/skills/fable-parity/scripts/phase.sh start
```

| 단계 | 할 일 | 산출물 (전환 전제조건) | 전환 명령 |
|---|---|---|---|
| spec | 목표·제약·완료 기준 작성, 사용자 확인 | `.claude/fable-parity/spec.md` | `phase.sh set analyze` |
| analyze | 병렬 탐색 서브에이전트로 영향 범위 맵 작성 | `.claude/fable-parity/analysis.md` | `phase.sh set design` |
| design | 접근법 2–3개 비교 → 변경 목록·리스크·완료 기준 매핑 | `.claude/fable-parity/design.md` + **사용자 승인** | `phase.sh set implement --user-approved` |
| implement | 변경 목록 순서대로 구현, 항목마다 빌드·린트 | — | `phase.sh set verify` |
| verify | 테스트 + 실제 실행, fresh-context 리뷰 에이전트 | `.claude/fable-parity/verify.md` (명령+출력 증거, PASS 포함) | `phase.sh set done` |
| done | 교훈 1건 = 1파일 기록 | — | 완료 |

규칙:
- `--user-approved`는 사용자가 design.md를 실제로 승인했을 때만 넘긴다. 임의로 넘기지 마라.
- 각 산출물 형식과 프롬프트 문구(위임 트리거, 커버리지 검증, no-tidying)는 [reference.md](reference.md) §4–§6 참조.
- 사소한 수정(오타, 한 줄 픽스)은 이 워크플로우 대상이 아니다 — `phase.sh off` 상태로 그냥 진행.

## 모델 설정 (성능 패리티)

- Claude Code: `/model opus` (effort 기본 xhigh 유지)
- API 직접 호출: `thinking={"type":"adaptive"}` **필수 명시**(생략 = 꺼짐), `output_config={"effort":"xhigh"}`,
  `max_tokens` ≥ 64K + 스트리밍. 상세는 [reference.md](reference.md) §2.

## 설치 (다른 프로젝트에 적용)

```bash
bash skills/fable-parity/install.sh /path/to/target-project
```

- 스킬을 대상 프로젝트 `.claude/skills/fable-parity/` 에 복사
- 훅 4개(SessionStart, UserPromptSubmit, PreToolUse, Stop)를 `.claude/settings.json` 에 병합 (백업 생성)

해제: `phase.sh off` (게이트만) / settings.json에서 훅 제거 (전체).
