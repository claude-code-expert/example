# AGENTS.md 작성 가이드

<!-- 
이 문서는 AGENTS.md 파일의 구성 방법과 각 섹션의 역할을 설명합니다.
AGENTS.md는 AI 코딩 에이전트가 프로젝트 작업 시 따라야 할 지침을 정의하는 
오픈 표준 파일입니다.

작성일: 2025-12-04
버전: 1.1
-->

---

## AGENTS.md란?

AGENTS.md는 **AI 코딩 에이전트가 프로젝트에서 작업할 때 따라야 할 지침**을 정의하는 파일이다.
AGENTS.md는 Google, OpenAI, Factory, Sourcegraph, Cursor 등 AI 소프트웨어 개발 생태계의 협업으로 탄생한 오픈 표준이다.
2025년 7월 공식화되었으며, 현재 60,000개 이상의 오픈소스 프로젝트에서 사용 중이다.
공식 사이트: https://agents.md/

### history
| 시점 | 내용 |
|------|------|
| 2025년 Spring | Sourcegraph가 AGENT.md 파일 형식 제안 |
| 2025년 6월 말 | Codex, Gemini CLI, Jules, Factory 등 주요 도구들이 AGENTS.md 채택 |
| 2025년 7월 16일 | OpenAI, Sourcegraph, Google이 공식 협업 발표 |
| 현재 | 60,000개 이상의 오픈소스 프로젝트에서 사용 중 |

**참여 기업/프로젝트:**
- Google (Jules, Gemini CLI)
- OpenAI (Codex)
- Sourcegraph
- Cursor
- Factory
- Amp

> **공식 사이트**: https://agents.md/
> **GitHub 저장소**: https://github.com/agentsmd/agents.md

### 핵심 개념

AGENTS.md는 "에이전트를 위한 README"라고 할 수 있다.

| 파일 | 대상 | 목적 |
|------|------|------|
| README.md | 인간 개발자 | 프로젝트 소개, 기여 가이드, 빠른 시작 |
| AGENTS.md | AI 코딩 에이전트 | 빌드/테스트 명령어, 코드 컨벤션, 작업 지침 |

README.md가 인간을 위한 문서라면, AGENTS.md는 AI 에이전트가 프로젝트를 이해하고 작업하는 데 필요한 **구체적이고 실행 가능한 지침**을 담는다.

### 지원 도구

현재 주요 AI 코딩 도구들이 AGENTS.md를 지원한다:

| 도구 | 지원 여부 | 비고 |
|------|----------|------|
| OpenAI Codex | ✅ | 공식 지원 |
| Google Jules | ✅ | 공식 지원 |
| Gemini CLI | ✅ | 공식 지원 |
| Cursor | ✅ | 공식 지원 |
| Factory | ✅ | 공식 지원 |
| Aider | ✅ | 지원 |
| RooCode | ✅ | 지원 |
| Zed | ✅ | 지원 |
| Claude Code | ⚠️ | CLAUDE.md 사용 (심볼릭 링크로 호환 가능) |

**Claude Code 호환 방법:**
```bash
# AGENTS.md를 기본으로 사용하고 CLAUDE.md를 심볼릭 링크로 연결
ln -s AGENTS.md CLAUDE.md
```

---

## 핵심 원칙

### 1. AI 관점에서 작성

> **인간 개발자가 아닌 AI의 관점에서 작성한다.**

| 구분 | AGENTS.md에 적합 | AGENTS.md에 부적합 |
|------|-----------------|-------------------|
| 대상 | AI 에이전트 | 인간 개발자 |
| 내용 | 실행 가능한 명령어, 코드 패턴 | PR 규칙, 커밋 메시지 컨벤션 |
| 표현 | 구체적, 명확 | 비유적, 암시적 |

### 2. 간결함 유지

AGENTS.md의 내용은 **매 요청마다 컨텍스트에 로드**된다. 따라서:

- 필수 정보만 포함
- 자주 변경되는 파일 경로보다 **기능/역할** 중심으로 설명
- 상세 내용은 별도 문서로 분리하고 링크

### 3. 실행 가능한 지침

```markdown
# ❌ Bad: 모호한 표현
테스트를 실행하세요.

# ✅ Good: 구체적인 명령어
pnpm test --run --no-color
```

