# Claude Fable 5 실전 운용 가이드

> Claude Fable 5(`claude-fable-5`)를 실제 작업에 쓰기 위한 실무 가이드.
> 사용법 · 하위 모델 작업 분배 · 멀티 에이전트 오케스트레이션 · 워크플로우 순서 · 안티패턴 ·
> 베스트 프랙티스 프롬프트 · 스킬 활용 · 워크플로우 활용을 예시 중심으로 정리한다.
> Claude Code 세션(CLAUDE.md)과 API 직접 호출 양쪽에 적용된다.
>
> 기준: Anthropic claude-api 스킬 문서(모델 카탈로그·마이그레이션 가이드) · 검증 2026-07

---

## 0. 한눈에 — Fable 5란

Claude Fable 5는 Anthropic이 널리 출시한 가장 강력한 모델이다. 가장 까다로운 추론과
**장기 자율 에이전트 작업(long-horizon agentic)**에 쓴다. Opus 4.8과 API 표면은 거의 같지만
동작 성향과 몇 가지 파라미터 규칙이 다르다.

| 항목 | 값 | 비고 |
|---|---|---|
| 모델 ID | `claude-fable-5` | Project Glasswing에서는 `claude-mythos-5` (동일 스펙) |
| 컨텍스트 | 1M 토큰 | 기본값 = 최대값 |
| 최대 출력 | 128K 토큰 | 16K 초과는 스트리밍 필수 |
| 가격 (1M 토큰) | 입력 $10 / 출력 $50 | Opus 4.8($5/$25)의 2배 |
| Thinking | **항상 켜짐** | `thinking` 파라미터 생략 |
| 토크나이저 | Opus 4.8과 동일 | Opus 4.7/4.8에서 마이그레이션 시 토큰 수 거의 불변 |
| 데이터 보존 | **30일 필수** | ZDR(제로 데이터 보존) 조직은 전 요청 400 |

**언제 쓰나** — 밤새 도는 자율 코딩, 잘 명세된 시스템의 첫 구현, 복잡한 리팩터·리서치,
엔드투엔드 산출물(재무 분석·스프레드시트·슬라이드·문서), 대규모 병렬 서브에이전트 협업.

**언제 안 쓰나** — 일상적 코딩·요약·분류. 가격이 Opus-tier를 넘는다. "최신 모델로 업그레이드"의
기본 대상은 여전히 `claude-opus-4-8`이다. Fable 5는 **명시적으로 선택했을 때만** 쓴다.
또한 리서치 생물학·대부분의 사이버보안 콘텐츠는 안전 분류기가 거부(refusal)할 수 있다(§8).

---

## 1. 필수 설정 — 모든 요청 공통

### 1.1 기본 호출 (Python)

```python
response = client.messages.create(
    model="claude-fable-5",
    max_tokens=64000,                    # 큰 출력은 스트리밍과 함께
    # thinking 파라미터를 아예 넣지 않는다 — 항상 켜짐
    output_config={"effort": "high"},    # low | medium | high | xhigh | max
    messages=[...],
)
```

### 1.2 규칙 (어기면 400)

| 하지 말 것 | 이유 | 대신 |
|---|---|---|
| `thinking: {type: "disabled"}` | Fable 5는 400 반환 | `thinking` 파라미터를 **생략** |
| `thinking: {type: "enabled", budget_tokens: N}` | 400 | `output_config.effort`로 깊이 제어 |
| `temperature` / `top_p` / `top_k` | 400 | 프롬프트로 스타일·변주 유도 |
| 어시스턴트 프리필(마지막 assistant 턴) | 400 | `output_config.format`(구조화 출력) 또는 시스템 프롬프트 지시 |
| ZDR 조직에서 호출 | 전 요청 400 | 조직 데이터 보존을 30일 이상으로 설정 |

### 1.3 Effort — 지능/지연/비용의 핵심 레버

`output_config.effort`가 Fable 5에서 가장 중요한 제어다. **`xhigh`를 반사적으로 쓰지 말고**
`high`를 기본으로 두고 자신의 평가셋으로 sweep한다.

