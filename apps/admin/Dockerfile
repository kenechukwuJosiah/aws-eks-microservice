FROM node:22-alpine

WORKDIR /app

EXPOSE 24000

COPY package*.json tsconfig.build.json ./

RUN npm i

COPY . .

RUN npm run build admin

RUN npm prune --omit=dev
RUN rm -rf apps config
RUN rm -f package*.json tsconfig.build.json nest-cli.json

CMD ["node", "dist/apps/admin/main"]