---

## 필수 섹션 구성

AGENTS.md는 다음 8개의 필수 섹션으로 구성된다.

| 순서 | 섹션 | 목적 | 핵심 질문 |
|------|------|------|----------|
| 1 | 프로젝트 개요 | 맥락 파악 | 이 프로젝트는 무엇인가? |
| 2 | 프로젝트 구조 | 코드 위치 파악 | 어디에 무엇이 있는가? |
| 3 | 기술 스택 | 도구/버전 확인 | 무엇을 사용하는가? |
| 4 | 명령어 | 빌드/테스트 실행 | 어떻게 실행하는가? |
| 5 | 코딩 컨벤션 | 일관된 코드 생성 | 어떤 스타일로 작성하는가? |
| 6 | 작업 규칙 | 작업 절차 준수 | 어떤 순서로 작업하는가? |
| 7 | 금지 사항 | 위험 방지 | 절대 하면 안 되는 것은? |
| 8 | 테스트 규칙 | 품질 보장 | 테스트를 어떻게 작성하는가? |

---

## 1. 프로젝트 개요

프로젝트의 목적과 기술 기반을 1-3문장으로 간결하게 설명한다.

### 포함 내용

- 프로젝트 목적
- 핵심 기술 기반
- 현재 상태 (선택)

### 작성 예시

```markdown
## 프로젝트 개요

Spring Boot 기반 TODO API 서버.
PostgreSQL을 데이터 저장소로 사용하며, RESTful API를 제공한다.
현재 Phase 1(백엔드 API) 개발 중.
```

---

## 2. 프로젝트 구조

주요 디렉토리와 각 디렉토리의 역할을 정의한다. AI가 코드를 어디에 배치할지 판단하는 데 사용된다.

### 포함 내용

- 디렉토리 트리 구조
- 각 디렉토리의 역할 설명

### 작성 시 주의사항

> ⚠️ **파일 경로보다 기능/역할 중심으로 설명**
>
> 파일 경로는 자주 변경된다. "src/auth/handlers.ts에 인증 로직이 있다"보다
> "인증 관련 코드는 auth 모듈에서 관리한다"가 더 안정적이다.

### 작성 예시

```markdown
## 프로젝트 구조

src/
├── main/java/com/example/app/
│   ├── controller/       # REST API 엔드포인트
│   ├── service/          # 비즈니스 로직
│   ├── repository/       # 데이터 접근 계층
│   ├── domain/           # 엔티티, VO
│   ├── dto/              # Request/Response DTO
│   └── config/           # 설정 클래스
├── main/resources/
│   ├── application.yml   # 메인 설정
│   └── db/migration/     # Flyway 마이그레이션
└── test/java/            # 테스트 코드
```

<details>
<summary>📁 레이어별 책임 상세</summary>

### Controller
- HTTP 요청/응답 처리
- 입력 검증 (`@Valid`)
- Service 호출 및 결과 반환

### Service
- 비즈니스 로직 구현
- 트랜잭션 관리 (`@Transactional`)
- 여러 Repository 조합

### Repository
- 데이터 접근 추상화
- JPA/QueryDSL 쿼리

### Domain
- 엔티티 정의
- 도메인 규칙 (불변식)

</details>
```

---

## 3. 기술 스택

사용하는 기술과 버전을 명시한다. AI가 호환되는 코드를 생성하는 데 필수적이다.

### 포함 내용

- 기술명
- 버전 (필수)
- 용도 (선택)

### 작성 예시

```markdown
## 기술 스택

| 영역 | 기술 | 버전 | 비고 |
|------|------|------|------|
| Language | Java | 21 | LTS |
| Framework | Spring Boot | 3.2.x | |
| ORM | Spring Data JPA | | QueryDSL 병행 |
| Database | PostgreSQL | 15.x | |
| Build | Gradle | 8.x | Kotlin DSL |
| Test | JUnit5 + Mockito | | Testcontainers 사용 |
```

---

## 4. 명령어

자주 사용하는 빌드, 테스트, 실행 명령어를 정리한다. **명령어는 문서 초반에 배치**하는 것이 좋다.

### 포함 내용

- 개발 서버 실행
- 빌드
- 테스트 실행
- 린트/포맷팅

### 작성 예시

```markdown
## 명령어