| effort | 용도 |
|---|---|
| `max` | 극도로 어렵고 지연 무관한 경우. 과도한 추론(overthinking) 위험 |
| `xhigh` | 가장 어려운 코딩·에이전트 작업 |
| `high` | 대부분의 지능 민감 작업의 기본값 |
| `medium` | 일상 작업. 비용 절감 |
| `low` | 서브에이전트, 단순·기계적 작업, 지연 민감 작업. **Fable 5는 low에서도 이전 모델의 xhigh/max를 능가하는 경우가 많다** |

> 작업이 정확히 끝났는데 필요 이상 오래 걸리면 effort를 내린다. 높은 effort는 뛰어난 검증 동작과
> 가장 엄밀한 산출물을 사지만, 일상 작업에서는 필요 이상으로 맥락을 모으고 숙고한다.

### 1.4 Thinking 출력 (필요 시)

Fable 5는 **원본 사고 사슬(raw chain of thought)을 절대 반환하지 않는다.** 요약만 볼 수 있다.

```python
thinking={"type": "adaptive", "display": "summarized"}  # 요약 노출. 기본값은 "omitted"(빈 문자열)
```

- 기본값 `"omitted"`이면 thinking 블록의 텍스트가 빈 문자열 → 스트리밍 UI에서는 긴 정적으로 보인다.
- 같은 모델에서 대화를 이어갈 땐 thinking 블록을 **받은 그대로**(빈 것 포함) 되돌려 보낸다.
- 다른 모델로 넘기면 Fable 5 thinking 블록은 프롬프트에서 조용히 제거된다(과금 안 됨, 스트립 불필요).

### 1.5 긴 자율 루프 — Task Budget (베타)

에이전트 루프가 스스로 토큰을 조절하도록 예산을 준다. `max_tokens`(강제 상한)와 별개로,
모델이 카운트다운을 **인지**하고 우아하게 마무리한다.

```python
response = client.beta.messages.create(
    model="claude-fable-5",
    max_tokens=128000,
    betas=["task-budgets-2026-03-13"],
    output_config={"effort": "xhigh", "task_budget": {"type": "tokens", "total": 64000}},  # 최소 20,000
    messages=[...], tools=[...],
)
```

### 1.6 스트리밍

16K 초과 출력은 스트리밍 필수(비스트리밍은 HTTP 타임아웃). `.stream()` + `.get_final_message()`.

---

## 2. 하위 모델에 대한 작업 분배

Fable 5는 비싸다(출력 $50/1M). **모든 단계를 Fable 5로 돌리지 않는다.** 판단·종합만 Fable 5에 두고,
기계적·병렬·검증 작업은 더 싼 모델에 분배한다.

### 2.1 모델 비용·능력 매트릭스

| 모델 | ID | 입력/출력 (1M) | 컨텍스트 | 역할 |
|---|---|---|---|---|
| Fable 5 | `claude-fable-5` | $10 / $50 | 1M | 최상위 오케스트레이터·설계·판단·종합 |
| Opus 4.8 | `claude-opus-4-8` | $5 / $25 | 1M | 무거운 구현·리뷰. Fable 대비 절반 가격 |
| Sonnet 5 | `claude-sonnet-5` | $3 / $15 | 1M | 대량 구현·코딩. Opus 근접 품질 |
| Haiku 4.5 | `claude-haiku-4-5` | $1 / $5 | 200K | 단순·고속 작업, 분류, 기계적 수정 |

### 2.2 분배 원칙

| 작업 성격 | 담당 모델 | effort |
|---|---|---|
| 계획·설계 판단·최종 종합·오케스트레이션 | Fable 5 | xhigh |
| 무거운 구현, 복잡한 코드 작성 | Opus 4.8 / Sonnet 5 | high–xhigh |
| 코드베이스 탐색, 다중 파일 읽기, 사용처 조사 | Sonnet 5 / Haiku 4.5 | low–medium |
| 독립 파일 단위 기계적 수정(rename·포맷) | Haiku 4.5 | low |
| 반박형 검증, 리뷰, 테스트 결과 판정 | Opus 4.8 (fresh context) | high–xhigh |

> **핵심:** 오케스트레이터는 한 모델(Fable 5)에 고정한다. 메인 루프에서 모델을 갈아끼우면 프롬프트 캐시가
> 깨진다. 값싼 하위 작업은 **서브에이전트**로 분리해 그쪽 모델을 바꾼다.

