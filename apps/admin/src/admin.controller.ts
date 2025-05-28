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

@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('ping')
  ping(): { message: string; time: string } {
    return this.adminService.ping();
  }

  @Get()
  @UseGuards(AuthGuard)
  listAdmins() {
    return this.adminService.listAdmins();
  }

  @Post()
  @UseGuards(AuthGuard)
  createAdmin(@Body() adminData: CreateAdminDto, @Request() req) {
    const createdById = req.user._id;
    return this.adminService.createAdmin(adminData, createdById);
  }
}
