# AGENTS.md - Java Backend

<!-- 
AGENTS.md는 AI 코딩 에이전트가 프로젝트에서 작업할 때 따라야 할 지침을 정의합니다. 
개발자가 아닌 AI 코딩 에이전트의 관점(Claude Code, Codex 등)에서 프로젝트 작업 시 따라야 할 지침을 정의합니다. 
Claude Code에서는 CLAUDE.md가 이 역할을 합니다.
-->

## 프로젝트 개요

Spring Boot 기반 백엔드 API 서버.
RESTful API를 제공하며 PostgreSQL/MySQL을 데이터 저장소로 사용한다.

## 프로젝트 구조
```
src/
├── main/
│   ├── java/com/example/app/
│   │   ├── domain/           # 엔티티, VO, 도메인 로직
│   │   ├── repository/       # JPA Repository
│   │   ├── service/          # 비즈니스 로직
│   │   ├── controller/       # REST Controller
│   │   ├── dto/              # Request/Response DTO
│   │   ├── config/           # 설정 클래스
│   │   └── common/           # 공통 유틸, 예외 처리
│   └── resources/
│       ├── application.yml   # 메인 설정
│       ├── application-{env}.yml
│       └── db/migration/     # Flyway 마이그레이션
├── test/java/                # 테스트 코드
docs/                         # 아키텍처, API 스펙 문서
docker/                       # Docker 관련 파일
```

<details>
<summary>📁 레이어별 책임</summary>

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
- 페이징, 정렬

### Domain
- 엔티티 정의
- 도메인 규칙 (불변식)
- Value Object

</details>

## 기술 스택

| 영역 | 기술 | 버전 |
|------|------|------|
| Language | Java | 21 |
| Framework | Spring Boot | 3.2.x |
| ORM | Spring Data JPA + QueryDSL | |
| Database | PostgreSQL / MySQL | 15.x / 8.x |
| Build | Gradle (Kotlin DSL) | 8.x |
| Test | JUnit5 + Mockito + Testcontainers | |
| Docs | Swagger/OpenAPI | 3.0 |

## 빌드 & 실행 명령어
```bash
# 개발 서버 실행
./gradlew bootRun

# 빌드
./gradlew clean build

# 테스트
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

## 코딩 컨벤션

### 네이밍 규칙

| 대상 | 규칙 | 예시 |
|------|------|------|
| 클래스 | PascalCase | `UserService`, `NoteController` |
| 메서드/변수 | camelCase | `getUserById`, `noteRepository` |
| 상수 | UPPER_SNAKE_CASE | `DEFAULT_PAGE_SIZE` |
| 패키지 | 소문자 | `com.example.note.domain` |
| DTO | 접미사 사용 | `CreateUserRequest`, `UserResponse` |
| 엔티티 | 단수형 명사 | `User`, `Note`, `Tag` |
| DB 컬럼 | snake_case | `created_at`, `updated_at` |

### 코드 스타일
```java
// ✅ Good: 명시적 타입, 불변 객체, 검증
@Getter
@RequiredArgsConstructor
public class CreateUserRequest {
    
    @NotBlank(message = "이름은 필수입니다")
    @Size(max = 50)
    private final String name;
    
    @Email
    @NotBlank
    private final String email;
}

// ✅ Good: Optional 적절한 사용
public Optional<User> findByEmail(String email) {
    return userRepository.findByEmail(email);
}

// ❌ Bad: Optional을 필드나 파라미터로 사용
public class User {
    private Optional<String> nickname;  // ❌
}
```

### Service 패턴
```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {
    
    private final UserRepository userRepository;
    
    public UserResponse getUser(Long id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException(id));
        return UserResponse.from(user);
    }
    
    @Transactional
    public UserResponse createUser(CreateUserRequest request) {
        validateDuplicateEmail(request.getEmail());
        
        User user = User.builder()
            .name(request.getName())
            .email(request.getEmail())
            .build();
        
        return UserResponse.from(userRepository.save(user));
    }
    
    private void validateDuplicateEmail(String email) {
        if (userRepository.existsByEmail(email)) {
            throw new DuplicateEmailException(email);
        }
    }
}
```

### Controller 패턴
```java
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<UserResponse>> getUser(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(userService.getUser(id)));
    }
    
    @PostMapping
    public ResponseEntity<ApiResponse<UserResponse>> createUser(
            @Valid @RequestBody CreateUserRequest request) {
        UserResponse response = userService.createUser(request);
        return ResponseEntity
            .status(HttpStatus.CREATED)
            .body(ApiResponse.success(response));
    }
}
```

## 테스트 규칙

### 테스트 네이밍
```java
// 패턴: methodName_조건_기대결과
@Test
void getUserById_whenUserExists_returnsUser() { }

@Test
void getUserById_whenUserNotFound_throwsException() { }

