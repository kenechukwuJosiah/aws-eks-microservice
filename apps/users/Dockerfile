FROM node:22-alpine

WORKDIR /app

COPY . .

RUN npm install

RUN npm run build admin

CMD ["node", "dist/main"]