# 개발 서버 실행
./gradlew bootRun

# 빌드
./gradlew clean build

# 테스트 실행
./gradlew test

# 특정 테스트만 실행
./gradlew test --tests "UserServiceTest"

# 린트 검사
./gradlew spotlessCheck

# 린트 자동 수정
./gradlew spotlessApply

# Docker 로컬 환경
docker-compose up -d
```

---

## 5. 코딩 컨벤션

네이밍 규칙과 코드 스타일을 정의한다. **실제 코드 예시를 포함**하면 효과적이다.

### 포함 내용

- 네이밍 규칙 (클래스, 메서드, 변수, 상수)
- 코드 스타일
- Good/Bad 패턴 예시

### 작성 예시

```markdown
## 코딩 컨벤션

### 네이밍 규칙

| 대상 | 규칙 | 예시 |
|------|------|------|
| 클래스 | PascalCase | `UserService`, `NoteController` |
| 메서드/변수 | camelCase | `getUserById`, `noteRepository` |
| 상수 | UPPER_SNAKE_CASE | `DEFAULT_PAGE_SIZE`, `MAX_RETRY` |
| 패키지 | 소문자 | `com.example.user.domain` |
| DTO | 접미사 사용 | `CreateUserRequest`, `UserResponse` |
| 엔티티 | 단수형 명사 | `User`, `Note`, `Tag` |
| DB 컬럼 | snake_case | `created_at`, `updated_at` |

### 코드 스타일

// ✅ Good: 생성자 주입, 불변 객체
@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
}

// ❌ Bad: 필드 주입
@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;
}
```

---

## 6. 작업 규칙

AI가 따라야 할 작업 절차와 원칙을 정의한다.

### 포함 내용

- 일반 원칙
- 코드 변경 워크플로우
- 에러 수정 워크플로우
- 승인이 필요한 상황

### 작성 예시

```markdown
## 작업 규칙

### 일반 원칙

1. **테스트 먼저**: 새 기능 구현 시 테스트를 먼저 작성한다
2. **작은 단위**: 한 번에 하나의 기능만 구현한다
3. **확인 후 진행**: 큰 변경 전에 계획을 먼저 공유하고 승인을 받는다

### 코드 변경 워크플로우

1. 변경 범위와 영향 분석 설명
2. 테스트 코드 먼저 작성
3. 구현 코드 작성
4. 테스트 통과 확인
5. 린트 검사 통과 확인

### 에러 수정 워크플로우

1. 에러 로그/스택 트레이스 분석
2. Root cause 설명
3. 재현 테스트 작성 (실패 확인)
4. 수정 코드 작성
5. 테스트 통과 확인

### 승인이 필요한 작업

- 500라인 이상 파일 수정
- 데이터베이스 스키마 변경
- 외부 의존성 추가/변경
- 설정 파일 변경
```

---

## 7. 금지 사항

**가장 중요한 섹션**. 위험한 명령어와 패턴을 명확히 나열한다.

### 포함 내용

- 데이터베이스 관련 금지 명령어
- Git 관련 금지 명령어
- 코드 패턴 금지 사항
- 보안 관련 금지 사항

### 작성 예시

```markdown
## 🚨 금지 사항

### 데이터베이스

-- ❌ 절대 금지 (사용자 명시적 요청 없이)
DROP TABLE ...
DROP DATABASE ...
TRUNCATE ...
DELETE FROM ... (WHERE 절 없이)
ALTER TABLE ... DROP COLUMN ...

**필수 규칙:**
- 삭제/리셋 시 반드시 사용자 승인 요청
- 기존 데이터 존재 시 마이그레이션으로 해결
- 운영 DB 직접 변경 절대 금지

### Git

# ❌ 절대 금지
git push --force
git reset --hard
git commit --no-verify

### 코드 패턴

// ❌ 절대 금지
System.out.println("debug");     // → 로거 사용
e.printStackTrace();             // → 로거 사용
new ObjectMapper();              // → Bean 주입 사용
@Autowired private field;        // → 생성자 주입 사용
catch (Exception e) { }          // → 빈 catch 블록 금지

### 보안

