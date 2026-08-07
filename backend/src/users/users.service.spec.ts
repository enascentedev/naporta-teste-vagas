import type { PrismaService } from '../prisma/prisma.service';
import { UsersService } from './users.service';

describe('UsersService', () => {
  const prisma = {
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
    },
  };
  const service = new UsersService(prisma as unknown as PrismaService);

  beforeEach(() => jest.clearAllMocks());

  it('busca usuário por e-mail', async () => {
    prisma.user.findUnique.mockResolvedValue({ id: 'user-id' });

    await expect(service.findByEmail('user@example.com')).resolves.toEqual({
      id: 'user-id',
    });
    expect(prisma.user.findUnique).toHaveBeenCalledWith({
      where: { email: 'user@example.com' },
    });
  });

  it('delega a criação ao Prisma', async () => {
    const data = {
      name: 'Usuário',
      email: 'user@example.com',
      password: 'hash',
    };
    prisma.user.create.mockResolvedValue({ id: 'user-id', ...data });

    await expect(service.create(data)).resolves.toEqual({
      id: 'user-id',
      ...data,
    });
    expect(prisma.user.create).toHaveBeenCalledWith({ data });
  });
});
