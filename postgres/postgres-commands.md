# PostgreSQL 터미널 명령어 가이드

## 1. 접속 및 기본 명령어

### 접속

```bash
# 기본 접속
psql -U postgres

# 특정 데이터베이스 접속
psql -U username -d dbname

# 호스트/포트 지정 접속
psql -h localhost -p 5432 -U username -d dbname

# 비밀번호 프롬프트 강제
psql -U username -d dbname -W
```

### psql 메타 명령어

```sql
\l              -- 데이터베이스 목록
\dt             -- 현재 DB의 테이블 목록
\dt+            -- 테이블 목록 (상세 정보 포함)
\d 테이블명       -- 테이블 구조 확인
\d+ 테이블명      -- 테이블 구조 상세 확인
\dn             -- 스키마 목록
\du             -- 사용자(롤) 목록
\df             -- 함수 목록
\di             -- 인덱스 목록
\dv             -- 뷰 목록
\ds             -- 시퀀스 목록
\c dbname       -- 다른 데이터베이스로 전환
\conninfo       -- 현재 접속 정보 확인
\timing         -- 쿼리 실행 시간 표시 토글
\x              -- 확장 출력 모드 토글 (세로 출력)
\e              -- 외부 에디터로 쿼리 편집
\i 파일경로       -- SQL 파일 실행
\o 파일경로       -- 쿼리 결과를 파일로 출력
\q              -- psql 종료
\?              -- psql 명령어 도움말
\h              -- SQL 명령어 도움말
\h CREATE TABLE -- 특정 SQL 명령어 도움말
```

---

## 2. 사용자(롤) 관리

### 사용자 생성

```sql
-- 기본 사용자 생성
CREATE USER myuser WITH PASSWORD 'mypassword';

-- 롤로 생성 (동일)
CREATE ROLE myuser WITH LOGIN PASSWORD 'mypassword';

-- 옵션 포함 생성
CREATE USER myuser WITH
  PASSWORD 'mypassword'
  CREATEDB                -- DB 생성 권한
  CREATEROLE              -- 롤 생성 권한
  VALID UNTIL '2025-12-31'; -- 만료일 설정

-- 슈퍼유저 생성
CREATE USER admin_user WITH PASSWORD 'adminpass' SUPERUSER;
```

### 사용자 수정

```sql
-- 비밀번호 변경
ALTER USER myuser WITH PASSWORD 'newpassword';

-- 권한 변경
ALTER USER myuser WITH CREATEDB;
ALTER USER myuser WITH NOCREATEDB;
ALTER USER myuser WITH SUPERUSER;
ALTER USER myuser WITH NOSUPERUSER;

-- 사용자 이름 변경
ALTER USER myuser RENAME TO newname;
```

### 사용자 삭제

```sql
DROP USER myuser;

-- 소유 객체가 있을 경우
REASSIGN OWNED BY myuser TO postgres;
DROP OWNED BY myuser;
DROP USER myuser;
```

### 사용자 조회

```sql
-- psql 메타 명령어
\du
\du+

-- SQL로 조회
SELECT usename, usecreatedb, usesuper FROM pg_user;
SELECT rolname, rolsuper, rolcreatedb, rolcanlogin FROM pg_roles;
```

---

## 3. 데이터베이스 관리

### 데이터베이스 생성

```sql
-- 기본 생성
CREATE DATABASE mydb;

-- 소유자 지정
CREATE DATABASE mydb OWNER myuser;

-- 인코딩/로케일 지정
CREATE DATABASE mydb
  OWNER myuser
  ENCODING 'UTF8'
  LC_COLLATE 'ko_KR.UTF-8'
  LC_CTYPE 'ko_KR.UTF-8'
  TEMPLATE template0;
```

### 데이터베이스 수정/삭제

```sql
-- 이름 변경
ALTER DATABASE mydb RENAME TO newdb;

-- 소유자 변경
ALTER DATABASE mydb OWNER TO newuser;

-- 삭제
DROP DATABASE mydb;

-- 접속 중인 세션 강제 종료 후 삭제
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'mydb';
DROP DATABASE mydb;
```

### 데이터베이스 조회

```sql
\l
\l+

SELECT datname, datdba, encoding FROM pg_database;
```

---

## 4. 스키마 관리

```sql
-- 스키마 생성
CREATE SCHEMA myschema;
CREATE SCHEMA myschema AUTHORIZATION myuser;

-- 스키마 삭제
DROP SCHEMA myschema;
DROP SCHEMA myschema CASCADE;  -- 하위 객체 포함 삭제

-- 검색 경로 설정
SET search_path TO myschema, public;
ALTER DATABASE mydb SET search_path TO myschema, public;
```

---

## 5. 테이블 관리

### 테이블 생성

