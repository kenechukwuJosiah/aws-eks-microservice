import { NestFactory } from '@nestjs/core';
import { UsersModule } from './users.module';

async function bootstrap() {
  const app = await NestFactory.create(UsersModule);
  app.setGlobalPrefix('api');
  await app.listen(process.env.AUTH_PORT ?? 24002);
}
bootstrap();
