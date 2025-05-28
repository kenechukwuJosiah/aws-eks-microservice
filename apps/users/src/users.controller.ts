import { Controller, Get } from '@nestjs/common';
import { UsersService } from './users.service';

@Controller('user')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('ping')
  ping(): { message: string; time: string } {
    return this.usersService.ping();
  }
}