```sql
-- 기본 테이블
CREATE TABLE users (
  id          SERIAL PRIMARY KEY,
  username    VARCHAR(50) NOT NULL UNIQUE,
  email       VARCHAR(100) NOT NULL,
  password    VARCHAR(255) NOT NULL,
  is_active   BOOLEAN DEFAULT true,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- UUID 기본키 사용
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE posts (
  id          UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title       VARCHAR(200) NOT NULL,
  content     TEXT,
  view_count  INTEGER DEFAULT 0,
  status      VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 복합 기본키
CREATE TABLE post_tags (
  post_id     UUID REFERENCES posts(id) ON DELETE CASCADE,
  tag_id      INTEGER REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (post_id, tag_id)
);
```

### 테이블 수정

```sql
-- 컬럼 추가
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- 컬럼 삭제
ALTER TABLE users DROP COLUMN phone;

-- 컬럼 타입 변경
ALTER TABLE users ALTER COLUMN username TYPE VARCHAR(100);

-- 컬럼 이름 변경
ALTER TABLE users RENAME COLUMN username TO user_name;

-- NOT NULL 제약 추가/제거
ALTER TABLE users ALTER COLUMN email SET NOT NULL;
ALTER TABLE users ALTER COLUMN email DROP NOT NULL;

-- 기본값 설정/제거
ALTER TABLE users ALTER COLUMN is_active SET DEFAULT true;
ALTER TABLE users ALTER COLUMN is_active DROP DEFAULT;

-- 테이블 이름 변경
ALTER TABLE users RENAME TO members;

-- 제약조건 추가
ALTER TABLE users ADD CONSTRAINT uk_email UNIQUE (email);
ALTER TABLE users ADD CONSTRAINT chk_email CHECK (email LIKE '%@%');

-- 제약조건 삭제
ALTER TABLE users DROP CONSTRAINT uk_email;

-- 인덱스 생성/삭제
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_posts_created ON posts(created_at DESC);
CREATE UNIQUE INDEX idx_users_username ON users(username);
DROP INDEX idx_users_email;
```

### 테이블 삭제

```sql
DROP TABLE users;
DROP TABLE IF EXISTS users;
DROP TABLE users CASCADE;       -- 의존 객체 포함 삭제

-- 데이터만 삭제 (테이블 유지)
TRUNCATE TABLE users;
TRUNCATE TABLE users RESTART IDENTITY CASCADE;  -- 시퀀스 초기화 + 참조 데이터 삭제
```

---

## 6. 데이터 CRUD

### INSERT

```sql
-- 단일 행
INSERT INTO users (username, email, password)
VALUES ('codevillain', 'code@example.com', 'hashed_pw');

-- 다중 행
INSERT INTO users (username, email, password) VALUES
  ('user1', 'user1@example.com', 'pw1'),
  ('user2', 'user2@example.com', 'pw2'),
  ('user3', 'user3@example.com', 'pw3');

-- 충돌 시 처리 (UPSERT)
INSERT INTO users (username, email, password)
VALUES ('codevillain', 'new@example.com', 'new_pw')
ON CONFLICT (username)
DO UPDATE SET email = EXCLUDED.email, updated_at = NOW();

-- 충돌 시 무시
INSERT INTO users (username, email, password)
VALUES ('codevillain', 'code@example.com', 'pw')
ON CONFLICT DO NOTHING;

-- INSERT 후 결과 반환
INSERT INTO users (username, email, password)
VALUES ('newuser', 'new@example.com', 'pw')
RETURNING id, username;
```

### SELECT

```sql
-- 기본 조회
SELECT * FROM users;
SELECT id, username, email FROM users;

-- 조건 조회
SELECT * FROM users WHERE is_active = true;
SELECT * FROM users WHERE username LIKE '%code%';
SELECT * FROM users WHERE created_at >= '2025-01-01';
SELECT * FROM users WHERE email IN ('a@b.com', 'c@d.com');
SELECT * FROM users WHERE phone IS NULL;

-- 정렬 및 페이징
SELECT * FROM users ORDER BY created_at DESC;
SELECT * FROM users ORDER BY username ASC LIMIT 10 OFFSET 20;

-- 집계
SELECT COUNT(*) FROM users;
SELECT status, COUNT(*) FROM posts GROUP BY status;
SELECT status, COUNT(*) FROM posts GROUP BY status HAVING COUNT(*) > 5;

-- 조인
SELECT u.username, p.title
FROM users u
INNER JOIN posts p ON u.id = p.user_id;

SELECT u.username, p.title
FROM users u
LEFT JOIN posts p ON u.id = p.user_id;

-- 서브쿼리
SELECT * FROM users
WHERE id IN (SELECT DISTINCT user_id FROM posts WHERE status = 'published');

-- CTE (Common Table Expression)
WITH active_authors AS (
  SELECT user_id, COUNT(*) as post_count
  FROM posts
  WHERE status = 'published'
  GROUP BY user_id
)
SELECT u.username, a.post_count
FROM users u
JOIN active_authors a ON u.id = a.user_id
ORDER BY a.post_count DESC;
```

