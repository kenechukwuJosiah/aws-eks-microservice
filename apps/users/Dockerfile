FROM node:22-alpine

WORKDIR /app

EXPOSE 24001

COPY package*.json tsconfig.build.json ./

RUN npm i

COPY . .

RUN npm run build users

RUN npm prune --omit=dev
RUN rm -rf apps config
RUN rm -f package*.json tsconfig.build.json nest-cli.json

CMD ["node", "dist/apps/users/main"]
