# Docker와 배포
책에 다 실어내지 못한 내용중 Docker 관련 내용은 다음과 같습니다.


Part 2의 TODO 앱은 Vercel을 통해 간편하게 배포했다. 정적 사이트와 서버리스 함수로 구성된 간단한 구조에는 Vercel이 적합했다. 하지만 AI 챗봇은 사정이 다르다. Bedrock API 호출, SSE 스트리밍, 환경 변수 기반의 모델 전환 등 백엔드의 역할이 크고, 운영 환경에서의 리소스 관리가 중요하다. Docker + AWS ECS 조합을 선택한 이유는 컨테이너 기반 배포가 이런 요구사항에 더 적합하기 때문이다.

---

## 13.1 Docker 기초

### 13.1.1 컨테이너와 이미지

Docker는 애플리케이션을 컨테이너라는 격리된 환경에서 실행한다.

| 개념 | 설명 | 비유 |
|------|------|------|
| 이미지 | 컨테이너를 만들기 위한 템플릿 | 설계도 |
| 컨테이너 | 이미지를 실행한 인스턴스 | 설계도로 만든 건물 |
| Dockerfile | 이미지를 만드는 스크립트 | 설계 지침서 |
| 레지스트리 | 이미지를 저장하는 저장소 | 설계도 보관소 |

이미지는 읽기 전용이다. 하나의 이미지에서 여러 컨테이너를 생성할 수 있다. 컨테이너 내부에서 파일을 수정해도 이미지는 변경되지 않는다.

```
[이미지]
   |
   +---> [컨테이너 1] (실행 중)
   |
   +---> [컨테이너 2] (실행 중)
   |
   +---> [컨테이너 3] (중지됨)
```

### 13.1.2 Docker를 사용하는 이유

Docker를 사용하면 다음 문제들을 해결할 수 있다.

**"내 컴퓨터에서는 되는데요" 문제:** Docker 컨테이너는 OS, 라이브러리 버전, 환경 설정을 모두 포함하므로 어디서든 동일하게 동작한다.

**환경 구성의 복잡성:** Node.js 버전, npm 패키지, 시스템 라이브러리 등을 일일이 설치할 필요 없이 `docker run` 한 번으로 실행할 수 있다.

**격리와 보안:** 각 서비스가 독립된 컨테이너에서 실행되어 서로 영향을 주지 않는다. 하나의 컨테이너가 문제가 생겨도 다른 서비스는 정상 동작한다.

**확장성:** 트래픽이 증가하면 동일한 컨테이너를 여러 개 실행해 부하를 분산할 수 있다.

### 13.1.3 Docker 설치

운영체제별 Docker 설치 방법이다.

**macOS:**

```bash
# Homebrew로 설치
brew install --cask docker

# Docker Desktop 실행 후 확인
docker --version
docker compose version
```

**Linux (Ubuntu):**

```bash
# 필수 패키지 설치
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg

# Docker GPG 키 추가
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 저장소 추가
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker 설치
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

# 현재 사용자를 docker 그룹에 추가 (sudo 없이 실행 가능)
sudo usermod -aG docker $USER
newgrp docker
```

**Windows:** Docker Desktop for Windows를 설치한다. WSL2 백엔드를 권장한다.

**설치 확인:**

```bash
$ docker --version
Docker version 29.2.1, build a5c7197

$ docker compose version
Docker Compose version v5.0.2

$ docker run hello-world
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

---

## 13.2 백엔드 Docker 구성

Node.js 백엔드를 Docker 이미지로 만든다.

### 13.2.1 프로젝트 구조

Docker 관련 파일을 추가한 프로젝트 구조다.

```
ai-chatbot/
├── backend/
│   ├── src/
│   ├── tests/
│   ├── package.json
│   ├── tsconfig.json
│   ├── Dockerfile            # 프로덕션용
│   ├── Dockerfile.dev        # 개발용
│   └── .dockerignore
├── frontend/
│   ├── src/
│   ├── Dockerfile            # 프로덕션용
│   ├── Dockerfile.dev        # 개발용
│   ├── nginx.conf
│   └── .dockerignore
├── docker-compose.yml        # 프로덕션 기본
├── docker-compose.dev.yml    # 개발 환경 오버라이드
└── .env.example
```

프로덕션용 `Dockerfile`과 개발용 `Dockerfile.dev`를 분리한다. 프로덕션은 멀티스테이지 빌드로 이미지 크기를 최소화하고, 개발은 볼륨 마운트와 핫 리로드에 초점을 맞춘다.

### 13.2.2 .dockerignore 작성

Docker 빌드 시 제외할 파일을 지정한다. `.gitignore`와 비슷한 역할이다.

```dockerfile
# backend/.dockerignore

