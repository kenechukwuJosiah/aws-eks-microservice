import { NestFactory } from '@nestjs/core';
import { AdminModule } from './admin.module';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AdminModule);

  app.setGlobalPrefix('api');

  const logger = new Logger();

  const PORT = process.env.ADMIN_PORT ?? 24000;

  await app.listen(PORT);

  logger.log(`APP RUNNING ON PORT: ${PORT}`);
}
bootstrap();
