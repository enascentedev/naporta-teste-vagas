import { ConfigModule } from '@nestjs/config';
import { Test, type TestingModule } from '@nestjs/testing';
import { Prisma } from '../../src/generated/prisma/client';
import { PrismaModule } from '../../src/prisma/prisma.module';
import { PrismaService } from '../../src/prisma/prisma.service';
import { UsersModule } from '../../src/users/users.module';
import { UsersService } from '../../src/users/users.service';
import { buildUserPayload } from '../factories/user.factory';
import { cleanTestDatabase } from '../helpers/test-database';

describe('UsersService com PostgreSQL', () => {
  let moduleRef: TestingModule;
  let prisma: PrismaService;
  let usersService: UsersService;

  beforeAll(async () => {
    moduleRef = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({ isGlobal: true }),
        PrismaModule,
        UsersModule,
      ],
    }).compile();
    await moduleRef.init();
    prisma = moduleRef.get(PrismaService);
    usersService = moduleRef.get(UsersService);
  });

  beforeEach(() => cleanTestDatabase(prisma));
  afterAll(() => moduleRef.close());

  it('cria e recupera um usuário pelo e-mail', async () => {
    const payload = buildUserPayload({ password: 'hash-de-teste' });

    const created = await usersService.create(payload);

    await expect(usersService.findByEmail(payload.email)).resolves.toEqual(
      created,
    );
  });

  it('preserva a constraint única de e-mail no banco', async () => {
    const payload = buildUserPayload({ password: 'hash-de-teste' });
    await usersService.create(payload);

    await expect(usersService.create(payload)).rejects.toMatchObject<
      Partial<Prisma.PrismaClientKnownRequestError>
    >({ code: 'P2002' });
  });
});
