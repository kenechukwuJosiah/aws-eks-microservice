import { User } from '@app/database';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateAdminDto } from './dto';
import { ObjectId } from 'mongodb';

@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(User)
    private readonly adminRepository: Repository<User>,
  ) {}

  async createAdmin(
    createAdminDto: CreateAdminDto,
    createdById: string,
  ): Promise<User> {
    const creator = await this.adminRepository.findOne({
      where: { _id: createdById as unknown as ObjectId },
    });

    if (!creator) {
      throw new Error('Creator not found');
    }
    if (creator.role !== 'admin') {
      throw new Error('Only admins can create new admins');
    }
    const admin = this.adminRepository.create({
      ...createAdminDto,
      role: 'admin',
    });
    return await this.adminRepository.save(admin);
  }

  async listAdmins(): Promise<User[]> {
    return await this.adminRepository.find();
  }

  ping(): { message: string; time: string } {
    return {
      message: 'Pong from Admin Service!',
      time: new Date().toISOString(),
    };
  }
}
