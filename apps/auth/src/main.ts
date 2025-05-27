import { NestFactory } from '@nestjs/core';
import { AuthModule } from './auth.module';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AuthModule);
  const logger = new Logger();

  app.setGlobalPrefix('api');

  const PORT = process.env.AUTH_PORT ?? 24002;

  await app.listen(PORT);

  logger.log(`APP RUNNING ON PORT: ${PORT}`);
}
bootstrap();
