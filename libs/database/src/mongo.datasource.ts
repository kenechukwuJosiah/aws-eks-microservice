import { DataSource } from 'typeorm';
import { User } from '../entities';

export const MongoDataSource = new DataSource({
  type: 'mongodb',
  host: process.env.MONGODB_HOST,
  port: parseInt(process.env.MONGODB_PORT) as number,
  database: process.env.MONGODB_DATABASE,
  entities: [User],
});
