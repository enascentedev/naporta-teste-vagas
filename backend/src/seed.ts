import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import * as bcrypt from 'bcrypt';
import { OrderStatus, PrismaClient } from './generated/prisma/client';

const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
  throw new Error('A variável de ambiente DATABASE_URL não está definida');
}

const adapter = new PrismaPg({ connectionString });
const prisma = new PrismaClient({ adapter });

const daysFromNow = (days: number): Date =>
  new Date(Date.now() + days * 24 * 60 * 60 * 1000);

const depotRio = {
  originAddress:
    'Depósito naPorta - Av. Brasil, 500 - São Cristóvão, Rio de Janeiro - RJ',
  originLat: -22.8975,
  originLng: -43.2245,
};

const depotSp = {
  originAddress: 'Depósito naPorta - Av. do Estado, 900 - Brás, São Paulo - SP',
  originLat: -23.5475,
  originLng: -46.623,
};

const orders = [
  {
    orderNumber: 'ORD-0001',
    deliveryForecast: daysFromNow(2),
    customerName: 'Maria da Silva',
    customerDocument: '123.456.789-00',
    customerEmail: 'maria.silva@email.com',
    customerPhone: '+55 21 99876-1001',
    ...depotRio,
    deliveryAddress:
      'Rua das Acácias, 120 - Complexo do Alemão, Rio de Janeiro - RJ',
    deliveryLat: -22.8625,
    deliveryLng: -43.252,
    status: OrderStatus.PENDING,
    createdAt: daysFromNow(-1),
    items: [
      { description: 'Smartphone Galaxy A15', price: 1199.9 },
      { description: 'Película de vidro', price: 29.9 },
    ],
  },
  {
    orderNumber: 'ORD-0002',
    deliveryForecast: daysFromNow(3),
    customerName: 'João Pereira',
    customerDocument: '987.654.321-00',
    customerEmail: 'joao.pereira@email.com',
    customerPhone: '+55 21 99876-1002',
    ...depotRio,
    deliveryAddress: 'Travessa São Jorge, 45 - Rocinha, Rio de Janeiro - RJ',
    deliveryLat: -22.9888,
    deliveryLng: -43.248,
    status: OrderStatus.IN_TRANSIT,
    createdAt: daysFromNow(-2),
    items: [{ description: 'Tênis esportivo nº 42', price: 249.99 }],
  },
  {
    orderNumber: 'ORD-0003',
    deliveryForecast: daysFromNow(-5),
    customerName: 'Ana Beatriz Costa',
    customerDocument: '456.789.123-00',
    customerEmail: 'ana.costa@email.com',
    customerPhone: '+55 11 99876-1003',
    ...depotSp,
    deliveryAddress: 'Rua da Paz, 78 - Paraisópolis, São Paulo - SP',
    deliveryLat: -23.618,
    deliveryLng: -46.725,
    status: OrderStatus.DELIVERED,
    createdAt: daysFromNow(-10),
    items: [
      { description: 'Panela de pressão 4,5L', price: 159.9 },
      { description: 'Jogo de talheres 24 peças', price: 89.9 },
      { description: 'Avental de cozinha', price: 24.5 },
    ],
  },
  {
    orderNumber: 'ORD-0004',
    deliveryForecast: daysFromNow(1),
    customerName: 'Carlos Eduardo Lima',
    customerDocument: '321.654.987-00',
    customerEmail: 'carlos.lima@email.com',
    customerPhone: '+55 11 99876-1004',
    ...depotSp,
    deliveryAddress: 'Beco do Sossego, 12 - Heliópolis, São Paulo - SP',
    deliveryLat: -23.611,
    deliveryLng: -46.59,
    status: OrderStatus.PENDING,
    createdAt: daysFromNow(-1),
    items: [{ description: 'Fone de ouvido Bluetooth', price: 129.9 }],
  },
  {
    orderNumber: 'ORD-0005',
    deliveryForecast: daysFromNow(-2),
    customerName: 'Fernanda Oliveira',
    customerDocument: '654.321.987-00',
    customerEmail: 'fernanda.oliveira@email.com',
    customerPhone: '+55 21 99876-1005',
    ...depotRio,
    deliveryAddress: 'Rua Nova Esperança, 230 - Maré, Rio de Janeiro - RJ',
    deliveryLat: -22.858,
    deliveryLng: -43.241,
    status: OrderStatus.CANCELLED,
    createdAt: daysFromNow(-7),
    items: [
      { description: 'Vestido floral M', price: 119.9 },
      { description: 'Bolsa de ombro', price: 89.0 },
    ],
  },
  {
    orderNumber: 'ORD-0006',
    deliveryForecast: daysFromNow(4),
    customerName: 'Roberto Santos',
    customerDocument: '789.123.456-00',
    customerEmail: 'roberto.santos@email.com',
    customerPhone: '+55 21 99876-1006',
    ...depotRio,
    deliveryAddress: 'Rua do Campo, 310 - Cidade de Deus, Rio de Janeiro - RJ',
    deliveryLat: -22.945,
    deliveryLng: -43.362,
    status: OrderStatus.IN_TRANSIT,
    createdAt: daysFromNow(-3),
    items: [
      { description: 'Furadeira de impacto 650W', price: 299.9 },
      { description: 'Kit de brocas 10 peças', price: 49.9 },
    ],
  },
  {
    orderNumber: 'ORD-0007',
    deliveryForecast: daysFromNow(-8),
    customerName: 'Juliana Almeida',
    customerDocument: '147.258.369-00',
    customerEmail: 'juliana.almeida@email.com',
    customerPhone: '+55 21 99876-1007',
    ...depotRio,
    deliveryAddress: 'Rua Boa Vista, 55 - Vidigal, Rio de Janeiro - RJ',
    deliveryLat: -22.993,
    deliveryLng: -43.233,
    status: OrderStatus.DELIVERED,
    createdAt: daysFromNow(-15),
    items: [{ description: 'Liquidificador 900W', price: 189.9 }],
  },
  {
    orderNumber: 'ORD-0008',
    deliveryForecast: daysFromNow(5),
    customerName: 'Pedro Henrique Souza',
    customerDocument: '258.369.147-00',
    customerEmail: 'pedro.souza@email.com',
    customerPhone: '+55 11 99876-1008',
    ...depotSp,
    deliveryAddress: 'Rua das Flores, 89 - Capão Redondo, São Paulo - SP',
    deliveryLat: -23.672,
    deliveryLng: -46.778,
    status: OrderStatus.PENDING,
    createdAt: daysFromNow(0),
    items: [
      { description: 'Mochila escolar', price: 99.9 },
      { description: 'Caderno universitário 200 folhas', price: 19.9 },
      { description: 'Estojo com zíper', price: 14.9 },
    ],
  },
  {
    orderNumber: 'ORD-0009',
    deliveryForecast: daysFromNow(-20),
    customerName: 'Luciana Rocha',
    customerDocument: '369.147.258-00',
    customerEmail: 'luciana.rocha@email.com',
    customerPhone: '+55 11 99876-1009',
    ...depotSp,
    deliveryAddress: 'Rua Esperança, 14 - Brasilândia, São Paulo - SP',
    deliveryLat: -23.46,
    deliveryLng: -46.69,
    status: OrderStatus.DELIVERED,
    createdAt: daysFromNow(-30),
    items: [{ description: 'Ventilador de mesa 40cm', price: 149.9 }],
  },
  {
    orderNumber: 'ORD-0010',
    deliveryForecast: daysFromNow(7),
    customerName: 'Marcos Vinícius Teixeira',
    customerDocument: '741.852.963-00',
    customerEmail: 'marcos.teixeira@email.com',
    customerPhone: '+55 21 99876-1010',
    ...depotRio,
    deliveryAddress: 'Rua União, 202 - Complexo da Penha, Rio de Janeiro - RJ',
    deliveryLat: -22.842,
    deliveryLng: -43.277,
    status: OrderStatus.PENDING,
    createdAt: daysFromNow(0),
    items: [
      { description: 'Cafeteira elétrica 30 xícaras', price: 169.9 },
      { description: 'Caixa de cápsulas de café (50 un)', price: 79.9 },
    ],
  },
];

async function main(): Promise<void> {
  const passwordHash = await bcrypt.hash('naporta123', 10);

  await prisma.user.upsert({
    where: { email: 'admin@naporta.com' },
    update: {},
    create: {
      name: 'Admin naPorta',
      email: 'admin@naporta.com',
      password: passwordHash,
    },
  });

  for (const { items, ...order } of orders) {
    await prisma.order.upsert({
      where: { orderNumber: order.orderNumber },
      update: order,
      create: { ...order, items: { create: items } },
    });
  }

  console.log('Seed concluído: 1 usuário (admin@naporta.com) e 10 pedidos.');
}

main()
  .catch((error) => {
    console.error('Erro ao executar o seed:', error);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
