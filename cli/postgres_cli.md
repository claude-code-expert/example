# PostgreSQL CLI 명령어 레퍼런스

---

## 1. 접속 / 종료

```bash
# PostgreSQL 접속
psql -U <user> -d <database>              # psql -U postgres -d tika

# 호스트/포트 지정 접속
psql -h <host> -p <port> -U <user> -d <database>
# psql -h localhost -p 5432 -U postgres -d tika

# 기본 접속 (현재 OS 사용자)
psql postgres

# 종료
\q
```

---

## 2. psql 메타 명령어 (백슬래시 명령어)

| 명령어 | 설명 | 예시 |
|--------|------|------|
| `\q` | psql 종료 | `\q` |
| `\l` | 데이터베이스 목록 | `\l` |
| `\c <db>` | 다른 데이터베이스로 전환 | `\c tika` |
| `\dt` | 현재 DB의 테이블 목록 | `\dt` |
| `\dt+` | 테이블 목록 (크기 포함) | `\dt+` |
| `\d <table>` | 테이블 구조 확인 | `\d tickets` |
| `\d+ <table>` | 테이블 상세 구조 (코멘트 포함) | `\d+ tickets` |
| `\di` | 인덱스 목록 | `\di` |
| `\du` | 유저/롤 목록 | `\du` |
| `\dn` | 스키마 목록 | `\dn` |
| `\df` | 함수 목록 | `\df` |
| `\dv` | 뷰 목록 | `\dv` |
| `\ds` | 시퀀스 목록 | `\ds` |
| `\dx` | 설치된 확장 목록 | `\dx` |
| `\conninfo` | 현재 연결 정보 | `\conninfo` |
| `\timing` | 쿼리 실행 시간 표시 토글 | `\timing` |
| `\x` | 확장 출력 모드 토글 (세로 표시) | `\x` |
| `\i <file>` | SQL 파일 실행 | `\i migrations/001.sql` |
| `\e` | 외부 에디터로 쿼리 편집 | `\e` |
| `\?` | 메타 명령어 도움말 | `\?` |
| `\h <command>` | SQL 명령어 도움말 | `\h CREATE TABLE` |

---

## 3. 데이터베이스 관리

### 생성

```sql
-- 기본 생성
CREATE DATABASE tika;

-- 소유자 지정
CREATE DATABASE tika OWNER tika_user;

-- 인코딩 지정
CREATE DATABASE tika
  OWNER tika_user
  ENCODING 'UTF8'
  LC_COLLATE 'en_US.UTF-8'
  LC_CTYPE 'en_US.UTF-8';
```

### 삭제

```sql
-- 데이터베이스 삭제
DROP DATABASE tika;

-- 존재할 때만 삭제
DROP DATABASE IF EXISTS tika;
```

### 셸에서 직접 실행

```bash
# createdb / dropdb 유틸리티
createdb -U postgres tika
dropdb -U postgres tika
```

---

## 4. 유저 / 롤 관리

### 생성

```sql
-- 유저 생성 (비밀번호 포함)
CREATE USER tika_user WITH PASSWORD 'your_password';

-- 롤 생성 (로그인 권한 포함)
CREATE ROLE tika_user WITH LOGIN PASSWORD 'your_password';

-- 슈퍼유저 생성
CREATE USER admin_user WITH SUPERUSER PASSWORD 'admin_pass';

-- DB 생성 권한 부여
CREATE USER tika_user WITH CREATEDB PASSWORD 'your_password';
```

### 수정

```sql
-- 비밀번호 변경
ALTER USER tika_user WITH PASSWORD 'new_password';

-- 권한 추가
ALTER USER tika_user WITH CREATEDB;

-- 슈퍼유저 권한 부여
ALTER USER tika_user WITH SUPERUSER;

-- 슈퍼유저 권한 제거
ALTER USER tika_user WITH NOSUPERUSER;
```

### 삭제

```sql
DROP USER tika_user;
DROP USER IF EXISTS tika_user;
```

---

## 5. 권한 관리 (GRANT / REVOKE)

### 데이터베이스 권한

```sql
-- DB 전체 권한 부여
GRANT ALL PRIVILEGES ON DATABASE tika TO tika_user;

-- 접속 권한만 부여
GRANT CONNECT ON DATABASE tika TO tika_user;

-- 권한 회수
REVOKE ALL PRIVILEGES ON DATABASE tika FROM tika_user;
```

