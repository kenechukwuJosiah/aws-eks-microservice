import { User } from '@app/database';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateAdminDto } from './dto';

@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(User)
    private readonly adminRepository: Repository<User>,
  ) {}

  async createAdmin(createAdminDto: CreateAdminDto): Promise<User> {
    const admin = this.adminRepository.create({
      ...createAdminDto,
      role: 'admin',
    });
    return await this.adminRepository.save(admin);
  }

  async listAdmins(): Promise<User[]> {
    return await this.adminRepository.find();
  }

  getHello(): string {
    return 'Hello World!';
  }
}