### 2.3 방법 1 — Claude Code Agent 툴 (model 오버라이드)

Claude Code에서는 `Agent` 툴의 `model` 인자로 서브에이전트 모델을 지정한다.

```
# 메인 세션: Fable 5 (또는 /model fable)
# 탐색은 저렴한 모델로 병렬 위임:
Agent(subagent_type="Explore", model="haiku",
      prompt="auth 미들웨어의 모든 호출자를 파일:라인으로 열거")
Agent(subagent_type="Explore", model="sonnet",
      prompt="결제 흐름의 데이터 모델과 기존 유사 구현을 매핑")

# 무거운 구현은 Opus로:
Agent(subagent_type="general-purpose", model="opus",
      prompt="설계 문서 X를 구현. 완료 기준: 테스트 A,B 통과")
```

### 2.4 방법 2 — API Managed Agents 멀티에이전트 (코디네이터)

프로그래밍 방식이면 코디네이터 에이전트가 다른 모델의 에이전트에 위임한다. `multiagent`는
`agents.create()`의 **최상위 필드**(툴 항목 아님).

```python
# 하위 에이전트를 각기 다른 모델로 생성
reviewer   = client.beta.agents.create(name="Reviewer",  model="claude-opus-4-8", tools=[...])
tester     = client.beta.agents.create(name="Tester",    model="claude-sonnet-5", tools=[...])

# Fable 5 코디네이터가 로스터를 가짐
lead = client.beta.agents.create(
    name="Engineering Lead",
    model="claude-fable-5",
    system="엔지니어링을 총괄한다. 리뷰는 reviewer에, 테스트는 tester에 위임하라.",
    tools=[{"type": "agent_toolset_20260401"}],
    multiagent={"type": "coordinator", "agents": [reviewer.id, tester.id, {"type": "self"}]},
)
session = client.beta.sessions.create(agent=lead.id, environment_id=env.id)
```

### 2.5 방법 3 — Advisor 툴 (실행기 + 조언자)

값싼 실행기가 대부분의 토큰을 생성하고, Fable 5가 계획만 조언한다. **조언자 모델은 실행기 이상**이어야 한다.

```python
client.beta.messages.create(
    model="claude-sonnet-5",                    # 실행기 (저렴)
    max_tokens=4096,
    betas=["advisor-tool-2026-03-01"],
    tools=[{"type": "advisor_20260301", "name": "advisor", "model": "claude-fable-5"}],  # 조언자
    messages=[...],
)
```

---

## 3. 멀티 에이전트 오케스트레이션 규칙

Fable 5는 병렬 서브에이전트 위임이 기본기다. Opus 4.8은 시키지 않으면 순차 작업하지만,
Fable 5는 **비동기로 오래 사는 서브에이전트**를 안정적으로 운용한다. 다만 기본값은 보수적이라
"언제 위임하는가"를 명시해야 최대치가 나온다.

### 3.1 규칙

1. **비동기 위임, spawn-and-block 금지.** 오래 사는 에이전트가 컨텍스트를 유지하면(캐시 절약),
   오케스트레이터가 가장 느린 서브에이전트에 병목되지 않는다.
   > 독립 서브태스크는 서브에이전트에 위임하고 그들이 도는 동안 계속 작업하라.
   > 서브에이전트가 이탈하거나 맥락이 부족하면 개입하라.
2. **위임은 트리거로 지시.** 작업이 독립 항목으로 갈라질 때(여러 파일 읽기, 여러 테스트, 여러 후보 조사)
   같은 턴에 병렬로 띄운다. 한 응답으로 끝나는 작업엔 만들지 않는다.
3. **검증은 분리.** 구현한 컨텍스트와 분리된 fresh-context 서브에이전트에 검증을 맡긴다 — 자기 검증보다 정확.
4. **결론만 회수.** 서브에이전트에는 파일 전문 덤프 대신 결론만 돌려받아 메인 컨텍스트를 아낀다.
5. **의도를 함께 준다.** Fable 5는 요청의 **이유**를 알면 더 잘한다(§7 "이유 프롬프트").
6. **verbatim 전달은 툴로.** 자율 실행 중 사용자에게 정확히 그대로 보여줄 내용은 `send_to_user`
   커스텀 툴을 준다 — 툴 입력은 절대 요약되지 않으므로 원문 그대로 도착한다(§7).

