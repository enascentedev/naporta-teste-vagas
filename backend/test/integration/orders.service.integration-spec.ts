import { ConfigModule } from '@nestjs/config';
import { Test, type TestingModule } from '@nestjs/testing';
import { OrderStatus } from '../../src/generated/prisma/client';
import { OrdersModule } from '../../src/orders/orders.module';
import { OrdersService } from '../../src/orders/orders.service';
import { PrismaModule } from '../../src/prisma/prisma.module';
import { PrismaService } from '../../src/prisma/prisma.service';
import {
  buildOrderPayload,
  createOrderInDatabase,
} from '../factories/order.factory';
import { cleanTestDatabase } from '../helpers/test-database';

describe('OrdersService com PostgreSQL', () => {
  let moduleRef: TestingModule;
  let prisma: PrismaService;
  let ordersService: OrdersService;

  beforeAll(async () => {
    moduleRef = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({ isGlobal: true }),
        PrismaModule,
        OrdersModule,
      ],
    }).compile();
    await moduleRef.init();
    prisma = moduleRef.get(PrismaService);
    ordersService = moduleRef.get(OrdersService);
  });

  beforeEach(() => cleanTestDatabase(prisma));
  afterAll(() => moduleRef.close());

  it('persiste pedido, itens e preço decimal', async () => {
    const payload = buildOrderPayload({
      items: [{ description: 'Item persistido', price: 10.25 }],
    });

    const created = await ordersService.create(payload);
    const persisted = await prisma.order.findUnique({
      where: { id: created.id },
      include: { items: true },
    });

    expect(persisted?.items).toHaveLength(1);
    expect(persisted?.items[0].description).toBe('Item persistido');
    expect(persisted?.items[0].price.toString()).toBe('10.25');
  });

  it('faz exclusão lógica sem remover o pedido nem seus itens', async () => {
    const created = await ordersService.create(buildOrderPayload());

    await ordersService.remove(created.id);

    const persisted = await prisma.order.findUnique({
      where: { id: created.id },
      include: { items: true },
    });
    const visible = await ordersService.findAll({ page: 1, limit: 10 });

    expect(persisted?.deletedAt).toBeInstanceOf(Date);
    expect(persisted?.items).toHaveLength(1);
    expect(visible.data).toHaveLength(0);
    expect(visible.meta.total).toBe(0);
  });

  it('combina número, status, período e paginação', async () => {
    await createOrderInDatabase(
      prisma,
      buildOrderPayload({
        orderNumber: 'COMBO-ALVO-01',
        status: OrderStatus.DELIVERED,
      }),
      { createdAt: new Date('2030-01-15T12:00:00.000Z') },
    );
    await createOrderInDatabase(
      prisma,
      buildOrderPayload({
        orderNumber: 'COMBO-FORA-02',
        status: OrderStatus.PENDING,
      }),
      { createdAt: new Date('2030-01-15T12:00:00.000Z') },
    );

    const result = await ordersService.findAll({
      orderNumber: 'alvo',
      status: OrderStatus.DELIVERED,
      startDate: '2030-01-01',
      endDate: '2030-01-31',
      page: 1,
      limit: 1,
    });

    expect(result.data.map((order) => order.orderNumber)).toEqual([
      'COMBO-ALVO-01',
    ]);
    expect(result.meta).toEqual({ total: 1, page: 1, limit: 1, lastPage: 1 });
  });

  it('desempata registros com o mesmo createdAt por id decrescente', async () => {
    const createdAt = new Date('2030-01-15T12:00:00.000Z');
    const first = await createOrderInDatabase(prisma, buildOrderPayload(), {
      createdAt,
    });
    const second = await createOrderInDatabase(prisma, buildOrderPayload(), {
      createdAt,
    });

    const result = await ordersService.findAll({ page: 1, limit: 10 });
    const expectedIds = [first.id, second.id].sort((left, right) =>
      right.localeCompare(left),
    );

    expect(result.data.map((order) => order.id)).toEqual(expectedIds);
  });
});
