import { Injectable } from '@nestjs/common';
import { User } from '../generated/prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  findByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { email } });
  }

  create(data: {
    name: string;
    email: string;
    password: string;
  }): Promise<User> {
    return this.prisma.user.create({ data });
  }
}