### 3.2 오케스트레이션 위임 프롬프트 (복붙)

```
독립 항목으로 갈라지는 작업(다중 파일 읽기, 다중 테스트, 다중 후보 조사)은
순차 처리하지 말고 같은 턴에 서브에이전트를 병렬로 띄워 위임하라.
서브에이전트가 도는 동안 너는 계속 일하라(비동기). 이탈·맥락 부족 시에만 개입하라.
한 응답으로 끝나는 작업(눈앞 함수 리팩터링, 단일 파일 읽기)에는 만들지 마라.
검증은 구현과 분리된 새 에이전트에 맡겨라. 서브에이전트에는 결론만 돌려받아라.
```

---

## 4. 작업 워크플로우 순서

Fable 5의 최대 강점은 "잘 명세된 목표를 받아 길게 자율 실행"이다. 단계 진입·이탈 조건을 고정한다.

```
0. 명세  →  1. 분석  →  2. 설계  →  3. 구현  →  4. 검증  →  5. 기록
```

| 단계 | 산출물 | effort | 이탈 조건 (다음 단계 진입 기준) |
|---|---|---|---|
| 0. 명세 | 목표·제약·완료 기준 1문서 | — (사람) | "완료"를 검증 가능한 문장으로 쓸 수 있음 |
| 1. 분석 | 영향 범위 맵(파일:라인, 데이터 흐름) | high | 변경이 닿는 모든 파일·호출자를 열거함 |
| 2. 설계 | 구현 계획(변경 목록 + 트레이드오프) | xhigh | 각 변경이 파일 단위로 특정되고 리스크가 명시됨 |
| 3. 구현 | 코드 + 커밋 단위 | xhigh | 계획 전 항목 완료, 빌드/린트 통과 |
| 4. 검증 | 테스트 결과 + 실제 실행 확인 | xhigh | 완료 기준 전 항목이 도구 출력으로 입증됨 |
| 5. 기록 | 배운 것 1건 = 1파일 메모 | low | — |

### 4.1 단계 0 — 명세가 성패를 가른다

Fable 5는 잘 명세된 첫 턴 하나로 최고 성능을 낸다. **전체 명세를 첫 턴에 몰아넣고 high 이상으로 돌린다.**

```
목표: [무엇을, 왜 — 누구를 위해]
제약: [건드리면 안 되는 것, 기술 스택, 스타일]
완료 기준: [검증 가능한 문장. 예: "GET /users가 200과 페이지네이션된 목록을 반환하고 테스트 X,Y 통과"]
진행 방식: 분석 → 설계 → 구현 → 검증 순서로, 각 단계 산출물을 보인 뒤 다음으로 넘어가라.
```

- Claude Code: `/goal`로 방향 설정. Managed Agents: Outcome(`user.define_outcome` + 채점 가능한 루브릭).
- 모호·점진적으로 여러 턴에 걸쳐 요구를 흘리면 토큰 효율과 성능이 떨어진다.

### 4.2 단계 1–2 — 분석·설계

1. 읽기 전에 요구사항을 한 문단으로 재진술하고 확인받는다(해석 오류 차단).
2. 관련 서브시스템별 탐색 서브에이전트를 병렬로(진입점·데이터 모델·유사 구현·테스트 현황).
3. 영향 범위 맵을 `파일:라인`으로 작성. "이 함수의 호출자 전부"까지 추적.
4. 설계는 대안 2–3개를 제시·비교 후 하나 추천. 설계안을 "반박하라, 빠진 엣지 케이스를 찾아라"
   프롬프트의 별도 검증 에이전트에 넣는다(self-verification 외부화).
5. 설계 확정 전 코드 수정 금지(Claude Code Plan Mode).

### 4.3 단계 3–4 — 구현·검증

