import { BadRequestException, Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { User } from '@app/database';
import { ObjectId } from 'mongodb';
import { LoginDto, SignupDto } from '../dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly jwtService: JwtService,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async login(loginPayload: LoginDto): Promise<string> {
    const { username, password } = loginPayload;
    const user = await this.userRepository.findOne({ where: { username } });

    if (!user || user.password !== password) {
      throw new BadRequestException('Invalid password or username');
    }
    const payload = { username: user.username, id: user._id };
    return this.jwtService.sign(payload);
  }

  async signup(signupDto: SignupDto): Promise<string> {
    const { username, email, password } = signupDto;

    const existingUser = await this.userRepository.findOne({
      where: { username },
    });

    if (existingUser) {
      throw new BadRequestException('User already exists');
    }
    const newUser = this.userRepository.create({
      username,
      password,
      email,
      role: 'user',
    });
    await this.userRepository.save(newUser);
    return 'User signed up successfully.';
  }

  async getProfile(userId: string): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { _id: userId as unknown as ObjectId },
    });
    if (!user) {
      throw new BadRequestException('User not found');
    }
    return user;
  }

  ping(): { message: string; time: string } {
    return {
      message: 'Pong from Auth Service!',
      time: new Date().toISOString(),
    };
  }
}
