# AGENTS.md

## 프로젝트 개요

Spring Boot 3.4 기반 Java 백엔드 API 서버.
Java 21(LTS), Layered Architecture.

## 프로젝트 구조

```
src/main/java/com/example/app/
├── domain/       엔티티, VO, 도메인 핵심 로직 (외부 의존성 최소화)
├── repository/   Spring Data JPA / QueryDSL 인터페이스
├── service/      비즈니스 로직, 트랜잭션 경계
├── controller/   REST API 엔드포인트, 입력 검증
├── dto/          계층 간 데이터 전송 객체 (Record 권장)
├── config/       보안, DB, Swagger 등 설정
└── common/       글로벌 예외 처리, 유틸리티

src/main/resources/
└── db/migration/ Flyway 마이그레이션 파일

docs/
├── PATTERNS.md   코드 패턴 레퍼런스
└── api/
    └── openapi.yml
```

## 기술 스택

| 영역 | 기술 | 버전 |
|------|------|------|
| Language | Java | 21 (LTS) |
| Framework | Spring Boot | 3.4.x |
| ORM | Spring Data JPA + QueryDSL | Jakarta 지원 버전 |
| DB | PostgreSQL / Redis | 16.x / Cache |
| Build | Gradle Kotlin DSL | — |
| Test | JUnit5 + Mockito + AssertJ + Testcontainers | — |

## 명령어

```bash
./gradlew bootRun          # 개발 서버 실행
./gradlew clean build      # 전체 빌드
./gradlew test             # 전체 테스트
./gradlew spotlessApply    # 코드 포맷팅 자동 수정
docker-compose up -d       # 로컬 인프라 (DB, Redis) 실행
```

## 언어 규칙

- 코드, 변수명, 주석, 커밋 메시지: **영어**
- 사용자 응답, 요약, 설명: **한국어**

## 조사 원칙

- 경로, 설정값, 동작 방식은 소스 코드를 먼저 읽고 답할 것. 추측 금지.
- `/compact` 이후 새 세션 시작 시 AGENTS.md를 다시 읽고 컨텍스트 재확립.

## 작업 규칙

- 모든 코드는 `docs/PATTERNS.md`의 구조를 따른다
- 신규 기능에는 반드시 단위 테스트 포함 — 메서드명 형식: `methodName_condition_expected`
- DTO는 Java `record` 사용
- Entity 필드는 기본적으로 불변으로 설계
- 의존성 주입은 생성자 주입(`@RequiredArgsConstructor`)만 허용
- 스키마 변경 시 직접 SQL 실행 금지 — Flyway 마이그레이션 파일 생성

## 가드레일

### 출력 / 로깅
- `System.out.println`, `e.printStackTrace()` 금지 — SLF4J 로거 사용
- 빈 `catch` 블록 금지 — 로그를 남기거나 예외 재발생

### 객체 생성
- 스프링 빈(`ObjectMapper` 등)을 `new`로 직접 생성 금지 — 주입받아 사용
- 필드 주입(`@Autowired`) 금지 — 생성자 주입만 허용

### Git
- `git push --force`, `git reset --hard`, `git commit --no-verify` 금지
- 자동 커밋/푸시 금지 — 사용자 명시 요청 시에만

### DB
- Flyway 마이그레이션 파일 수동 편집 금지
- 프로덕션 DB 직접 변경 금지

@docs/patterns.md