# PATTERNS.md
- AGENTS(java-back).md 에서 참조하는 파일 (.claude/rules/ 하위에 위치)

## 1. Controller & DTO

- 모든 응답은 `ApiResponse<T>` 공통 포맷으로 래핑
- 입력 DTO에는 Bean Validation(`@Valid`) 포함
- DTO는 `record` 사용

```java
// Controller
@PostMapping
public ResponseEntity<ApiResponse<UserResponse>> createUser(
        @Valid @RequestBody CreateUserRequest request) {
    UserResponse response = userService.createUser(request);
    return ResponseEntity
            .status(HttpStatus.CREATED)
            .body(ApiResponse.success(response));
}

// DTO (record)
public record CreateUserRequest(
        @NotBlank String name,
        @Email String email
) {}
```

## 2. Service & Transaction

- 클래스 레벨에 `@Transactional(readOnly = true)` 선언 (읽기 기본값)
- 변경 작업 메서드에만 `@Transactional` 추가
- 의존성은 `@RequiredArgsConstructor`로 생성자 주입

```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;

    @Transactional
    public UserResponse createUser(CreateUserRequest request) {
        User user = User.create(request.name(), request.email());
        userRepository.save(user);
        return UserResponse.from(user);
    }

    public UserResponse getUser(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));
        return UserResponse.from(user);
    }
}
```

## 3. Exception Handling

- `BusinessException`을 상속한 커스텀 예외 정의
- `GlobalExceptionHandler`에서 모든 예외를 캡처해 일관된 JSON 응답
- 빈 `catch` 블록 금지 — 로그를 남기거나 예외 재발생

```java
// 커스텀 예외
public class BusinessException extends RuntimeException {
    private final ErrorCode errorCode;

    public BusinessException(ErrorCode errorCode) {
        super(errorCode.getMessage());
        this.errorCode = errorCode;
    }
}

// 글로벌 핸들러
@RestControllerAdvice
@RequiredArgsConstructor
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiResponse<Void>> handleBusinessException(BusinessException e) {
        log.warn("Business exception: {}", e.getMessage());
        return ResponseEntity
                .status(e.getErrorCode().getStatus())
                .body(ApiResponse.fail(e.getErrorCode()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleException(Exception e) {
        log.error("Unexpected error", e);
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.fail(ErrorCode.INTERNAL_SERVER_ERROR));
    }
}
```

## 4. Test

- Given-When-Then 구조 유지
- 메서드명 형식: `methodName_condition_expected`
- 외부 의존성은 Mockito로 모킹 (`@ExtendWith(MockitoExtension.class)`)
- DB 포함 통합 테스트는 Testcontainers 사용

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @Test
    void getUser_whenExists_returnsUser() {
        // given
        User testUser = User.create("Alice", "alice@example.com");
        given(userRepository.findById(1L)).willReturn(Optional.of(testUser));

        // when
        UserResponse result = userService.getUser(1L);

        // then
        assertThat(result.name()).isEqualTo("Alice");
    }

    @Test
    void getUser_whenNotExists_throwsBusinessException() {
        // given
        given(userRepository.findById(999L)).willReturn(Optional.empty());

        // when & then
        assertThatThrownBy(() -> userService.getUser(999L))
                .isInstanceOf(BusinessException.class);
    }
}
```

## 5. Repository (QueryDSL)

- 단순 조회는 Spring Data JPA 인터페이스 사용
- 동적 쿼리는 `QuerydslRepositorySupport` 또는 `JPAQueryFactory` 사용

```java
@Repository
@RequiredArgsConstructor
public class UserQueryRepository {

    private final JPAQueryFactory queryFactory;

    public List<User> findActiveUsersByName(String name) {
        return queryFactory
                .selectFrom(user)
                .where(
                        user.name.containsIgnoreCase(name),
                        user.active.isTrue()
                )
                .orderBy(user.createdAt.desc())
                .fetch();
    }
}
```