node_modules
npm-debug.log
dist
coverage
.env
.env.local
.git
.gitignore
README.md
*.md
tests
__tests__
*.test.ts
*.spec.ts
.nyc_output
```

`node_modules`를 제외하는 이유는 호스트 OS와 컨테이너 OS가 다르면 네이티브 모듈이 호환되지 않을 수 있고, 빌드 컨텍스트 크기를 줄여 빌드 속도를 향상시키기 위해서다. 의존성은 컨테이너 내에서 `npm ci`로 새로 설치한다.

### 13.2.3 Dockerfile 작성 (멀티스테이지 빌드)

프로덕션용 Dockerfile은 멀티스테이지 빌드를 사용한다. 빌드에 필요한 도구(TypeScript, devDependencies)는 빌드 스테이지에서만 사용하고, 실행 스테이지에는 빌드 결과물과 프로덕션 의존성만 포함한다.

```dockerfile
# backend/Dockerfile

# === 빌드 스테이지 ===
FROM node:20-alpine AS builder

WORKDIR /app

# 패키지 파일 복사 (캐시 최적화)
COPY package*.json ./
RUN npm ci

# 소스 복사 및 빌드
COPY . .
RUN npm run build

# === 실행 스테이지 ===
FROM node:20-alpine AS runner

WORKDIR /app

# 프로덕션 의존성만 설치
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# 빌드 결과물만 복사
COPY --from=builder /app/dist ./dist

# 보안: non-root 사용자
USER node

EXPOSE 3000

CMD ["node", "dist/index.js"]
```

각 명령어의 역할:

| 명령어 | 설명 |
|--------|------|
| `FROM node:20-alpine AS builder` | Node.js 20 기반 Alpine Linux로 빌드 환경 구성 |
| `COPY package*.json ./` | package.json과 lock 파일을 먼저 복사 (캐시 최적화) |
| `RUN npm ci` | lock 파일 기준 정확한 버전 설치 |
| `COPY . .` | 나머지 소스 코드 복사 |
| `RUN npm run build` | TypeScript 컴파일 |
| `FROM node:20-alpine AS runner` | 실행용 경량 이미지 시작 |
| `npm ci --omit=dev` | devDependencies 제외하고 설치 |
| `COPY --from=builder /app/dist` | 빌드 스테이지의 결과물만 복사 |
| `USER node` | root가 아닌 node 사용자로 실행 (보안) |

**캐시 최적화:** `package*.json`을 먼저 복사하고 `npm ci`를 실행한다. 소스 코드가 변경되어도 `package.json`이 변경되지 않으면 `npm ci` 레이어를 캐시에서 재사용한다.

**멀티스테이지 빌드 효과:** 단일 스테이지에서는 TypeScript 컴파일러와 빌드 도구가 포함되어 이미지가 약 500MB에 달하지만, 멀티스테이지로 분리하면 약 150MB로 줄일 수 있다. 이미지가 작을수록 배포 속도가 빠르고 보안 취약점도 줄어든다.

### 13.2.4 개발용 Dockerfile

개발 환경에서는 멀티스테이지 빌드 없이 `npm run dev`로 개발 서버를 실행한다.

```dockerfile
# backend/Dockerfile.dev

FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]
```

### 13.2.5 환경 변수 관리

민감한 정보는 Dockerfile에 하드코딩하지 않는다.

```dockerfile
# ❌ 잘못된 예 — 절대 하지 말 것
ENV AWS_ACCESS_KEY_ID=AKIA...
ENV AWS_SECRET_ACCESS_KEY=...

# ✅ 올바른 예 — 런타임에 주입
# docker run -e AWS_ACCESS_KEY_ID=...
# 또는 docker-compose에서 env_file 사용
```

### 13.2.6 이미지 빌드 및 테스트

```bash
# 백엔드 디렉터리에서 이미지 빌드
cd backend
docker build -t ai-chatbot-backend:latest .

# 빌드된 이미지 확인
docker images | grep ai-chatbot-backend

# 컨테이너 실행 테스트
docker run --rm -p 3000:3000 --env-file .env ai-chatbot-backend:latest

