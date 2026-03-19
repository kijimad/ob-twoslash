FROM node:24-alpine
WORKDIR /app
COPY twoslash-runner/package.json twoslash-runner/package-lock.json ./
RUN npm ci --production
COPY twoslash-runner/index.mjs .
ENTRYPOINT ["node", "index.mjs"]
