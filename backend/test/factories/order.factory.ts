import { OrderStatus } from '../../src/generated/prisma/client';
import type { CreateOrderDto } from '../../src/orders/dto/create-order.dto';
import type { PrismaService } from '../../src/prisma/prisma.service';

let orderSequence = 0;

export function buildOrderPayload(
  overrides: Partial<CreateOrderDto> = {},
): CreateOrderDto {
  orderSequence += 1;
  const items = [{ description: 'Produto de teste', price: 49.9 }];

  return {
    orderNumber: `TEST-${orderSequence.toString().padStart(5, '0')}`,
    deliveryForecast: '2030-02-15T12:00:00.000Z',
    customerName: 'Cliente de Teste',
    customerDocument: '123.456.789-00',
    customerEmail: 'cliente@example.com',
    customerPhone: '+55 11 99999-0000',
    originAddress: 'Origem de Teste, 100',
    originLat: -23.5505,
    originLng: -46.6333,
    deliveryAddress: 'Destino de Teste, 200',
    deliveryLat: -22.9068,
    deliveryLng: -43.1729,
    items,
    ...overrides,
    items: overrides.items ?? items,
  };
}

export async function createOrderInDatabase(
  prisma: PrismaService,
  payload: CreateOrderDto = buildOrderPayload(),
  timestamps: { createdAt?: Date; deletedAt?: Date } = {},
) {
  return prisma.order.create({
    data: {
      orderNumber: payload.orderNumber,
      deliveryForecast: new Date(payload.deliveryForecast),
      customerName: payload.customerName,
      customerDocument: payload.customerDocument,
      customerEmail: payload.customerEmail,
      customerPhone: payload.customerPhone,
      originAddress: payload.originAddress,
      originLat: payload.originLat,
      originLng: payload.originLng,
      deliveryAddress: payload.deliveryAddress,
      deliveryLat: payload.deliveryLat,
      deliveryLng: payload.deliveryLng,
      status: payload.status ?? OrderStatus.PENDING,
      createdAt: timestamps.createdAt,
      deletedAt: timestamps.deletedAt,
      items: { create: payload.items },
    },
    include: { items: true },
  });
}
