# Node.js LTS + 기본 디렉토리 설정
FROM node:18-alpine

# 디렉토리 생성 및 작업 디렉토리 설정
WORKDIR /app

# govuk 프로토타입 생성
RUN npx govuk-prototype-kit create . --version local && npm install

# 3000 포트 노출
EXPOSE 3000

# 고정 실행
CMD ["npm", "run", "dev"]