### 스키마 권한

```sql
-- 스키마 사용 권한
GRANT USAGE ON SCHEMA public TO tika_user;

-- 스키마 내 테이블 생성 권한
GRANT CREATE ON SCHEMA public TO tika_user;
```

### 테이블 권한

```sql
-- 특정 테이블 전체 권한
GRANT ALL PRIVILEGES ON TABLE tickets TO tika_user;

-- 읽기 전용
GRANT SELECT ON TABLE tickets TO readonly_user;

-- 읽기 + 쓰기
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE tickets TO tika_user;

-- 현재 스키마의 모든 테이블
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO tika_user;

-- 이후 생성되는 테이블에도 자동 적용
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT ALL PRIVILEGES ON TABLES TO tika_user;

-- 시퀀스 권한 (SERIAL/auto-increment 사용 시 필수)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO tika_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO tika_user;
```

### 권한 회수

```sql
REVOKE ALL PRIVILEGES ON TABLE tickets FROM tika_user;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM tika_user;
```

---

## 6. 테이블 관리

### 생성

```sql
-- 기본 테이블 생성
CREATE TABLE tickets (
  id SERIAL PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'BACKLOG',
  priority VARCHAR(10) NOT NULL DEFAULT 'MEDIUM',
  position INTEGER NOT NULL DEFAULT 0,
  due_date DATE,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 존재하지 않을 때만 생성
CREATE TABLE IF NOT EXISTS tickets ( ... );
```

### 인덱스

```sql
-- 인덱스 생성
CREATE INDEX idx_tickets_status_position ON tickets(status, position);
CREATE INDEX idx_tickets_due_date ON tickets(due_date);

-- 유니크 인덱스
CREATE UNIQUE INDEX idx_users_email ON users(email);

-- 인덱스 삭제
DROP INDEX idx_tickets_due_date;
```

### 변경

```sql
-- 칼럼 추가
ALTER TABLE tickets ADD COLUMN user_id TEXT;

-- 칼럼 삭제
ALTER TABLE tickets DROP COLUMN user_id;

-- 칼럼 타입 변경
ALTER TABLE tickets ALTER COLUMN title TYPE VARCHAR(500);

-- 칼럼 기본값 설정
ALTER TABLE tickets ALTER COLUMN status SET DEFAULT 'BACKLOG';

-- NOT NULL 추가
ALTER TABLE tickets ALTER COLUMN title SET NOT NULL;

-- NOT NULL 제거
ALTER TABLE tickets ALTER COLUMN description DROP NOT NULL;

-- 테이블 이름 변경
ALTER TABLE tickets RENAME TO tasks;

-- 칼럼 이름 변경
ALTER TABLE tickets RENAME COLUMN due_date TO deadline;
```

### 삭제

```sql
-- 테이블 삭제
DROP TABLE tickets;

-- 존재할 때만 삭제
DROP TABLE IF EXISTS tickets;

-- 종속 객체까지 같이 삭제
DROP TABLE IF EXISTS tickets CASCADE;

-- 데이터만 삭제 (구조 유지)
TRUNCATE TABLE tickets;

-- 시퀀스(ID)까지 리셋
TRUNCATE TABLE tickets RESTART IDENTITY;
```

---

## 7. 데이터 조작 (기본 CRUD)

```sql
-- 삽입
INSERT INTO tickets (title, status, priority, position)
VALUES ('할 일 추가', 'BACKLOG', 'HIGH', 0);

-- 여러 행 삽입
INSERT INTO tickets (title, status, priority, position) VALUES
  ('작업 1', 'BACKLOG', 'HIGH', 0),
  ('작업 2', 'TODO', 'MEDIUM', 1024);

-- 조회
SELECT * FROM tickets;
SELECT id, title, status FROM tickets WHERE status = 'BACKLOG' ORDER BY position;

-- 수정
UPDATE tickets SET status = 'DONE', completed_at = NOW() WHERE id = 1;

-- 삭제
DELETE FROM tickets WHERE id = 1;

-- 행 수 확인
SELECT COUNT(*) FROM tickets;

-- 칼럼별 집계
SELECT status, COUNT(*) FROM tickets GROUP BY status;
```

---

## 8. 백업 / 복원