### UPDATE

```sql
-- 기본 업데이트
UPDATE users SET email = 'new@example.com' WHERE id = 1;

-- 다중 컬럼 업데이트
UPDATE users SET
  email = 'new@example.com',
  is_active = false,
  updated_at = NOW()
WHERE username = 'codevillain';

-- 조건부 업데이트
UPDATE posts SET status = 'archived'
WHERE created_at < NOW() - INTERVAL '1 year';

-- 업데이트 후 결과 반환
UPDATE users SET is_active = false WHERE id = 1
RETURNING *;
```

### DELETE

```sql
-- 조건 삭제
DELETE FROM users WHERE id = 1;
DELETE FROM users WHERE is_active = false;

-- 삭제 후 결과 반환
DELETE FROM posts WHERE status = 'draft'
RETURNING id, title;
```

---

## 7. 권한(GRANT/REVOKE) 관리

### 데이터베이스 권한

```sql
-- 데이터베이스 접속 권한
GRANT CONNECT ON DATABASE mydb TO myuser;
REVOKE CONNECT ON DATABASE mydb FROM myuser;

-- 데이터베이스 전체 권한
GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;
REVOKE ALL PRIVILEGES ON DATABASE mydb FROM myuser;
```

### 스키마 권한

```sql
GRANT USAGE ON SCHEMA public TO myuser;
GRANT CREATE ON SCHEMA public TO myuser;
GRANT ALL ON SCHEMA public TO myuser;
```

### 테이블 권한

```sql
-- 개별 테이블
GRANT SELECT ON users TO myuser;
GRANT SELECT, INSERT, UPDATE ON users TO myuser;
GRANT ALL PRIVILEGES ON users TO myuser;

-- 스키마 내 모든 테이블
GRANT SELECT ON ALL TABLES IN SCHEMA public TO myuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO myuser;

-- 향후 생성되는 테이블에 자동 권한 부여
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO myuser;

-- 시퀀스 권한 (SERIAL 컬럼 사용 시 필요)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO myuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO myuser;

-- 권한 회수
REVOKE ALL ON users FROM myuser;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM myuser;
```

### 권한 조회

```sql
-- 테이블 권한 확인
\dp users
\z users

-- SQL로 조회
SELECT grantee, privilege_type, table_name
FROM information_schema.table_privileges
WHERE table_schema = 'public';

-- 사용자별 권한 조회
SELECT grantee, table_name, privilege_type
FROM information_schema.table_privileges
WHERE grantee = 'myuser';
```

---

## 8. 백업 및 복원

```bash
# 데이터베이스 백업
pg_dump -U postgres mydb > backup.sql
pg_dump -U postgres -F c mydb > backup.dump       # 커스텀 포맷
pg_dump -U postgres -F c -Z 9 mydb > backup.dump   # 압축

# 특정 테이블만 백업
pg_dump -U postgres -t users mydb > users_backup.sql

# 스키마만 백업 (데이터 제외)
pg_dump -U postgres --schema-only mydb > schema.sql

# 데이터만 백업 (스키마 제외)
pg_dump -U postgres --data-only mydb > data.sql

# 전체 클러스터 백업
pg_dumpall -U postgres > all_databases.sql

# 복원
psql -U postgres mydb < backup.sql
pg_restore -U postgres -d mydb backup.dump
pg_restore -U postgres -d mydb --clean backup.dump  # 기존 객체 삭제 후 복원
```

---

## 9. 유용한 관리 쿼리

### 세션/프로세스 관리

```sql
-- 현재 접속 세션 확인
SELECT pid, usename, datname, client_addr, state, query
FROM pg_stat_activity;

-- 특정 세션 강제 종료
SELECT pg_terminate_backend(pid);

-- 특정 DB 모든 세션 종료
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'mydb' AND pid <> pg_backend_pid();
```

### 테이블 크기 조회

```sql
-- 개별 테이블 크기
SELECT pg_size_pretty(pg_total_relation_size('users'));

-- 전체 테이블 크기 순위
SELECT
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC;

-- 데이터베이스 크기
SELECT pg_size_pretty(pg_database_size('mydb'));
```

### 슬로우 쿼리 및 성능

```sql
-- 실행 계획 확인
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- 테이블 통계 갱신
ANALYZE users;

-- 테이블 정리
VACUUM users;
VACUUM FULL users;  -- 디스크 공간 회수 (테이블 잠금 발생)
VACUUM ANALYZE users;
```

### 잠금(Lock) 확인

```sql
SELECT
  l.pid,
  a.usename,
  l.relation::regclass AS table_name,
  l.mode,
  l.granted
FROM pg_locks l
JOIN pg_stat_activity a ON l.pid = a.pid
WHERE l.relation IS NOT NULL;
```
