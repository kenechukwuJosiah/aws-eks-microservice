import { Injectable } from '@nestjs/common';

@Injectable()
export class UsersService {
  ping(): { message: string; time: string } {
    return {
      message: 'Pong from Users Service!',
      time: new Date().toISOString(),
    };
  }
}