1. 계획 항목 단위로 위에서부터. 항목 완료마다 빌드·린트.
2. **범위 이탈 금지**(§7 no-tidying 스니펫).
3. **진행 보고는 증거 기반**(§7 grounded-progress 스니펫).
4. 검증: 테스트 통과만으로 끝내지 말고 변경된 흐름을 실제로 한 번 구동(앱 실행·API 호출·CLI).
5. fresh-context 리뷰 에이전트에 diff를 넣되 **커버리지 우선**으로 시킨다(§6 안티패턴 참조).
6. 실패 시 증상이 아니라 근본 원인을 고치고 검증 전체를 재실행.

### 4.4 단계 5 — 기록(메모리)

Fable 5는 쓸 곳을 주면 학습을 기록해 다음 세션에 활용한다. `.md` 파일이면 충분하다.

> 교훈 1건 = 파일 1개, 맨 위 한 줄 요약. 수정·확정된 접근을 이유와 함께 기록.
> 저장소·이력에 이미 있는 건 저장하지 말고, 기존 메모와 겹치면 갱신, 틀린 메모는 삭제.

---

## 5. 워크플로우에서의 활용 (Claude Code Workflow)

Claude Code의 `Workflow` 툴은 서브에이전트를 결정론적으로 오케스트레이션한다.
**단계별로 모델을 라우팅**해 Fable 5는 판단·종합에, 값싼 모델은 대량 작업에 배치한다.

### 5.1 파이프라인 — 단계별 모델 라우팅

`pipeline()`은 각 아이템을 모든 단계에 독립적으로 통과시킨다(단계 간 배리어 없음).

```js
// 리뷰(값싼 모델 병렬) → 각 발견을 Fable 5가 반박 검증
const results = await pipeline(
  changedFiles,
  f => agent(`${f} 리뷰: 버그·회귀만`, {model: 'sonnet', effort: 'medium',
             phase: 'Review', schema: FINDINGS}),
  review => parallel(review.findings.map(bug => () =>
    agent(`이 발견을 반박하라(기본 refuted=true): ${bug.desc}`,
          {model: 'fable', effort: 'xhigh', phase: 'Verify', schema: VERDICT})
      .then(v => ({...bug, verdict: v}))))
);
const confirmed = results.flat().filter(Boolean).filter(f => f.verdict?.isReal);
```

### 5.2 반박형 검증 (adversarial verify)

Fable 5의 self-verification을 워크플로우로 외부화한다. N명의 독립 회의론자가 반박을 시도해 다수결로 판정.

```js
const votes = await parallel(Array.from({length: 3}, (_, i) => () =>
  agent(`반박하라: ${claim}. 불확실하면 refuted=true를 기본으로.`,
        {model: 'fable', effort: 'high', label: `verify-${i}`, schema: VERDICT})));
const survives = votes.filter(Boolean).filter(v => !v.refuted).length >= 2;
```

### 5.3 판사 패널 (judge panel)

서로 다른 각도(MVP-first, 리스크-first, 사용자-first)로 N개 안을 생성하고 Fable 5 판사들이 채점,
1등을 뼈대로 하되 2·3등의 좋은 아이디어를 접붙인다.

```js
const attempts = await parallel(ANGLES.map(a => () =>
  agent(`${a.prompt}`, {model: 'sonnet', effort: 'high', schema: DESIGN})));
const scored = await parallel(attempts.filter(Boolean).map(d => () =>
  agent(`이 설계를 채점하라: ${d.summary}`, {model: 'fable', effort: 'xhigh', schema: SCORE})));
```

### 5.4 언제 워크플로우를 쓰나

| 쓴다 | 안 쓴다 |
|---|---|
| 광범위 리뷰·감사·마이그레이션(분해→병렬 커버) | 대화형 한 턴 |
| 독립 관점·반박 검증이 정답 신뢰도를 올릴 때 | 사소한 기계적 수정 |
| 한 컨텍스트에 안 담기는 규모 | 이미 검증된 작업 |

> Workflow는 사용자가 명시적으로 멀티에이전트 오케스트레이션을 요청했을 때만 쓴다(대량 토큰 소비).
> Claude Code에서 스크립트는 `agent()`/`pipeline()`/`parallel()`로 구성한다.

---

## 6. 안티패턴 — 하지 말아야 할 것

### 6.1 파라미터 (400 에러)

