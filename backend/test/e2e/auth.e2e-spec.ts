import type { INestApplication } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import request from 'supertest';
import { PrismaService } from '../../src/prisma/prisma.service';
import { buildUserPayload } from '../factories/user.factory';
import { createE2eApp, getHttpServer } from '../helpers/e2e-app';
import { cleanTestDatabase } from '../helpers/test-database';

describe('Autenticação (e2e)', () => {
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

  it('registra usuário com 201, armazena hash e omite a senha', async () => {
    const payload = buildUserPayload();

    const response = await request(getHttpServer(app))
      .post('/api/auth/register')
      .send(payload)
      .expect(201);
    const body = response.body as Record<string, unknown>;
    const persisted = await prisma.user.findUniqueOrThrow({
      where: { email: payload.email },
    });

    expect(body).toMatchObject({ name: payload.name, email: payload.email });
    expect(body).not.toHaveProperty('password');
    expect(await bcrypt.compare(payload.password, persisted.password)).toBe(
      true,
    );
    expect(persisted.password).not.toBe(payload.password);
  });

  it('retorna 409 para e-mail duplicado', async () => {
    const payload = buildUserPayload();
    await request(getHttpServer(app))
      .post('/api/auth/register')
      .send(payload)
      .expect(201);

    const response = await request(getHttpServer(app))
      .post('/api/auth/register')
      .send(payload)
      .expect(409);

    expect(JSON.stringify(response.body)).not.toContain(payload.password);
  });

  it('faz login válido e retorna JWT com os claims esperados', async () => {
    const payload = buildUserPayload();
    const registration = await request(getHttpServer(app))
      .post('/api/auth/register')
      .send(payload)
      .expect(201);

    const response = await request(getHttpServer(app))
      .post('/api/auth/login')
      .send({ email: payload.email, password: payload.password })
      .expect(200);
    const body = response.body as { access_token: string; password?: string };
    const claims = await jwtService.verifyAsync<{ sub: string; email: string }>(
      body.access_token,
    );

    expect(body.password).toBeUndefined();
    expect(claims).toMatchObject({
      sub: (registration.body as { id: string }).id,
      email: payload.email,
    });
  });

  it('retorna 401 e mensagem genérica para senha incorreta', async () => {
    const payload = buildUserPayload();
    await request(getHttpServer(app))
      .post('/api/auth/register')
      .send(payload)
      .expect(201);

    const response = await request(getHttpServer(app))
      .post('/api/auth/login')
      .send({ email: payload.email, password: 'senha-incorreta' })
      .expect(401);

    expect(response.body).toMatchObject({ message: 'Credenciais inválidas' });
    expect(JSON.stringify(response.body)).not.toContain('senha-incorreta');
  });

  it('retorna o mesmo 401 genérico para usuário inexistente', async () => {
    const response = await request(getHttpServer(app))
      .post('/api/auth/login')
      .send({ email: 'inexistente@example.com', password: 'senha123' })
      .expect(401);

    expect(response.body).toMatchObject({ message: 'Credenciais inválidas' });
  });
});
