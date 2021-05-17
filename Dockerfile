FROM node:12-alpine
COPY . /APP

WORKDIR /APP

RUN npm install \
    && npm test \
    && npm run test:e2e