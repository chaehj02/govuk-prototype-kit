FROM node:18-alpine

WORKDIR /app

# File watch limit 증가
RUN echo fs.inotify.max_user_watches=524288 >> /etc/sysctl.conf && \
    echo fs.inotify.max_user_instances=512 >> /etc/sysctl.conf

RUN npx govuk-prototype-kit create . --version local && npm install

EXPOSE 3000

CMD ["npm", "run", "dev"]
