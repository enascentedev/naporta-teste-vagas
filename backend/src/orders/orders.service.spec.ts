import { ConflictException, NotFoundException } from '@nestjs/common';
import { Prisma } from '../generated/prisma/client';
import type { PrismaService } from '../prisma/prisma.service';
import { buildOrderPayload } from '../../test/factories/order.factory';
import { OrdersService } from './orders.service';

describe('OrdersService', () => {
  const prisma = {
    order: {
      create: jest.fn(),
      findMany: jest.fn(),
      count: jest.fn(),
      findFirst: jest.fn(),
      update: jest.fn(),
    },
    $transaction: jest.fn(),
  };
  let service: OrdersService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new OrdersService(prisma as unknown as PrismaService);
  });

  it('cria pedido e itens com a data convertida', async () => {
    const dto = buildOrderPayload();
    prisma.order.create.mockResolvedValue({ id: 'order-id' });

    await expect(service.create(dto)).resolves.toEqual({ id: 'order-id' });
    expect(prisma.order.create).toHaveBeenCalledWith({
      data: {
        orderNumber: dto.orderNumber,
        deliveryForecast: new Date(dto.deliveryForecast),
        customerName: dto.customerName,
        customerDocument: dto.customerDocument,
        customerEmail: dto.customerEmail,
        customerPhone: dto.customerPhone,
        originAddress: dto.originAddress,
        originLat: dto.originLat,
        originLng: dto.originLng,
        deliveryAddress: dto.deliveryAddress,
        deliveryLat: dto.deliveryLat,
        deliveryLng: dto.deliveryLng,
        status: dto.status,
        items: { create: dto.items },
      },
      include: { items: true },
    });
  });

  it('traduz a constraint única de número para conflito', async () => {
    prisma.order.create.mockRejectedValue(
      new Prisma.PrismaClientKnownRequestError('Unique constraint', {
        code: 'P2002',
        clientVersion: '7.8.0',
        meta: { target: ['order_number'] },
      }),
    );

    await expect(service.create(buildOrderPayload())).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it('lista com paginação padrão, exclusão lógica e ordenação estável', async () => {
    prisma.order.findMany.mockReturnValue('find-many-query');
    prisma.order.count.mockReturnValue('count-query');
    prisma.$transaction.mockResolvedValue([[{ id: 'order-id' }], 1]);

    await expect(service.findAll({ page: 1, limit: 10 })).resolves.toEqual({
      data: [{ id: 'order-id' }],
      meta: { total: 1, page: 1, limit: 10, lastPage: 1 },
    });
    expect(prisma.order.findMany).toHaveBeenCalledWith({
      where: { deletedAt: null },
      include: { items: true },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      skip: 0,
      take: 10,
    });
  });

  it('combina número, status, datas e paginação', async () => {
    prisma.$transaction.mockResolvedValue([[], 0]);

    await service.findAll({
      orderNumber: 'abc',
      status: 'DELIVERED',
      startDate: '2030-01-01',
      endDate: '2030-01-31',
      page: 2,
      limit: 5,
    });

    expect(prisma.order.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          deletedAt: null,
          orderNumber: { contains: 'abc', mode: 'insensitive' },
          status: 'DELIVERED',
          createdAt: {
            gte: new Date('2030-01-01'),
            lte: new Date('2030-01-31T23:59:59.999Z'),
          },
        },
        skip: 5,
        take: 5,
      }),
    );
  });

  it('retorna pedido ativo por ID', async () => {
    prisma.order.findFirst.mockResolvedValue({ id: 'order-id' });

    await expect(service.findOne('order-id')).resolves.toEqual({
      id: 'order-id',
    });
    expect(prisma.order.findFirst).toHaveBeenCalledWith({
      where: { id: 'order-id', deletedAt: null },
      include: { items: true },
    });
  });

  it('retorna 404 para pedido inexistente ou excluído', async () => {
    prisma.order.findFirst.mockResolvedValue(null);

    await expect(service.findOne('order-id')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it('atualiza somente campos enviados e substitui itens', async () => {
    const dto = {
      customerName: 'Nome Atualizado',
      customerEmail: null,
      items: [{ description: 'Novo item', price: 10 }],
    };
    prisma.order.findFirst.mockResolvedValue({ id: 'order-id' });
    prisma.order.update.mockResolvedValue({ id: 'order-id', ...dto });

    await service.update('order-id', dto);

    expect(prisma.order.update).toHaveBeenCalledWith({
      where: { id: 'order-id' },
      data: {
        customerName: 'Nome Atualizado',
        customerEmail: null,
        items: { deleteMany: {}, create: dto.items },
      },
      include: { items: true },
    });
  });

  it('faz exclusão lógica após confirmar que o pedido está ativo', async () => {
    const deletedAt = new Date('2030-01-01T00:00:00.000Z');
    jest.useFakeTimers().setSystemTime(deletedAt);
    prisma.order.findFirst.mockResolvedValue({ id: 'order-id' });
    prisma.order.update.mockResolvedValue({ id: 'order-id' });

    await service.remove('order-id');

    expect(prisma.order.update).toHaveBeenCalledWith({
      where: { id: 'order-id' },
      data: { deletedAt },
    });
    jest.useRealTimers();
  });
});
