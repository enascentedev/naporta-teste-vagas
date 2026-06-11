import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Order, Prisma } from '../generated/prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { FilterOrdersDto } from './dto/filter-orders.dto';
import { UpdateOrderDto } from './dto/update-order.dto';

@Injectable()
export class OrdersService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateOrderDto): Promise<Order> {
    try {
      return await this.prisma.order.create({
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
    } catch (error) {
      this.handleUniqueConstraint(error);
      throw error;
    }
  }

  async findAll(filter: FilterOrdersDto) {
    const { orderNumber, startDate, endDate, status, page, limit } = filter;

    const where: Prisma.OrderWhereInput = {
      deletedAt: null,
      ...(orderNumber && {
        orderNumber: { contains: orderNumber, mode: 'insensitive' },
      }),
      ...(status && { status }),
      ...((startDate || endDate) && {
        createdAt: {
          ...(startDate && { gte: new Date(startDate) }),
          ...(endDate && { lte: this.toEndOfDay(endDate) }),
        },
      }),
    };

    const [data, total] = await this.prisma.$transaction([
      this.prisma.order.findMany({
        where,
        include: { items: true },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.order.count({ where }),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        lastPage: Math.max(Math.ceil(total / limit), 1),
      },
    };
  }

  async findOne(id: string): Promise<Order> {
    const order = await this.prisma.order.findFirst({
      where: { id, deletedAt: null },
      include: { items: true },
    });

    if (!order) {
      throw new NotFoundException('Pedido não encontrado');
    }

    return order;
  }

  async update(id: string, dto: UpdateOrderDto): Promise<Order> {
    await this.findOne(id);

    try {
      return await this.prisma.order.update({
        where: { id },
        data: {
          // Campos obrigatórios no schema: ignora null/undefined para não
          // violar a coluna NOT NULL (PartialType torna todos opcionais no DTO)
          ...(dto.orderNumber != null && { orderNumber: dto.orderNumber }),
          ...(dto.deliveryForecast != null && {
            deliveryForecast: new Date(dto.deliveryForecast),
          }),
          ...(dto.customerName != null && { customerName: dto.customerName }),
          ...(dto.customerDocument != null && {
            customerDocument: dto.customerDocument,
          }),
          ...(dto.deliveryAddress != null && {
            deliveryAddress: dto.deliveryAddress,
          }),
          ...(dto.status != null && { status: dto.status }),
          // Campos anuláveis: undefined preserva o valor atual, null limpa
          ...(dto.customerEmail !== undefined && {
            customerEmail: dto.customerEmail,
          }),
          ...(dto.customerPhone !== undefined && {
            customerPhone: dto.customerPhone,
          }),
          ...(dto.originAddress !== undefined && {
            originAddress: dto.originAddress,
          }),
          ...(dto.originLat !== undefined && { originLat: dto.originLat }),
          ...(dto.originLng !== undefined && { originLng: dto.originLng }),
          ...(dto.deliveryLat !== undefined && {
            deliveryLat: dto.deliveryLat,
          }),
          ...(dto.deliveryLng !== undefined && {
            deliveryLng: dto.deliveryLng,
          }),
          ...(dto.items != null && {
            items: { deleteMany: {}, create: dto.items },
          }),
        },
        include: { items: true },
      });
    } catch (error) {
      this.handleUniqueConstraint(error);
      throw error;
    }
  }

  async remove(id: string): Promise<void> {
    await this.findOne(id);

    await this.prisma.order.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }

  private handleUniqueConstraint(error: unknown): void {
    if (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === 'P2002'
    ) {
      throw new ConflictException('Já existe um pedido com este número');
    }
  }

  private toEndOfDay(date: string): Date {
    const parsed = new Date(date);
    if (/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      parsed.setUTCHours(23, 59, 59, 999);
    }
    return parsed;
  }
}