// ❌ 절대 금지
String query = "SELECT * FROM users WHERE id = " + userId;  // SQL Injection
String password = "admin123";  // 하드코딩된 비밀번호
```

---

## 8. 테스트 규칙

테스트 작성 방법과 네이밍 컨벤션을 정의한다.

### 포함 내용

- 테스트 네이밍 컨벤션
- 테스트 작성 패턴
- 테스트 프레임워크
- 예시 코드

### 작성 예시

```markdown
## 테스트 규칙

### 네이밍 컨벤션

패턴: methodName_조건_기대결과

예시:
- getUserById_whenUserExists_returnsUser
- getUserById_whenUserNotFound_throwsException
- createUser_withDuplicateEmail_throwsDuplicateEmailException

### 작성 패턴

given-when-then (AAA: Arrange-Act-Assert) 패턴을 사용한다.

@Test
void getUserById_whenUserExists_returnsUser() {
    // given (Arrange)
    Long userId = 1L;
    User user = User.builder().id(userId).name("홍길동").build();
    given(userRepository.findById(userId)).willReturn(Optional.of(user));
    
    // when (Act)
    UserResponse result = userService.getUser(userId);
    
    // then (Assert)
    assertThat(result.getName()).isEqualTo("홍길동");
}

### 테스트 종류

| 종류 | 도구 | 대상 |
|------|------|------|
| 단위 테스트 | JUnit5 + Mockito | Service, Util |
| 통합 테스트 | @SpringBootTest + Testcontainers | Repository, API |
| API 테스트 | MockMvc / RestAssured | Controller |
```

---

## 선택 섹션

프로젝트 특성에 따라 추가할 수 있는 섹션이다.

| 섹션 | 필요한 경우 |
|------|------------|
| API 응답 형식 | REST API 프로젝트 |
| 예외 처리 패턴 | 표준화된 에러 처리가 필요한 경우 |
| 환경 변수 | 설정이 복잡한 경우 |
| 참조 문서 | PRD, TRD 등 별도 문서가 있는 경우 |

### API 응답 형식 예시

```markdown
## API 응답 형식

### 성공 응답

{
  "success": true,
  "data": {
    "id": 1,
    "name": "홍길동"
  },
  "error": null
}

### 에러 응답

{
  "success": false,
  "data": null,
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "사용자를 찾을 수 없습니다"
  }
}
```

### 환경 변수 예시

```markdown
## 환경 변수

| 변수 | 필수 | 기본값 | 설명 |
|------|------|--------|------|
| `DATABASE_URL` | Y | - | JDBC 연결 문자열 |
| `DATABASE_USERNAME` | Y | - | DB 사용자명 |
| `DATABASE_PASSWORD` | Y | - | DB 비밀번호 |
| `JWT_SECRET` | Y | - | JWT 서명 키 |
| `PORT` | N | 8080 | 서버 포트 |
```

---

## 모노레포에서의 AGENTS.md

대규모 프로젝트나 모노레포에서는 **중첩된 AGENTS.md 파일**을 사용할 수 있다.

### 디렉토리 구조

```
my-project/
├── AGENTS.md              # 루트: 전체 프로젝트 공통 설정
├── packages/
│   ├── api/
│   │   └── AGENTS.md      # API 패키지 전용 설정
│   ├── web/
│   │   └── AGENTS.md      # 웹 패키지 전용 설정
│   └── shared/
│       └── AGENTS.md      # 공유 패키지 전용 설정
```

### 동작 방식

- 에이전트는 **디렉토리 트리에서 가장 가까운 AGENTS.md**를 읽는다
- 하위 디렉토리의 설정이 상위 설정보다 우선한다
- 각 서브프로젝트에 맞춤 지침을 제공할 수 있다

### 루트 AGENTS.md 예시

```markdown
# AGENTS.md

이 프로젝트는 웹 서비스와 CLI 도구를 포함하는 모노레포이다.
pnpm workspaces로 의존성을 관리한다.
각 패키지의 상세 지침은 해당 패키지의 AGENTS.md를 참조하라.
```

### 패키지 AGENTS.md 예시

```markdown
# packages/api/AGENTS.md

이 패키지는 Prisma를 사용하는 Node.js GraphQL API이다.

