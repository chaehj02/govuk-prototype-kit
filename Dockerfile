# Node.js LTS (작고 빠른 alpine 이미지 사용)
FROM node:18-alpine

# 작업 디렉토리
WORKDIR /app

# package.json과 lock 파일 복사
COPY package*.json ./

# 의존성 설치 (CI 환경에 최적화된 방식)
RUN npm ci

# 전체 앱 복사
COPY . .

# 앱이 3000번 포트에서 동작함
EXPOSE 3000

# 앱 실행 명령
CMD ["npm", "run", "dev"]
