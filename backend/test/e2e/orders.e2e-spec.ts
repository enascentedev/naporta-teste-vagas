import type { INestApplication } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import request from 'supertest';
import { OrderStatus } from '../../src/generated/prisma/client';
import { PrismaService } from '../../src/prisma/prisma.service';
import {
  buildOrderPayload,
  createOrderInDatabase,
} from '../factories/order.factory';
import { authenticateTestUser } from '../helpers/e2e-auth';
import { createE2eApp, getHttpServer } from '../helpers/e2e-app';
import { cleanTestDatabase } from '../helpers/test-database';

describe('Pedidos (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let token: string;

  const authorized = () => ({ Authorization: `Bearer ${token}` });

  beforeAll(async () => {
    app = await createE2eApp();
    prisma = app.get(PrismaService);
  });

  beforeEach(async () => {
    await cleanTestDatabase(prisma);
    token = await authenticateTestUser(app);
  });

  afterAll(() => app.close());

  describe('criação', () => {
    it('cria payload válido, item válido e status padrão', async () => {
      const payload = buildOrderPayload();

      const response = await request(getHttpServer(app))
        .post('/api/orders')
        .set(authorized())
        .send(payload)
        .expect(201);

      expect(response.body).toMatchObject({
        orderNumber: payload.orderNumber,
        status: OrderStatus.PENDING,
        items: [{ description: payload.items[0].description, price: '49.9' }],
        deletedAt: null,
      });
    });

    it('retorna 409 para número duplicado', async () => {
      const payload = buildOrderPayload();
      await request(getHttpServer(app))
        .post('/api/orders')
        .set(authorized())
        .send(payload)
        .expect(201);

      await request(getHttpServer(app))
        .post('/api/orders')
        .set(authorized())
        .send(payload)
        .expect(409);
    });

    it.each([
      ['lista vazia', []],
      ['descrição vazia', [{ description: '', price: 10 }]],
    ])('rejeita item inválido: %s', async (_label, items) => {
      await request(getHttpServer(app))
        .post('/api/orders')
        .set(authorized())
        .send(buildOrderPayload({ items }))
        .expect(400);
    });

    it.each([0, -1, 10.123])('rejeita preço inválido: %s', async (price) => {
      await request(getHttpServer(app))
        .post('/api/orders')
        .set(authorized())
        .send(
          buildOrderPayload({
            items: [{ description: 'Item', price }],
          }),
        )
        .expect(400);
    });

    it('rejeita status inválido', async () => {
      await request(getHttpServer(app))
        .post('/api/orders')
        .set(authorized())
        .send({ ...buildOrderPayload(), status: 'UNKNOWN' })
        .expect(400);
    });

    it('aceita a ausência dos campos opcionais', async () => {
      const payload = buildOrderPayload();
      delete payload.customerEmail;
      delete payload.customerPhone;
      delete payload.originAddress;
      delete payload.originLat;
      delete payload.originLng;
      delete payload.deliveryLat;
      delete payload.deliveryLng;

      const response = await request(getHttpServer(app))
        .post('/api/orders')
        .set(authorized())
        .send(payload)
        .expect(201);

      expect(response.body).toMatchObject({
        customerEmail: null,
        customerPhone: null,
        originAddress: null,
      });
    });
  });

  describe('listagem e busca', () => {
    it('aplica paginação padrão e customizada', async () => {
      for (let index = 0; index < 12; index += 1) {
        await createOrderInDatabase(prisma);
      }

      const firstPage = await request(getHttpServer(app))
        .get('/api/orders')
        .set(authorized())
        .expect(200);
      const customPage = await request(getHttpServer(app))
        .get('/api/orders?page=2&limit=5')
        .set(authorized())
        .expect(200);

      expect(firstPage.body).toMatchObject({
        meta: { total: 12, page: 1, limit: 10, lastPage: 2 },
      });
      expect((firstPage.body as { data: unknown[] }).data).toHaveLength(10);
      expect(customPage.body).toMatchObject({
        meta: { total: 12, page: 2, limit: 5, lastPage: 3 },
      });
      expect((customPage.body as { data: unknown[] }).data).toHaveLength(5);
    });

    it('aceita limite 100 e rejeita limite 101', async () => {
      await request(getHttpServer(app))
        .get('/api/orders?limit=100')
        .set(authorized())
        .expect(200);
      await request(getHttpServer(app))
        .get('/api/orders?limit=101')
        .set(authorized())
        .expect(400);
    });

    it('ordena por criação decrescente e não lista excluídos', async () => {
      const oldest = await createOrderInDatabase(prisma, buildOrderPayload(), {
        createdAt: new Date('2030-01-01T00:00:00.000Z'),
      });
      const newest = await createOrderInDatabase(prisma, buildOrderPayload(), {
        createdAt: new Date('2030-01-03T00:00:00.000Z'),
      });
      await createOrderInDatabase(prisma, buildOrderPayload(), {
        createdAt: new Date('2030-01-04T00:00:00.000Z'),
        deletedAt: new Date('2030-01-05T00:00:00.000Z'),
      });

      const response = await request(getHttpServer(app))
        .get('/api/orders')
        .set(authorized())
        .expect(200);

      expect(
        (response.body as { data: Array<{ id: string }> }).data.map(
          (order) => order.id,
        ),
      ).toEqual([newest.id, oldest.id]);
      expect(response.body).toMatchObject({ meta: { total: 2 } });
    });

    it('busca pedido existente e inclui itens', async () => {
      const order = await createOrderInDatabase(prisma);

      const response = await request(getHttpServer(app))
        .get(`/api/orders/${order.id}`)
        .set(authorized())
        .expect(200);

      expect(response.body).toMatchObject({ id: order.id });
      expect((response.body as { items: unknown[] }).items).toHaveLength(1);
    });

    it('retorna 404 para pedido inexistente e excluído', async () => {
      const deleted = await createOrderInDatabase(prisma, buildOrderPayload(), {
        deletedAt: new Date(),
      });

      await request(getHttpServer(app))
        .get(`/api/orders/${randomUUID()}`)
        .set(authorized())
        .expect(404);
      await request(getHttpServer(app))
        .get(`/api/orders/${deleted.id}`)
        .set(authorized())
        .expect(404);
    });
  });

  describe('atualização', () => {
    it('faz atualização parcial e preserva os outros campos', async () => {
      const order = await createOrderInDatabase(prisma);

      const response = await request(getHttpServer(app))
        .patch(`/api/orders/${order.id}`)
        .set(authorized())
        .send({ customerName: 'Nome Atualizado' })
        .expect(200);

      expect(response.body).toMatchObject({
        id: order.id,
        customerName: 'Nome Atualizado',
        customerDocument: order.customerDocument,
      });
    });

    it('caracteriza payload vazio como 200 sem alteração de dados', async () => {
      const order = await createOrderInDatabase(prisma);

      const response = await request(getHttpServer(app))
        .patch(`/api/orders/${order.id}`)
        .set(authorized())
        .send({})
        .expect(200);

      expect(response.body).toMatchObject({
        id: order.id,
        customerName: order.customerName,
      });
    });

    it('rejeita campo desconhecido e status inválido', async () => {
      const order = await createOrderInDatabase(prisma);

      await request(getHttpServer(app))
        .patch(`/api/orders/${order.id}`)
        .set(authorized())
        .send({ unknownField: true })
        .expect(400);
      await request(getHttpServer(app))
        .patch(`/api/orders/${order.id}`)
        .set(authorized())
        .send({ status: 'UNKNOWN' })
        .expect(400);
    });

    it('altera status válido e persiste', async () => {
      const order = await createOrderInDatabase(prisma);

      await request(getHttpServer(app))
        .patch(`/api/orders/${order.id}`)
        .set(authorized())
        .send({ status: OrderStatus.DELIVERED })
        .expect(200);

      await expect(
        prisma.order.findUniqueOrThrow({ where: { id: order.id } }),
      ).resolves.toMatchObject({ status: OrderStatus.DELIVERED });
    });

    it('retorna 404 para pedido inexistente ou excluído', async () => {
      const deleted = await createOrderInDatabase(prisma, buildOrderPayload(), {
        deletedAt: new Date(),
      });

      await request(getHttpServer(app))
        .patch(`/api/orders/${randomUUID()}`)
        .set(authorized())
        .send({ status: OrderStatus.DELIVERED })
        .expect(404);
      await request(getHttpServer(app))
        .patch(`/api/orders/${deleted.id}`)
        .set(authorized())
        .send({ status: OrderStatus.DELIVERED })
        .expect(404);
    });
  });

  describe('exclusão lógica', () => {
    it('retorna 204, mantém o registro/itens e o oculta das consultas', async () => {
      const order = await createOrderInDatabase(prisma);

      const deletion = await request(getHttpServer(app))
        .delete(`/api/orders/${order.id}`)
        .set(authorized())
        .expect(204);
      const persisted = await prisma.order.findUniqueOrThrow({
        where: { id: order.id },
        include: { items: true },
      });
      const listing = await request(getHttpServer(app))
        .get('/api/orders')
        .set(authorized())
        .expect(200);

      expect(deletion.text).toBe('');
      expect(persisted.deletedAt).toBeInstanceOf(Date);
      expect(persisted.items).toHaveLength(1);
      expect(listing.body).toMatchObject({ data: [], meta: { total: 0 } });
      await request(getHttpServer(app))
        .get(`/api/orders/${order.id}`)
        .set(authorized())
        .expect(404);
    });

    it('retorna 404 na segunda exclusão', async () => {
      const order = await createOrderInDatabase(prisma);
      await request(getHttpServer(app))
        .delete(`/api/orders/${order.id}`)
        .set(authorized())
        .expect(204);

      await request(getHttpServer(app))
        .delete(`/api/orders/${order.id}`)
        .set(authorized())
        .expect(404);
    });
  });

  describe('filtros', () => {
    async function seedFilters(): Promise<void> {
      await createOrderInDatabase(
        prisma,
        buildOrderPayload({
          orderNumber: 'TARGET-JAN-DELIVERED',
          status: OrderStatus.DELIVERED,
        }),
        { createdAt: new Date('2030-01-15T12:00:00.000Z') },
      );
      await createOrderInDatabase(
        prisma,
        buildOrderPayload({
          orderNumber: 'TARGET-JAN-PENDING',
          status: OrderStatus.PENDING,
        }),
        { createdAt: new Date('2030-01-31T23:00:00.000Z') },
      );
      await createOrderInDatabase(
        prisma,
        buildOrderPayload({
          orderNumber: 'OTHER-FEB-DELIVERED',
          status: OrderStatus.DELIVERED,
        }),
        { createdAt: new Date('2030-02-01T00:00:00.000Z') },
      );
      await createOrderInDatabase(
        prisma,
        buildOrderPayload({
          orderNumber: 'TARGET-DELETED',
          status: OrderStatus.DELIVERED,
        }),
        {
          createdAt: new Date('2030-01-20T12:00:00.000Z'),
          deletedAt: new Date('2030-01-21T12:00:00.000Z'),
        },
      );
    }

    it('filtra número parcial sem diferenciar maiúsculas e status', async () => {
      await seedFilters();

      const number = await request(getHttpServer(app))
        .get('/api/orders?orderNumber=target')
        .set(authorized())
        .expect(200);
      const status = await request(getHttpServer(app))
        .get(`/api/orders?status=${OrderStatus.DELIVERED}`)
        .set(authorized())
        .expect(200);

      expect((number.body as { data: unknown[] }).data).toHaveLength(2);
      expect((status.body as { data: unknown[] }).data).toHaveLength(2);
    });

    it('aplica data inicial, data final inclusiva e intervalo', async () => {
      await seedFilters();

      const start = await request(getHttpServer(app))
        .get('/api/orders?startDate=2030-02-01')
        .set(authorized())
        .expect(200);
      const end = await request(getHttpServer(app))
        .get('/api/orders?endDate=2030-01-31')
        .set(authorized())
        .expect(200);
      const range = await request(getHttpServer(app))
        .get('/api/orders?startDate=2030-01-31&endDate=2030-01-31')
        .set(authorized())
        .expect(200);

      expect((start.body as { data: unknown[] }).data).toHaveLength(1);
      expect((end.body as { data: unknown[] }).data).toHaveLength(2);
      expect(
        (range.body as { data: Array<{ orderNumber: string }> }).data.map(
          (order) => order.orderNumber,
        ),
      ).toEqual(['TARGET-JAN-PENDING']);
    });

    it('combina filtros com paginação e metadados corretos', async () => {
      await seedFilters();

      const response = await request(getHttpServer(app))
        .get(
          `/api/orders?orderNumber=target&status=${OrderStatus.DELIVERED}` +
            '&startDate=2030-01-01&endDate=2030-01-31&page=1&limit=1',
        )
        .set(authorized())
        .expect(200);

      expect(response.body).toMatchObject({
        data: [{ orderNumber: 'TARGET-JAN-DELIVERED' }],
        meta: { total: 1, page: 1, limit: 1, lastPage: 1 },
      });
    });

    it('rejeita intervalo invertido e status inválido', async () => {
      await request(getHttpServer(app))
        .get('/api/orders?startDate=2030-02-01&endDate=2030-01-01')
        .set(authorized())
        .expect(400);
      await request(getHttpServer(app))
        .get('/api/orders?status=UNKNOWN')
        .set(authorized())
        .expect(400);
    });
  });
});