## 명령어
pnpm dev      # 개발 서버
pnpm test     # 테스트
pnpm generate # Prisma 클라이언트 생성
```

---

## 작성 체크리스트

AGENTS.md 작성 완료 후 다음 항목을 확인한다.

### 관점 확인

- [ ] AI 에이전트 관점에서 작성했는가?
- [ ] 인간 개발자용 내용(PR 규칙, 커밋 컨벤션)을 분리했는가?
- [ ] 모호한 표현 없이 구체적인가?

### 필수 섹션 확인

- [ ] 프로젝트 개요가 간결한가? (1-3문장)
- [ ] 프로젝트 구조가 명확한가?
- [ ] 기술 스택에 버전이 명시되어 있는가?
- [ ] 자주 사용하는 명령어가 포함되어 있는가?
- [ ] 코딩 컨벤션이 구체적인가?
- [ ] 작업 규칙과 워크플로우가 명확한가?
- [ ] 금지 사항이 구체적으로 나열되어 있는가?
- [ ] 테스트 규칙이 정의되어 있는가?

### 품질 확인

- [ ] Good/Bad 코드 예시가 포함되어 있는가?
- [ ] 복사해서 바로 실행 가능한 명령어인가?
- [ ] 파일 경로보다 기능/역할 중심으로 설명했는가?
- [ ] 불필요하게 긴 내용은 없는가?

---

## AGENTS.md vs CLAUDE.md vs REQUIREMENTS.md

| 항목 | AGENTS.md | CLAUDE.md | REQUIREMENTS.md |
|------|-----------|-----------|-----------------|
| **대상** | AI 에이전트 전반 | Claude Code 전용 | AI + 인간 개발자 |
| **주요 내용** | 작업 지침, 금지 사항 | 대화 스타일, 워크플로우 | 기능/기술 요구사항 |
| **도구 종속성** | 범용 (오픈 표준) | Claude 전용 | 범용 |
| **분량** | 1-3페이지 | 1-3페이지 | 3-10페이지 |
| **공식 사이트** | https://agents.md/ | Anthropic 문서 | - |

### 사용 전략

| 상황 | 권장 조합 |
|------|----------|
| Claude Code만 사용 | `CLAUDE.md` + `REQUIREMENTS.md` |
| 여러 AI 도구 사용 | `AGENTS.md` + `REQUIREMENTS.md` |
| 둘 다 사용 | `AGENTS.md`(공통) + `CLAUDE.md`(Claude 특화) 또는 심볼릭 링크 |

### 심볼릭 링크로 호환성 유지

```bash
# AGENTS.md를 기본으로 사용
# CLAUDE.md를 심볼릭 링크로 연결하여 Claude Code에서도 동일 파일 사용
ln -s AGENTS.md CLAUDE.md
```

---

## 부록: AGENTS.md 템플릿

아래는 바로 사용할 수 있는 AGENTS.md 템플릿이다.

```markdown
# AGENTS.md

## 프로젝트 개요

[프로젝트 설명 1-3문장]

## 명령어

[자주 사용하는 명령어 - 문서 초반에 배치]

## 프로젝트 구조

[디렉토리 트리와 역할]

## 기술 스택

| 영역 | 기술 | 버전 |
|------|------|------|
| | | |

## 코딩 컨벤션

### 네이밍 규칙

| 대상 | 규칙 | 예시 |
|------|------|------|
| | | |

### 코드 스타일

[Good/Bad 예시]

## 작업 규칙

### 일반 원칙

1. 
2. 
3. 

### 워크플로우

[작업 절차]

## 🚨 금지 사항

### 데이터베이스

[금지 명령어]

### Git

[금지 명령어]

### 코드 패턴

[금지 패턴]

## 테스트 규칙

### 네이밍 컨벤션

[패턴과 예시]

### 작성 패턴

[테스트 코드 예시]
```

---

## 참고 자료

- **AGENTS.md 공식 사이트**: https://agents.md/
- **GitHub 저장소**: https://github.com/agentsmd/agents.md
- **Factory 문서**: https://docs.factory.ai/cli/configuration/agents-md
- **OpenAI Codex 가이드**: https://developers.openai.com/codex/guides/agents-md
- **GitHub 블로그 - AGENTS.md 작성법**: https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/