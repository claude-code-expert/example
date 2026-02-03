# CLAUDE.md - TODO Server

<!-- 
packages/server 전용 설정
루트 CLAUDE.md를 상속하며, 서버 특화 규칙을 정의
-->

## 패키지 개요

Express 기반 REST API 서버.
Prisma ORM으로 PostgreSQL과 연동한다.

## 디렉토리 구조
```
packages/server/
├── src/
│   ├── index.ts             # 엔트리 포인트
│   ├── app.ts               # Express 앱 설정
│   ├── routes/              # 라우트 정의
│   │   ├── index.ts
│   │   └── todos.ts
│   ├── controllers/         # 요청 핸들러
│   │   └── todo.controller.ts
│   ├── services/            # 비즈니스 로직
│   │   └── todo.service.ts
│   ├── repositories/        # 데이터 접근 계층
│   │   └── todo.repository.ts
│   ├── middleware/          # 미들웨어
│   │   ├── errorHandler.ts
│   │   └── validate.ts
│   ├── lib/                 # 유틸리티
│   │   ├── prisma.ts
│   │   └── logger.ts
│   └── types/               # 로컬 타입
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
└── __tests__/
    ├── integration/         # API 통합 테스트
    └── unit/                # 단위 테스트
```

## 레이어드 아키텍처
```
Request
   ↓
┌─────────────────────────────────────┐
│ Routes (라우트 정의)                 │
│ - URL 매핑, 미들웨어 연결           │
└─────────────────────────────────────┘
   ↓
┌─────────────────────────────────────┐
│ Controllers (요청/응답 처리)         │
│ - 요청 파싱, 응답 포맷팅            │
│ - 에러 변환                         │
└─────────────────────────────────────┘
   ↓
┌─────────────────────────────────────┐
│ Services (비즈니스 로직)             │
│ - 도메인 규칙 적용                  │
│ - 트랜잭션 관리                     │
└─────────────────────────────────────┘
   ↓
┌─────────────────────────────────────┐
│ Repositories (데이터 접근)           │
│ - Prisma 쿼리                       │
│ - 데이터 매핑                       │
└─────────────────────────────────────┘
   ↓
Database
```

## 코드 패턴

### 라우트 정의
```typescript
// routes/todos.ts
import { Router } from 'express';
import { todoController } from '../controllers/todo.controller';
import { validate } from '../middleware/validate';
import { createTodoSchema, updateTodoSchema } from '@todo-app/shared';

const router = Router();

router.get('/', todoController.getAll);
router.post('/', validate(createTodoSchema), todoController.create);
router.get('/:id', todoController.getById);
router.patch('/:id', validate(updateTodoSchema), todoController.update);
router.delete('/:id', todoController.delete);

export default router;
```

### 컨트롤러
```typescript
// controllers/todo.controller.ts
import { Request, Response, NextFunction } from 'express';
import { todoService } from '../services/todo.service';
import type { CreateTodoInput, UpdateTodoInput } from '@todo-app/shared';

export const todoController = {
  async getAll(req: Request, res: Response, next: NextFunction) {
    try {
      const { completed } = req.query;
      const filter = completed !== undefined 
        ? { completed: completed === 'true' } 
        : undefined;
      
      const todos = await todoService.findAll(filter);
      
      res.json({ data: todos });
    } catch (error) {
      next(error);
    }
  },

  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const input: CreateTodoInput = req.body;
      const todo = await todoService.create(input);
      
      res.status(201).json({ data: todo });
    } catch (error) {
      next(error);
    }
  },

  // ...
};
```