# 다른 터미널에서 API 테스트
curl http://localhost:3000/api/health
```

---

## 13.3 프런트엔드 Docker 구성

React 프런트엔드를 Nginx로 서빙하는 Docker 이미지를 만든다.

### 13.3.1 Nginx를 쓰는 이유

React는 빌드하면 정적 파일(HTML, CSS, JS)이 생성된다. 이 파일을 브라우저에 전달하려면 웹 서버가 필요하고, 동시에 API 요청을 백엔드로 전달하는 리버스 프록시 역할도 해야 한다. Nginx는 이 두 가지를 모두 처리한다.

| 역할 | 설명 |
|------|------|
| 정적 파일 서빙 | HTML, CSS, JS, 이미지를 효율적으로 전송 |
| 리버스 프록시 | `/api/*` 요청을 백엔드 컨테이너로 전달 |
| gzip 압축 | 전송 크기를 60~80% 감소 |
| 캐싱 | 빌드 해시가 포함된 정적 파일에 장기 캐시 설정 |
| SPA 라우팅 | React Router의 클라이언트 사이드 라우팅 지원 |

### 13.3.2 Nginx 설정

```nginx
# frontend/nginx.conf

server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # gzip 압축
    gzip on;
    gzip_types text/plain text/css application/json
               application/javascript text/xml application/xml;
    gzip_min_length 1000;

    # 정적 파일 캐싱
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # API 요청 프록시
    location /api/ {
        proxy_pass http://backend:3000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_cache_bypass $http_upgrade;

        # SSE(Server-Sent Events)를 위한 설정
        proxy_buffering off;
        proxy_read_timeout 86400s;
    }

    # SPA 라우팅 — 모든 경로를 index.html로
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 보안 헤더
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

`proxy_pass http://backend:3000`에서 `backend`는 Docker Compose의 서비스 이름이다. Docker 내부 DNS가 이를 해당 컨테이너의 IP로 해석한다. `proxy_buffering off`는 AI 챗봇의 SSE 스트리밍 응답을 위해 필수적인 설정이다.

### 13.3.3 Dockerfile 작성

```dockerfile
# frontend/Dockerfile

# === 빌드 스테이지 ===
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# === 실행 스테이지 ===
FROM nginx:alpine AS runner

# Nginx 설정 복사
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 빌드 결과물 복사
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

Vite 빌드 결과물은 `dist` 폴더에 생성된다. 정적 파일만 Nginx 이미지에 복사하므로 최종 이미지 크기는 약 30MB 정도다.

### 13.3.4 개발용 Dockerfile과 .dockerignore

```dockerfile
# frontend/Dockerfile.dev

FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 5173

CMD ["npm", "run", "dev"]
```

```dockerfile
# frontend/.dockerignore

node_modules
dist
coverage
.git
.gitignore
*.md
tests
__tests__
*.test.ts
*.test.tsx
*.spec.ts
*.spec.tsx
.env
.env.local
```

---

## 13.4 Docker Compose

백엔드와 프런트엔드를 함께 실행하는 Docker Compose 설정이다.

**[그림 13-1] Docker Compose 구성도**

브라우저에서 `localhost:80`으로 프런트엔드에 접속하면, Nginx가 `/api/*` 요청을 백엔드 컨테이너의 `:3000` 포트로 프록시한다. 백엔드는 Docker 네트워크 외부의 AWS Bedrock API를 호출한다.

### 13.4.1 프로덕션 Compose 정의

```yaml
# docker-compose.yml

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: ai-chatbot-backend
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
    env_file:
      - .env
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1",
             "--spider", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
    restart: unless-stopped

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: ai-chatbot-frontend
    ports:
      - "80:80"
    depends_on:
      backend:
        condition: service_healthy
    restart: unless-stopped

networks:
  default:
    name: ai-chatbot-network
```

주요 설정:

| 옵션 | 설명 |
|------|------|
| `build.context` | Dockerfile이 있는 디렉터리 |
| `container_name` | 컨테이너 이름 (없으면 자동 생성) |
| `ports` | 호스트:컨테이너 포트 매핑 |
| `env_file` | 환경 변수 파일 |
| `healthcheck` | 컨테이너 상태 확인 |
| `depends_on` | 의존 서비스와 시작 조건 |
| `restart` | 재시작 정책 |

### 13.4.2 헬스체크

Chapter 10에서 `routes/index.ts`에 헬스체크 엔드포인트를 이미 구현했다.

```typescript
// backend/src/routes/index.ts (발췌)
router.get("/health", (req, res) => {
  res.json({ status: "ok" });
});
```

`app.ts`에서 `app.use('/api', routes)`로 라우터를 마운트하므로 헬스체크 URL은 `/api/health`가 된다. `depends_on`에 `condition: service_healthy`를 설정했으므로, 백엔드가 정상 상태가 된 후에 프런트엔드가 시작된다.

### 13.4.3 개발 환경 Compose

개발 환경에서는 소스 코드 변경을 즉시 반영하기 위해 볼륨 마운트를 사용한다.

```yaml
# docker-compose.dev.yml

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    volumes:
      - ./backend/src:/app/src
      - ./backend/package.json:/app/package.json
      - /app/node_modules          # 컨테이너 내부 것 사용
    environment:
      - NODE_ENV=development
    env_file:
      - .env.development

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    ports:
      - "5173:5173"
    volumes:
      - ./frontend/src:/app/src
      - ./frontend/package.json:/app/package.json
      - /app/node_modules
    environment:
      - NODE_ENV=development
```

볼륨 마운트에서 `/app/node_modules`를 별도로 선언하는 이유는, 호스트의 `node_modules`가 컨테이너 내부로 덮어쓰이는 것을 방지하기 위해서다. 컨테이너 내부에서 `npm install`로 설치한 의존성을 그대로 사용한다.

---

## 13.5 환경별 설정

개발, 스테이징, 운영 환경을 분리한다.

### 13.5.1 환경 변수 파일

`.env.example`을 템플릿으로 만들고, 이를 복사해서 각 환경 파일을 작성한다.

```bash
# .env.example (템플릿)

# AWS Bedrock
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=

# Server
NODE_ENV=production
PORT=3000

# Bedrock Model
BEDROCK_MODEL_ID=anthropic.claude-sonnet-4-5-20250929-v1:0
```

환경별로 달라지는 핵심 값:

| 환경 | 모델 | LOG_LEVEL | 이유 |
|------|------|-----------|------|
| 개발 | Claude Haiku 4.5 | debug | 빠른 응답, 낮은 비용 |
| 스테이징 | Claude Sonnet 4.5 | info | 운영과 동일한 모델로 테스트 |
| 운영 | Claude Sonnet 4.5 | warn | 품질과 비용의 균형 |

```bash
# .env.development
NODE_ENV=development
LOG_LEVEL=debug
BEDROCK_MODEL_ID=anthropic.claude-haiku-4-5-20251001-v1:0

# .env.production
NODE_ENV=production
LOG_LEVEL=warn
BEDROCK_MODEL_ID=anthropic.claude-sonnet-4-5-20250929-v1:0
```

### 13.5.2 환경별 실행

```bash
# 개발 환경
docker compose -f docker-compose.dev.yml up

# 운영 환경
docker compose -f docker-compose.yml up -d
```

운영 환경에서는 리소스 제한을 추가한다. 특정 컨테이너가 호스트 리소스를 독점하는 것을 방지하고, 메모리 누수가 발생해도 지정한 한도에서 컨테이너가 종료되므로 서버 전체가 다운되는 것을 막을 수 있다. 또한 ECS Fargate는 Task 정의 시 CPU/Memory를 반드시 지정해야 하므로 Compose에서 미리 설계해두면 배포 설정과 일관성을 유지할 수 있다.

```yaml
# docker-compose.yml의 운영 환경 리소스 제한 (추가)
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: "1"
          memory: 512M

  frontend:
    deploy:
      resources:
        limits:
          cpus: "0.5"
          memory: 256M
```

### 13.5.3 AWS 자격 증명 관리

이 책에서는 모든 환경에서 `AWS_ACCESS_KEY_ID`와 `AWS_SECRET_ACCESS_KEY` 환경 변수를 사용한다. `.env` 파일에 자격 증명을 저장하고, 이 파일은 절대 Git에 커밋하지 않는다.

```gitignore
# .gitignore
.env
.env.local
.env.development.local
.env.production.local
```

> **운영 환경 참고:** 실제 서비스 운영 시에는 환경 변수에 자격 증명을 직접 넣는 대신 IAM Role을 사용하는 것이 권장된다. ECS Task에 IAM Role을 할당하면 자격 증명 없이도 AWS 서비스에 접근할 수 있어 노출 위험이 없다. 자세한 내용은 AWS 공식 문서의 "ECS Task IAM Role" 항목을 참고한다.

---

## 13.6 배포 전략

컨테이너화된 애플리케이션을 운영 환경에 배포한다.

### 13.6.1 배포 옵션 비교

| 옵션 | 장점 | 단점 | 적합한 상황 |
|------|------|------|-------------|
| AWS ECS Fargate | 서버 관리 불필요, 자동 확장 | 비용이 다소 높음 | 프로덕션, 트래픽 변동 |
| AWS EC2 + Docker | 비용 예측 가능, 완전한 제어 | 서버 관리 필요 | 안정적인 트래픽 |
| AWS App Runner | 가장 간단한 설정 | 커스터마이징 제한 | 빠른 프로토타입 |
| 자체 서버 | 낮은 비용 | 모든 관리 직접 | 소규모, 학습용 |

이 프로젝트에서는 AWS ECS Fargate를 사용한다. 서버 인스턴스를 직접 관리할 필요 없이 컨테이너 단위로 배포할 수 있고, 트래픽에 따라 자동으로 확장/축소되기 때문이다.

**[그림 13-2] ECS Fargate 배포 아키텍처**

사용자 요청은 ALB(Application Load Balancer)를 통해 ECS Cluster의 Fargate Task로 전달된다. 하나의 Task 안에 frontend, backend 두 컨테이너가 함께 실행되며, ECR에서 Docker 이미지를 가져오고, CloudWatch로 로그와 메트릭을 전송한다.

### 13.6.2 ECR에 이미지 푸시

AWS ECR(Elastic Container Registry)에 Docker 이미지를 업로드한다. ECR은 AWS 계정 내에서 프라이빗하게 관리하는 컨테이너 이미지 저장소다.

> 아래 명령어는 Chapter 9.1에서 설치한 AWS CLI와 `aws configure`로 설정한 자격 증명이 필요하다.

```bash
# 환경 변수 설정
AWS_ACCOUNT_ID=123456789012
AWS_REGION=us-east-1

# 1. ECR 리포지토리 생성 (한 번만)
aws ecr create-repository --repository-name ai-chatbot-backend
aws ecr create-repository --repository-name ai-chatbot-frontend

# 2. ECR 로그인
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS \
  --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# 3. 이미지 태그
docker tag ai-chatbot-backend:latest \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ai-chatbot-backend:latest
docker tag ai-chatbot-frontend:latest \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ai-chatbot-frontend:latest

# 4. 이미지 푸시
docker push \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ai-chatbot-backend:latest
docker push \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ai-chatbot-frontend:latest
```

### 13.6.3 ECS 태스크 정의

ECS에서 컨테이너를 실행하려면 태스크 정의(Task Definition)가 필요하다. Docker Compose의 `docker-compose.yml`에 해당하는 AWS 버전이라고 이해하면 된다.

```json
{
  "family": "ai-chatbot",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/ai-chatbot-task-role",
  "containerDefinitions": [
    {
      "name": "backend",
      "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/ai-chatbot-backend:latest",
      "portMappings": [
        { "containerPort": 3000, "protocol": "tcp" }
      ],
      "environment": [
        { "name": "NODE_ENV", "value": "production" },
        { "name": "AWS_REGION", "value": "us-east-1" }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/ai-chatbot",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "backend"
        }
      },
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      }
    },
    {
      "name": "frontend",
      "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/ai-chatbot-frontend:latest",
      "portMappings": [
        { "containerPort": 80, "protocol": "tcp" }
      ],
      "dependsOn": [
        { "containerName": "backend", "condition": "HEALTHY" }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/ai-chatbot",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "frontend"
        }
      }
    }
  ]
}
```

주요 설정:
- `cpu`와 `memory`: Fargate Task 전체에 할당할 리소스. 512 CPU 단위(0.5 vCPU)와 1024MB 메모리를 지정했다.
- `executionRoleArn`: ECS가 ECR에서 이미지를 가져오고 CloudWatch에 로그를 보내는 데 필요한 IAM 역할이다.
- `logConfiguration`: 컨테이너 로그를 CloudWatch로 전송하는 설정이다. 13.7절에서 이 로그를 확인한다.
- `dependsOn`: frontend 컨테이너가 backend의 헬스체크가 통과한 후에 시작되도록 순서를 지정한다.

### 13.6.4 배포 스크립트

ECR 로그인부터 이미지 빌드, 푸시, ECS 서비스 업데이트까지의 과정을 하나의 스크립트로 자동화한다.

```bash
#!/bin/bash
# scripts/deploy.sh

set -e

# 설정
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-123456789012}
AWS_REGION=${AWS_REGION:-us-east-1}
IMAGE_TAG=${IMAGE_TAG:-latest}
ECS_CLUSTER=${ECS_CLUSTER:-ai-chatbot-cluster}
ECS_SERVICE=${ECS_SERVICE:-ai-chatbot-service}

echo "=== AI Chatbot 배포 시작 ==="

# 1. ECR 로그인
echo "1. ECR 로그인..."
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS \
  --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# 2. 이미지 빌드
echo "2. Docker 이미지 빌드..."
docker compose build

# 3. 이미지 태그 및 푸시
echo "3. 이미지 푸시..."
for SERVICE in backend frontend; do
  docker tag ai-chatbot-$SERVICE:latest \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ai-chatbot-$SERVICE:$IMAGE_TAG
  docker push \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/ai-chatbot-$SERVICE:$IMAGE_TAG
done

# 4. ECS 서비스 업데이트
echo "4. ECS 서비스 업데이트..."
aws ecs update-service \
  --cluster $ECS_CLUSTER \
  --service $ECS_SERVICE \
  --force-new-deployment

# 5. 배포 완료 대기
echo "5. 배포 완료 대기..."
aws ecs wait services-stable \
  --cluster $ECS_CLUSTER \
  --services $ECS_SERVICE

echo "=== 배포 완료 ==="
```

```bash
# 실행 권한 부여 및 실행
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

---

## 13.7 운영 시 고려사항

배포까지 완료했다면, 운영 단계에서 신경 써야 할 두 가지가 있다. 로그 관리와 비용 관리다.

### 13.7.1 로깅

ECS Fargate는 컨테이너의 표준 출력(`console.log`, `console.error`)을 CloudWatch Logs로 자동 전송한다. 13.6.3의 태스크 정의에서 `awslogs` 로그 드라이버를 이미 설정했으므로, AWS 콘솔의 CloudWatch > 로그 그룹에서 `/ecs/ai-chatbot` 로그를 확인할 수 있다.

운영 환경에서는 로그를 JSON 형식으로 출력하는 것이 좋다. 일반 텍스트 로그는 사람이 읽기엔 편하지만, CloudWatch Logs Insights에서 필드 단위로 검색하려면 구조화된 형식이 필요하다.

```typescript
// 일반 텍스트 로그 (검색 어려움)
console.log("Chat request received - session: abc123, length: 150");

// JSON 구조화 로그 (필드 단위 검색 가능)
console.log(JSON.stringify({
  timestamp: new Date().toISOString(),
  level: "info",
  message: "Chat request received",
  sessionId: "abc123",
  messageLength: 150
}));
```

> 로그 보존 기간을 설정하지 않으면 무한히 쌓여 비용이 증가하므로 반드시 설정한다. CloudWatch Logs의 보존 기간 설정, Logs Insights 쿼리 문법은 AWS 공식 문서의 "Amazon CloudWatch Logs User Guide"를 참고한다.

### 13.7.2 비용 관리

AI 서비스는 사용량에 따라 비용이 발생한다. Bedrock의 Claude 모델은 입력/출력 토큰 수에 비례해 과금된다(모델별 가격은 Chapter 8.1의 비용 비교 표를 참고한다). 개발 환경에서 Haiku를 사용하고 운영에서만 Sonnet을 사용하는 것이 13.5.1에서 환경별 모델을 분리한 이유다.

예상치 못한 비용 폭증을 방지하려면 다음 두 가지를 설정한다.

**AWS Budgets:** AWS 콘솔 > Billing > Budgets에서 월간 예산과 알림 임계치를 설정한다. 예를 들어 월 $100 예산에 80% 도달 시 이메일 알림을 받도록 설정하면, 비용이 $80을 초과할 때 알림을 받을 수 있다.

**Bedrock 모델 호출 제한:** Bedrock 서비스 할당량(Service Quotas)에서 분당 요청 수 상한을 설정할 수 있다. AWS 콘솔 > Service Quotas > Amazon Bedrock에서 조정한다.

> CloudWatch Alarms를 활용한 세부 메트릭 모니터링(CPU, 메모리, 에러율)과 SNS 알림 연동은 AWS 공식 문서의 "Amazon CloudWatch Alarms"를 참고한다.