- ❌ `thinking: {type: "disabled"}` — Fable 5는 400. `thinking` 파라미터를 **생략**한다.
- ❌ `budget_tokens` — 제거됨(400). effort로 대체.
- ❌ `temperature` / `top_p` / `top_k` — 400. 프롬프트로 유도.
- ❌ 어시스턴트 프리필 — 400. `output_config.format` 또는 시스템 지시.
- ❌ ZDR 조직에서 호출 — 전 요청 400. 데이터 보존 30일 이상 설정.

### 6.2 코드/응답 처리

- ❌ `response.content[0]`을 무조건 읽기 — refusal 시 content가 비어 인덱스 에러. **`stop_reason` 먼저 확인**(§8).
- ❌ 툴 입력을 원문 문자열 매칭 — Unicode·슬래시 이스케이프가 다를 수 있음. `json.loads()`/`JSON.parse()`로 파싱.
- ❌ 16K 초과 출력을 비스트리밍 — HTTP 타임아웃. 스트리밍 사용.
- ❌ 이전 모델 토큰 수 재사용 — 토크나이저는 Opus 4.8과 동일하나 Opus 4.6/Sonnet/Haiku에서 오면 재측정(`count_tokens`).

### 6.3 프롬프트/운용 성향

- ❌ **과도하게 규범적인 프롬프트.** 이전 모델용 단계별 스캐폴딩은 Fable 5 품질을 **떨어뜨린다**.
  단계 나열보다 목표·제약 진술을 선호. 마이그레이션 후 옛 스캐폴딩을 빼고 A/B.
- ❌ **심각도 필터로 recall 손실.** "심각한 것만 보고하라"를 문자 그대로 따라 발견을 누락한다.
  검증·리뷰는 "확신 낮거나 사소해도 전부 보고, 확신도·심각도 첨부"로 시키고 뒤에서 거른다(§7).
- ❌ **spawn-and-block 위임.** 서브에이전트를 띄우고 멈춰 기다리지 말고 비동기로 계속 작업.
- ❌ **컨텍스트 카운트다운 노출.** 남은 토큰 수를 보이면 Fable 5가 불안해하며 새 세션을 제안하거나
  작업을 줄인다. 명시적 예산 카운트를 UI에 띄우지 않는다.
- ❌ **높은 effort에서 무단 정리(over-tidying).** 요구 이상의 리팩터·추상화·불가능 시나리오 에러 처리
  추가. no-tidying 스니펫으로 억제(§7).
- ❌ **경계 밖 행동.** 사용자가 문제를 설명·질문·생각 중일 때 요청 없이 수정 적용, 백업 브랜치 생성,
  이메일 초안 작성 등. 경계 지시로 억제(§7).
- ❌ **자율 실행 중 되묻기.** 사용자가 실시간으로 보지 않는데 "~할까요?"로 블록. 자율 리마인더 추가(§7).
- ❌ `thinking` 생략 = 꺼짐이라 오해 — Fable 5는 생략해도 **켜짐**(Opus 4.8과 반대). 끄려 하지 말 것.

---

## 7. 베스트 프랙티스 프롬프트 (복붙용)

시스템 프롬프트 / CLAUDE.md / API `system`에 넣는다. Fable 5 마이그레이션 가이드의 튜닝 스니펫을
그대로 옮긴 것.

### 7.1 자율성 (되묻기 억제)

```
너는 자율적으로 동작한다. 사용자는 실시간으로 보지 않으며 중간 질문에 답할 수 없다.
요청에서 따라오는 되돌릴 수 있는 행동은 묻지 말고 진행하라. 사소한 결정(이름, 포맷,
기본값, 동등한 접근법 중 선택)은 합리적인 것을 골라 기록만 하라. 범위 변경이나 파괴적
작업만 먼저 확인하라. 턴을 끝내기 전 마지막 문단을 점검하라 — 그것이 계획·분석·질문·
다음 단계 목록·미완 약속("~하겠습니다")이면 지금 도구 호출로 그 작업을 하라.
작업이 끝났거나 사용자만 줄 수 있는 입력에 막혔을 때만 턴을 끝내라.
```

### 7.2 범위 (no-tidying)

```
작업이 요구하는 것 이상의 기능 추가·리팩터·추상화 도입을 하지 마라. 버그 수정에 주변
정리를 끼워 넣지 마라. 가정 불가능한 시나리오의 에러 처리·폴백·검증을 추가하지 마라.
내부 코드와 프레임워크 보장을 신뢰하라. 시스템 경계(사용자 입력·외부 API)에서만 검증하라.
불필요한 추상화를 피하고, 반쪽짜리 구현도 남기지 마라.
```

