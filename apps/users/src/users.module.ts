import { Module } from '@nestjs/common';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { prometheusModule } from '@app/prometheus';

@Module({
  imports: [prometheusModule],
  controllers: [UsersController],
  providers: [UsersService],
})
export class UsersModule {}
