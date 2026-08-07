import type { INestApplication } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { randomUUID } from 'node:crypto';
import request from 'supertest';
import { PrismaService } from '../../src/prisma/prisma.service';
import { buildOrderPayload } from '../factories/order.factory';
import { buildUserPayload } from '../factories/user.factory';
import { authenticateTestUser } from '../helpers/e2e-auth';
import { createE2eApp, getHttpServer } from '../helpers/e2e-app';
import { cleanTestDatabase } from '../helpers/test-database';

describe('Segurança HTTP (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let jwtService: JwtService;

  beforeAll(async () => {
    app = await createE2eApp();
    prisma = app.get(PrismaService);
    jwtService = app.get(JwtService);
  });

  beforeEach(() => cleanTestDatabase(prisma));
  afterAll(() => app.close());

  it('mantém apenas registro e login explicitamente públicos', async () => {
    const user = buildUserPayload();
    await request(getHttpServer(app))
      .post('/api/auth/register')
      .send(user)
      .expect(201);
    await request(getHttpServer(app))
      .post('/api/auth/login')
      .send({ email: user.email, password: user.password })
      .expect(200);
    await request(getHttpServer(app)).get('/api/orders').expect(401);
  });

  it.each([
    ['post', '/api/orders'],
    ['get', '/api/orders'],
    ['get', `/api/orders/${randomUUID()}`],
    ['patch', `/api/orders/${randomUUID()}`],
    ['delete', `/api/orders/${randomUUID()}`],
  ] as const)('protege %s %s sem token', async (method, path) => {
    await request(getHttpServer(app))[method](path).expect(401);
  });

  it('rejeita token inválido', async () => {
    await request(getHttpServer(app))
      .get('/api/orders')
      .set('Authorization', 'Bearer token-invalido')
      .expect(401);
  });

  it('rejeita token expirado', async () => {
    const token = await jwtService.signAsync(
      { sub: randomUUID(), email: 'expired@example.com' },
      { expiresIn: -1 },
    );

    await request(getHttpServer(app))
      .get('/api/orders')
      .set('Authorization', `Bearer ${token}`)
      .expect(401);
  });

  it('aplica whitelist e forbidNonWhitelisted no mesmo setup da produção', async () => {
    const token = await authenticateTestUser(app);

    const response = await request(getHttpServer(app))
      .post('/api/orders')
      .set('Authorization', `Bearer ${token}`)
      .send({ ...buildOrderPayload(), unknownField: 'não permitido' })
      .expect(400);

    const body = response.body as { message: string[] };
    expect(
      body.message.some((message) =>
        message.includes('unknownField should not exist'),
      ),
    ).toBe(true);
  });
});
