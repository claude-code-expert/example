# Server Code Patterns
- CLAUDE-template(Server).md 에서 참조하는 파일 (.claude/rules/ 하위에 위치)
## Route
```typescript
// routes/todos.ts
import { Router } from 'express'
import { todoController } from '../controllers/todo.controller'
import { validate } from '../middleware/validate'
import { createTodoSchema, updateTodoSchema } from '@todo-app/shared'

const router = Router()

router.get('/', todoController.getAll)
router.post('/', validate(createTodoSchema), todoController.create)
router.get('/:id', todoController.getById)
router.patch('/:id', validate(updateTodoSchema), todoController.update)
router.delete('/:id', todoController.delete)

export default router
```

## Controller
```typescript
export const todoController = {
  async getAll(req: Request, res: Response, next: NextFunction) {
    try {
      const todos = await todoService.findAll()
      res.json({ data: todos })
    } catch (error) {
      next(error)
    }
  },

  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const todo = await todoService.create(req.body)
      res.status(201).json({ data: todo })
    } catch (error) {
      next(error)
    }
  },
}
```

## Service
```typescript
export const todoService = {
  async findById(id: string): Promise<Todo> {
    const todo = await todoRepository.findById(id)
    if (!todo) throw new NotFoundError(`Todo ${id} not found`)
    return todo
  },

  async create(input: CreateTodoInput): Promise<Todo> {
    return todoRepository.create({
      title: input.title.trim(),
      completed: false,
    })
  },
}
```

## Repository
```typescript
export const todoRepository = {
  async findMany(filter?: { completed?: boolean }): Promise<Todo[]> {
    return prisma.todo.findMany({
      where: filter,
      orderBy: { createdAt: 'desc' },
    })
  },

  async findById(id: string): Promise<Todo | null> {
    return prisma.todo.findUnique({ where: { id } })
  },

  async create(data: { title: string; completed: boolean }): Promise<Todo> {
    return prisma.todo.create({ data })
  },

  async update(id: string, data: Partial<{ title: string; completed: boolean }>): Promise<Todo> {
    return prisma.todo.update({ where: { id }, data })
  },

  async delete(id: string): Promise<void> {
    await prisma.todo.delete({ where: { id } })
  },
}
```

## Custom Errors
```typescript
// lib/errors.ts
export class AppError extends Error {
  constructor(
    public code: string,
    message: string,
    public statusCode = 500
  ) {
    super(message)
    this.name = 'AppError'
  }
}

export class NotFoundError extends AppError {
  constructor(message: string) { super('NOT_FOUND', message, 404) }
}

export class ValidationError extends AppError {
  constructor(message: string, public details?: Record<string, unknown>) {
    super('VALIDATION_ERROR', message, 400)
  }
}
```

## Error Handler Middleware
```typescript
// middleware/errorHandler.ts
export function errorHandler(error: Error, req: Request, res: Response, next: NextFunction) {
  logger.error('Error occurred:', error)

  if (error instanceof AppError) {
    return res.status(error.statusCode).json({
      error: {
        code: error.code,
        message: error.message,
        ...(error instanceof ValidationError && { details: error.details }),
      },
    })
  }

  res.status(500).json({ error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' } })
}
```

## Integration Test Pattern
```typescript
// __tests__/integration/todos.test.ts
describe('POST /api/todos', () => {
  beforeEach(async () => { await prisma.todo.deleteMany() })

  it('creates a todo', async () => {
    const res = await request(app).post('/api/todos').send({ title: 'New todo' }).expect(201)
    expect(res.body.data).toMatchObject({ title: 'New todo', completed: false })
  })

  it('rejects empty title with 400', async () => {
    const res = await request(app).post('/api/todos').send({ title: '' }).expect(400)
    expect(res.body.error.code).toBe('VALIDATION_ERROR')
  })
})
```

## Unit Test Pattern
```typescript
// __tests__/unit/todo.service.test.ts
jest.mock('../../src/repositories/todo.repository')

describe('todoService.findById', () => {
  it('throws NotFoundError when not found', async () => {
    ;(todoRepository.findById as jest.Mock).mockResolvedValue(null)
    await expect(todoService.findById('999')).rejects.toThrow(NotFoundError)
  })
})
```