import { NestFactory } from '@nestjs/core';

import { Logger } from '@nestjs/common';
import { UsersModule } from './users.module';

async function bootstrap() {
  const app = await NestFactory.create(UsersModule);
  const logger = new Logger();

  app.setGlobalPrefix('api');

  const PORT = process.env.USER_PORT ?? 24001;

  await app.listen(PORT);

  logger.log(`APP RUNNING ON PORT: ${PORT}`);
}
bootstrap();