### 7.3 진행 보고 (grounded progress)

```
진행 상황을 보고하기 전에 각 주장을 이 세션의 도구 출력과 대조하라. 증거를 가리킬 수
있는 작업만 완료로 보고하고, 미검증 항목은 미검증이라고 명시하라. 테스트가 실패하면
출력과 함께 실패했다고 보고하라. 건너뛴 단계는 건너뛰었다고 말하라. 완료·검증된 것은
헤징 없이 담담히 완료라고 말하라.
```

### 7.4 경계 (boundaries)

```
사용자가 문제를 설명·질문·생각 중일 뿐 변경을 요청하지 않았다면 산출물은 너의 평가다.
발견을 보고하고 멈춰라. 요청하기 전에는 수정을 적용하지 마라. 시스템 상태를 바꾸는
명령(재시작·삭제·설정 편집) 전에는 증거가 그 행동을 실제로 뒷받침하는지 확인하라.
```

### 7.5 검증 커버리지 (심각도 필터 방지)

```
발견한 문제를 확신이 낮거나 사소해 보여도 전부 보고하라. 이 단계에서는 중요도·확신으로
거르지 마라 — 필터링은 별도 단계에서 한다. 목표는 커버리지다. 각 발견에 확신도와 예상
심각도를 붙여 하위 필터가 순위를 매기게 하라.
```

### 7.6 위임 (§3.2 재수록)

```
독립 항목으로 갈라지는 작업(다중 파일·테스트·후보 조사)은 같은 턴에 서브에이전트를
병렬로 띄워 비동기 위임하라. 서브에이전트가 도는 동안 계속 일하라. 한 응답으로 끝나는
작업엔 만들지 마라. 검증은 구현과 분리된 새 에이전트에 맡기고, 결론만 돌려받아라.
```

### 7.7 의도 전달 (이유 프롬프트)

```
나는 [더 큰 작업]을 [누구]를 위해 하고 있다. 그들은 [산출물이 가능하게 하는 것]이 필요하다.
그것을 염두에 두고: [실제 요청].
```

### 7.8 verbatim 전달 툴 (send_to_user)

자율 에이전트가 사용자에게 **정확히 그대로** 보여줄 내용(진행 수치·직접 답·부분 결과)을 전달할 때.
툴 입력은 요약되지 않으므로 원문이 그대로 도착한다.

```json
{
  "name": "send_to_user",
  "description": "사용자에게 메시지를 그대로 표시한다. 작업 종료 전 사용자가 정확히 봐야 할 진행 상황·부분 결과·직접 답에 사용.",
  "input_schema": {
    "type": "object",
    "properties": { "message": { "type": "string", "description": "표시할 내용" } },
    "required": ["message"]
  }
}
```

---

## 8. Refusal 처리 (안전 분류기)

Fable 5는 리서치 생물학·대부분 사이버보안 요청을 거부할 수 있다. 인접한 정상 작업(보안 도구·생명과학)도
가끔 오탐된다. 거부는 **HTTP 200 + `stop_reason: "refusal"`**로 온다.

```python
response = client.messages.create(model="claude-fable-5", max_tokens=1024, messages=[...])
if response.stop_reason == "refusal":     # content 읽기 전에 반드시 확인
    handle_refusal()                       # 출력 전 거부: content 빈 배열, 과금 없음
else:                                       # 중간 거부: 부분 출력 과금 — 폐기
    print(response.content[0].text)
```

**폴백은 opt-in이다.** 거부 시 요청이 그냥 멈추지 않도록, 새 `claude-fable-5` 코드는 기본으로
서버사이드 `fallbacks`를 넣는다(정책 거부 시 같은 호출 안에서 폴백 모델이 재처리).

```python
response = client.beta.messages.create(
    model="claude-fable-5",
    max_tokens=16000,
    betas=["server-side-fallback-2026-06-01"],
    fallbacks=[{"model": "claude-opus-4-8"}],
    messages=[...],
)
```