### 서비스
```typescript
// services/todo.service.ts
import { todoRepository } from '../repositories/todo.repository';
import type { Todo, CreateTodoInput, UpdateTodoInput } from '@todo-app/shared';
import { NotFoundError } from '../lib/errors';

export const todoService = {
  async findAll(filter?: { completed?: boolean }): Promise<Todo[]> {
    return todoRepository.findMany(filter);
  },

  async findById(id: string): Promise<Todo> {
    const todo = await todoRepository.findById(id);
    
    if (!todo) {
      throw new NotFoundError(`Todo with id ${id} not found`);
    }
    
    return todo;
  },

  async create(input: CreateTodoInput): Promise<Todo> {
    return todoRepository.create({
      title: input.title.trim(),
      completed: false,
    });
  },

  async update(id: string, input: UpdateTodoInput): Promise<Todo> {
    await this.findById(id); // 존재 확인
    
    return todoRepository.update(id, {
      ...(input.title && { title: input.title.trim() }),
      ...(input.completed !== undefined && { completed: input.completed }),
    });
  },

  async delete(id: string): Promise<void> {
    await this.findById(id); // 존재 확인
    await todoRepository.delete(id);
  },
};
```

### 리포지토리
```typescript
// repositories/todo.repository.ts
import { prisma } from '../lib/prisma';
import type { Todo } from '@todo-app/shared';

export const todoRepository = {
  async findMany(filter?: { completed?: boolean }): Promise<Todo[]> {
    return prisma.todo.findMany({
      where: filter,
      orderBy: { createdAt: 'desc' },
    });
  },

  async findById(id: string): Promise<Todo | null> {
    return prisma.todo.findUnique({
      where: { id },
    });
  },

  async create(data: { title: string; completed: boolean }): Promise<Todo> {
    return prisma.todo.create({ data });
  },

  async update(id: string, data: Partial<{ title: string; completed: boolean }>): Promise<Todo> {
    return prisma.todo.update({
      where: { id },
      data,
    });
  },

  async delete(id: string): Promise<void> {
    await prisma.todo.delete({ where: { id } });
  },
};
```

## 에러 처리

### 커스텀 에러 클래스
```typescript
// lib/errors.ts
export class AppError extends Error {
  constructor(
    public code: string,
    message: string,
    public statusCode: number = 500
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export class NotFoundError extends AppError {
  constructor(message: string) {
    super('NOT_FOUND', message, 404);
  }
}

export class ValidationError extends AppError {
  constructor(message: string, public details?: Record<string, unknown>) {
    super('VALIDATION_ERROR', message, 400);
  }
}
```

### 에러 핸들러 미들웨어
```typescript
// middleware/errorHandler.ts
import { Request, Response, NextFunction } from 'express';
import { AppError } from '../lib/errors';
import { logger } from '../lib/logger';

export function errorHandler(
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction
) {
  logger.error('Error occurred:', error);

  if (error instanceof AppError) {
    return res.status(error.statusCode).json({
      error: {
        code: error.code,
        message: error.message,
        ...(error instanceof ValidationError && { details: error.details }),
      },
    });
  }

  // 예상치 못한 에러
  res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred',
    },
  });
}
```

## 테스트 규칙

### 통합 테스트 (API)
```typescript
// __tests__/integration/todos.test.ts
import request from 'supertest';
import { app } from '../../src/app';
import { prisma } from '../../src/lib/prisma';

describe('GET /api/todos', () => {
  beforeEach(async () => {
    await prisma.todo.deleteMany();
  });

  it('빈 목록을 반환해야 한다', async () => {
    const response = await request(app)
      .get('/api/todos')
      .expect(200);

    expect(response.body).toEqual({ data: [] });
  });

  it('모든 할 일을 반환해야 한다', async () => {
    await prisma.todo.createMany({
      data: [
        { title: '할 일 1', completed: false },
        { title: '할 일 2', completed: true },
      ],
    });

    const response = await request(app)
      .get('/api/todos')
      .expect(200);

    expect(response.body.data).toHaveLength(2);
  });

  it('completed 필터가 동작해야 한다', async () => {
    await prisma.todo.createMany({
      data: [
        { title: '할 일 1', completed: false },
        { title: '할 일 2', completed: true },
      ],
    });

    const response = await request(app)
      .get('/api/todos?completed=true')
      .expect(200);

    expect(response.body.data).toHaveLength(1);
    expect(response.body.data[0].completed).toBe(true);
  });
});

describe('POST /api/todos', () => {
  it('새 할 일을 생성해야 한다', async () => {
    const response = await request(app)
      .post('/api/todos')
      .send({ title: '새 할 일' })
      .expect(201);

    expect(response.body.data).toMatchObject({
      title: '새 할 일',
      completed: false,
    });
    expect(response.body.data.id).toBeDefined();
  });

  it('빈 제목은 400 에러를 반환해야 한다', async () => {
    const response = await request(app)
      .post('/api/todos')
      .send({ title: '' })
      .expect(400);

    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('제목이 100자를 초과하면 400 에러를 반환해야 한다', async () => {
    const response = await request(app)
      .post('/api/todos')
      .send({ title: 'a'.repeat(101) })
      .expect(400);

    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });
});
```

