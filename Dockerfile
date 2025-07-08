FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

RUN mkdir /tmp/prototype && \
    cd /tmp/prototype && \
    npx govuk-prototype-kit create . --version local && \
    cd /tmp/prototype && \
    npm install

WORKDIR /tmp/prototype
CMD ["npm", "run", "dev"]

