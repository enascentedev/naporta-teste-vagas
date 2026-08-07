import type { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { buildUserPayload } from '../factories/user.factory';
import { getHttpServer } from './e2e-app';

export async function authenticateTestUser(
  app: INestApplication,
): Promise<string> {
  const user = buildUserPayload();
  const server = getHttpServer(app);

  const registration = await request(server)
    .post('/api/auth/register')
    .send(user);
  if (registration.status !== 201) {
    throw new Error(
      `Falha ao registrar usuário de teste: ${registration.status}`,
    );
  }

  const login = await request(server).post('/api/auth/login').send({
    email: user.email,
    password: user.password,
  });
  if (login.status !== 200) {
    throw new Error(`Falha no login do usuário de teste: ${login.status}`);
  }

  return (login.body as { access_token: string }).access_token;
}