- 헤더는 정확히 `server-side-fallback-2026-06-01`. Batches API에서는 거부됨. Bedrock/Vertex/Foundry
  미지원 — 그쪽은 클라이언트사이드 미들웨어(`BetaRefusalFallbackMiddleware`) 사용.
- 최종 응답이 여전히 `stop_reason: "refusal"`이면 체인 전체가 거부한 것.

---

## 9. 스킬 활용 방안

### 9.1 Agent Skills — 문서·산출물 생성 (Messages API)

`.pptx`/`.xlsx`/`.docx`/`.pdf` 같은 작업별 스킬을 코드 실행 컨테이너에서 로드한다. **Managed Agents가
아니다** — `container` 파라미터 + 코드 실행 툴 + 두 베타 헤더.

```python
response = client.beta.messages.create(
    model="claude-fable-5", max_tokens=32000,
    betas=["code-execution-2025-08-25", "skills-2025-10-02"],
    container={"skills": [{"type": "anthropic", "skill_id": "pptx", "version": "latest"}]},
    tools=[{"type": "code_execution_20260521", "name": "code_execution"}],
    messages=[{"role": "user", "content": "X에 대한 3장짜리 발표자료를 만들어줘"}],
)
# 생성 파일은 컨테이너에 쓰이고 응답에 file_id로 온다 → Files API로 다운로드
# client.beta.files.download(file_id)
```

- 프리빌트 스킬: `pptx`, `xlsx`, `docx`, `pdf`. 커스텀 스킬은 Skills API의 `skill_id`로 참조.
- Fable 5는 스킬을 작업 중 학습한 것으로 즉석 갱신하는 데 능하다 — 그렇게 하도록 놔둔다.

### 9.2 Claude Code 스킬

Claude Code 세션에서는 `Skill` 툴로 스킬을 호출한다(사용 가능 목록 내에서만).
CLAUDE.md에 §7 스니펫을 넣어 Fable 5 성향을 보정하고, 프로젝트 스킬(예: 앱 실행·검증)을
워크플로우 단계에 배치한다.

> Fable 5는 메모리를 잘 활용하므로 "몇 턴 이상 걸리는 작업 전 메모 파일을 확인하고 새 발견을 기록하라"를
> CLAUDE.md에 명시하면 세션 간 학습이 누적된다.

---

## 10. 요청 전 체크리스트

- [ ] `thinking` 파라미터를 **생략**했는가(생략=켜짐, `disabled`는 400)
- [ ] effort: 코딩·에이전트 `xhigh` / 지능 민감 `high` / 서브에이전트·단순 `low`, 평가셋으로 sweep
- [ ] `max_tokens` 충분 + 16K 초과 출력은 스트리밍
- [ ] 첫 턴에 목표·제약·완료 기준을 모두 넣었는가(모호한 요청 금지)
- [ ] `temperature`/`top_p`/`top_k`/`budget_tokens`/프리필 없음(모두 400)
- [ ] `stop_reason == "refusal"` 처리 + 서버사이드 `fallbacks` opt-in
- [ ] 조직 데이터 보존 30일 이상(ZDR 아님)
- [ ] 하위 모델 분배: 판단=Fable, 구현=Opus/Sonnet, 탐색·기계=Haiku
- [ ] 위임·검증 커버리지·no-tidying·경계·자율 스니펫이 system/CLAUDE.md에 포함
- [ ] 긴 자율 루프에는 Task Budget(`task-budgets-2026-03-13`, ≥20K)
- [ ] 과도하게 규범적인 옛 스캐폴딩 제거 후 A/B

---

## 참고

- 모델 카탈로그·기능 조회: Models API — `client.models.retrieve("claude-fable-5")`
- Fable 5 소개: https://platform.claude.com/docs/en/about-claude/models/introducing-claude-fable-5.md
- 마이그레이션 가이드: https://platform.claude.com/docs/en/about-claude/models/migration-guide.md
- 관련 문서: `Opus48-Fable5-ko.md`(Opus 4.8을 Fable 5처럼 운용하는 역방향 지침)
- 본 문서의 행동 성향·프롬프트 스니펫은 Anthropic claude-api 스킬의 모델 마이그레이션 가이드
  (Migrating to Claude Fable 5 섹션)에 근거한다.