### 단위 테스트 (서비스)
```typescript
// __tests__/unit/todo.service.test.ts
import { todoService } from '../../src/services/todo.service';
import { todoRepository } from '../../src/repositories/todo.repository';
import { NotFoundError } from '../../src/lib/errors';

jest.mock('../../src/repositories/todo.repository');

describe('TodoService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('findById', () => {
    it('존재하는 할 일을 반환해야 한다', async () => {
      const mockTodo = { id: '1', title: '테스트', completed: false };
      (todoRepository.findById as jest.Mock).mockResolvedValue(mockTodo);

      const result = await todoService.findById('1');

      expect(result).toEqual(mockTodo);
    });

    it('존재하지 않으면 NotFoundError를 던져야 한다', async () => {
      (todoRepository.findById as jest.Mock).mockResolvedValue(null);

      await expect(todoService.findById('999')).rejects.toThrow(NotFoundError);
    });
  });

  describe('create', () => {
    it('제목 앞뒤 공백을 제거해야 한다', async () => {
      const mockTodo = { id: '1', title: '할 일', completed: false };
      (todoRepository.create as jest.Mock).mockResolvedValue(mockTodo);

      await todoService.create({ title: '  할 일  ' });

      expect(todoRepository.create).toHaveBeenCalledWith({
        title: '할 일',
        completed: false,
      });
    });
  });
});
```

## 명령어 (서버)
```bash
# 개발 서버 (핫 리로드)
pnpm dev

# 빌드
pnpm build

# 프로덕션 실행
pnpm start

# 테스트
pnpm test
pnpm test:watch
pnpm test:coverage

# Prisma
pnpm prisma:generate    # 클라이언트 생성
pnpm prisma:migrate     # 마이그레이션 실행
pnpm prisma:studio      # DB GUI 실행
pnpm prisma:seed        # 시드 데이터 삽입
```

## 환경 변수
```env
# .env
DATABASE_URL="postgresql://user:password@localhost:5432/todo_dev"
PORT=4000
NODE_ENV=development
LOG_LEVEL=debug
```

| 변수 | 필수 | 기본값 | 설명 |
|------|------|--------|------|
| `DATABASE_URL` | Y | - | PostgreSQL 연결 문자열 |
| `PORT` | N | 4000 | 서버 포트 |
| `NODE_ENV` | N | development | 환경 |
| `LOG_LEVEL` | N | info | 로그 레벨 |

## 주의사항

1. **Prisma 클라이언트 동기화**
    - 스키마 변경 후 반드시 `pnpm prisma:generate` 실행
    - 마이그레이션 파일은 커밋 대상

2. **트랜잭션**
    - 여러 쓰기 작업 시 `prisma.$transaction()` 사용
    - 서비스 레이어에서 트랜잭션 관리

3. **로깅**
    - `console.log` 대신 `logger` 사용
    - 민감 정보 로깅 금지 (비밀번호, 토큰 등)

4. **에러 처리**
    - 컨트롤러에서 try-catch로 감싸고 next(error) 호출
    - 비즈니스 에러는 커스텀 에러 클래스 사용