```bash
# 데이터베이스 백업 (SQL 덤프)
pg_dump -U postgres tika > tika_backup.sql

# 특정 테이블만 백업
pg_dump -U postgres -t tickets tika > tickets_backup.sql

# 커스텀 포맷 백업 (압축)
pg_dump -U postgres -Fc tika > tika_backup.dump

# 복원 (SQL 덤프)
psql -U postgres -d tika < tika_backup.sql

# 복원 (커스텀 포맷)
pg_restore -U postgres -d tika tika_backup.dump

# 새 DB로 복원
createdb -U postgres tika_restored
pg_restore -U postgres -d tika_restored tika_backup.dump
```

---

## 9. 서버 관리

```bash
# 서버 시작 (macOS Homebrew)
brew services start postgresql@17

# 서버 중지
brew services stop postgresql@17

# 서버 재시작
brew services restart postgresql@17

# 상태 확인
brew services info postgresql@17

# 수동 시작/중지 (pg_ctl)
pg_ctl -D /opt/homebrew/var/postgresql@17 start
pg_ctl -D /opt/homebrew/var/postgresql@17 stop
pg_ctl -D /opt/homebrew/var/postgresql@17 status
```

### 활성 연결 확인

```sql
-- 현재 활성 세션 조회
SELECT pid, usename, datname, state, query
FROM pg_stat_activity
WHERE datname = 'tika';

-- 특정 연결 종료
SELECT pg_terminate_backend(<pid>);
```

---

## 10. MarkFlow KMS 로컬 세팅

```bash
# 1. PostgreSQL 접속 (비밀번호 입력)
psql -h localhost -p 5432 -U postgres

# 2. 유저 + DB 생성
CREATE USER markflow WITH PASSWORD 'markflow';
CREATE DATABASE markflow OWNER markflow;
GRANT ALL PRIVILEGES ON DATABASE markflow TO markflow;
\c markflow
GRANT ALL PRIVILEGES ON SCHEMA public TO markflow;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO markflow;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO markflow;
\q

# 3. 접속 확인
psql -h localhost -p 5432 -U markflow -d markflow
\dt   -- 아직 테이블 없음 (마이그레이션 전)
\q

# 4. .env 설정 (apps/api/.env)
# DATABASE_URL=postgresql://markflow:markflow@localhost:5432/markflow

# 5. 마이그레이션
cd packages/db && pnpm drizzle-kit push

# 6. 서버 실행
pnpm dev
```

### MarkFlow 자주 쓰는 쿼리

```sql
-- markflow DB 접속
psql -h localhost -p 5432 -U markflow -d markflow

-- 사용자 목록
SELECT id, email, name, email_verified FROM users;

-- 이메일 인증 우회
UPDATE users SET email_verified = true WHERE email = 'test@test.com';

-- 계정 잠금 해제
UPDATE users SET locked_until = NULL, login_fail_count = 0 WHERE email = 'test@test.com';

-- 워크스페이스 목록
SELECT id, name, slug, is_public FROM workspaces;

-- 문서 목록
SELECT id, title, slug, updated_at FROM documents
WHERE workspace_id = '워크스페이스UUID' AND is_deleted = false
ORDER BY updated_at DESC;

-- 멤버 확인
SELECT wm.role, u.name, u.email
FROM workspace_members wm JOIN users u ON wm.user_id = u.id
WHERE wm.workspace_id = '워크스페이스UUID';
```

---

## 11. Tika 프로젝트 로컬 세팅 예시

```bash
# 1. PostgreSQL 접속
psql -U postgres

# 2. 유저 생성
CREATE USER tika_user WITH PASSWORD 'tika_password';

# 3. 데이터베이스 생성
CREATE DATABASE tika OWNER tika_user;

# 4. 권한 부여
GRANT ALL PRIVILEGES ON DATABASE tika TO tika_user;
\c tika
GRANT ALL PRIVILEGES ON SCHEMA public TO tika_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO tika_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO tika_user;

# 5. 확인
\l        -- tika DB 확인
\du       -- tika_user 확인
\q        -- 종료

# 6. .env.local 설정
# POSTGRES_URL=postgresql://tika_user:tika_password@localhost:5432/tika

# 7. 마이그레이션 실행
npm run db:generate
npm run db:migrate
npm run db:seed
```
