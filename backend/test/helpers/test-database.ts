import type { PrismaService } from '../../src/prisma/prisma.service';

export function assertTestDatabaseUrl(): string {
  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    throw new Error(
      'DATABASE_URL de teste não definida. Copie .env.test.example para .env.test.',
    );
  }

  const databaseName = decodeURIComponent(
    new URL(databaseUrl).pathname.slice(1),
  );
  if (!databaseName.endsWith('_test')) {
    throw new Error(
      `Limpeza recusada: o banco "${databaseName}" não termina com "_test".`,
    );
  }

  return databaseUrl;
}

export async function cleanTestDatabase(prisma: PrismaService): Promise<void> {
  assertTestDatabaseUrl();
  await prisma.$executeRawUnsafe(
    'TRUNCATE TABLE "order_items", "orders", "users" RESTART IDENTITY CASCADE',
  );
}
