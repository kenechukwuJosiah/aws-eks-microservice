import { Entity, ObjectIdColumn, Column, ObjectId } from 'typeorm';

@Entity('users')
export class User {
  @ObjectIdColumn()
  _id: ObjectId;

  @Column()
  username: string;

  @Column()
  email: string;

  @Column()
  password: string;

  @Column()
  role: 'user' | 'admin';

  @Column({ default: new Date() })
  createdAt: Date;
}
