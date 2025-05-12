import { Module } from '@nestjs/common';
import { DatabaseService } from './database.service';
import { MongoDataSource } from './mongo.datasource';

@Module({
  providers: [DatabaseService],
  exports: [DatabaseService],
})
export class DatabaseModule {
  async onModuleInit() {
    await MongoDataSource.initialize();
  }
}
