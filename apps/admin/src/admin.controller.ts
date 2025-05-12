import {
  Body,
  Controller,
  Get,
  Post,
  UseGuards,
  Request,
} from '@nestjs/common';
import { AdminService } from './admin.service';
import { AuthGuard } from '@app/authguard';
import { CreateAdminDto } from './dto';

@Controller()
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get()
  getHello(): string {
    return this.adminService.getHello();
  }

  @Get('admin')
  @UseGuards(AuthGuard)
  listAdmins() {
    return this.adminService.listAdmins();
  }

  @Post('admin')
  @UseGuards(AuthGuard)
  createAdmin(@Body() adminData: CreateAdminDto, @Request() req) {
    const createdById = req.user._id;
    return this.adminService.createAdmin(adminData, createdById);
  }
}