@Test
void createUser_withDuplicateEmail_throwsDuplicateEmailException() { }
```

### 단위 테스트 (Service)
```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    void getUserById_whenUserExists_returnsUser() {
        // given
        Long userId = 1L;
        User user = User.builder()
            .id(userId)
            .name("홍길동")
            .email("hong@example.com")
            .build();
        
        given(userRepository.findById(userId)).willReturn(Optional.of(user));
        
        // when
        UserResponse result = userService.getUser(userId);
        
        // then
        assertThat(result.getName()).isEqualTo("홍길동");
        assertThat(result.getEmail()).isEqualTo("hong@example.com");
    }
    
    @Test
    void getUserById_whenUserNotFound_throwsException() {
        // given
        Long userId = 999L;
        given(userRepository.findById(userId)).willReturn(Optional.empty());
        
        // when & then
        assertThatThrownBy(() -> userService.getUser(userId))
            .isInstanceOf(UserNotFoundException.class)
            .hasMessageContaining("999");
    }
}
```

### 통합 테스트 (Repository)
```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = Replace.NONE)
@Testcontainers
class UserRepositoryTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    void findByEmail_whenEmailExists_returnsUser() {
        // given
        User user = userRepository.save(
            User.builder().name("테스트").email("test@example.com").build()
        );
        
        // when
        Optional<User> found = userRepository.findByEmail("test@example.com");
        
        // then
        assertThat(found).isPresent();
        assertThat(found.get().getName()).isEqualTo("테스트");
    }
}
```

## 작업 규칙

### 일반 원칙

1. **테스트 먼저**: 새 기능 구현 시 테스트를 먼저 작성
2. **작은 단위**: 한 번에 하나의 기능만 구현
3. **확인 후 진행**: 큰 변경 전에 계획을 먼저 공유

### 코드 변경 시 워크플로우
```
1. 변경 범위와 영향 분석 설명
2. 테스트 코드 먼저 작성
3. 구현 코드 작성
4. 테스트 통과 확인
5. 린트 검사 통과 확인
```

### 에러 수정 시 워크플로우
```
1. 에러 로그/스택 트레이스 분석
2. Root cause 설명
3. 재현 테스트 작성 (실패 확인)
4. 수정 코드 작성
5. 테스트 통과 확인
```

## 🚨 절대 금지 사항

### 데이터베이스
```sql
-- ❌ 절대 금지 (사용자 명시적 요청 없이)
DROP TABLE ...
DROP DATABASE ...
TRUNCATE ...
DELETE FROM ... (WHERE 절 없이)
ALTER TABLE ... DROP COLUMN ...
```

**필수 규칙:**
- 삭제/리셋 시 반드시 사용자 승인 요청
- 기존 데이터 존재 시 마이그레이션으로 해결
- 운영 DB 직접 변경 절대 금지

### Git 명령어
```bash
# ❌ 절대 금지
git push --force
git reset --hard
git commit --no-verify
```

### 코드 패턴
```java
// ❌ 절대 금지
System.out.println("debug");     // 로거 사용
e.printStackTrace();             // 로거 사용
new ObjectMapper()               // Bean 주입 사용
@Autowired private field;        // 생성자 주입 사용
catch (Exception e) { }          // 빈 catch 블록
```

### 보안
```java
// ❌ 절대 금지
String query = "SELECT * FROM users WHERE id = " + userId;  // SQL Injection
password = "admin123";  // 하드코딩된 비밀번호
```

## 예외 처리 패턴

### 커스텀 예외 정의
```java
// 비즈니스 예외 기본 클래스
public abstract class BusinessException extends RuntimeException {
    private final ErrorCode errorCode;
    
    protected BusinessException(ErrorCode errorCode) {
        super(errorCode.getMessage());
        this.errorCode = errorCode;
    }
}

// 구체적인 예외
public class UserNotFoundException extends BusinessException {
    public UserNotFoundException(Long id) {
        super(ErrorCode.USER_NOT_FOUND);
    }
}
```

### 전역 예외 핸들러
```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiResponse<?>> handleBusinessException(BusinessException e) {
        return ResponseEntity
            .status(e.getErrorCode().getStatus())
            .body(ApiResponse.error(e.getErrorCode()));
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<?>> handleValidationException(
            MethodArgumentNotValidException e) {
        // 검증 에러 처리
    }
}
```

## API 응답 형식

### 성공 응답
```java
@Getter
@RequiredArgsConstructor(access = AccessLevel.PRIVATE)
public class ApiResponse<T> {
    private final boolean success;
    private final T data;
    private final ErrorResponse error;
    
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(true, data, null);
    }
    
    public static ApiResponse<?> error(ErrorCode errorCode) {
        return new ApiResponse<>(false, null, ErrorResponse.of(errorCode));
    }
}
```
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "홍길동",
    "email": "hong@example.com"
  },
  "error": null
}
```

### 에러 응답
```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "사용자를 찾을 수 없습니다",
    "details": null
  }
}
```

## 환경 변수
```yaml
# application.yml
spring:
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USERNAME}
    password: ${DATABASE_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate  # 운영에서는 항상 validate
```

| 변수 | 필수 | 설명 |
|------|------|------|
| `DATABASE_URL` | Y | JDBC URL |
| `DATABASE_USERNAME` | Y | DB 사용자명 |
| `DATABASE_PASSWORD` | Y | DB 비밀번호 |
| `JWT_SECRET` | Y | JWT 서명 키 |

## 참조 문서

| 문서 | 위치 | 용도 |
|------|------|------|
| API 스펙 | `/docs/api/openapi.yml` | OpenAPI 3.0 스펙 |
| ERD | `/docs/erd.puml` | 데이터베이스 구조 |
| 아키텍처 | `/docs/architecture.md` | 시스템 설계 |