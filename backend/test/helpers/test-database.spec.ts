import { assertTestDatabaseUrl } from './test-database';

describe('assertTestDatabaseUrl', () => {
  const originalDatabaseUrl = process.env.DATABASE_URL;

  afterEach(() => {
    if (originalDatabaseUrl === undefined) {
      delete process.env.DATABASE_URL;
    } else {
      process.env.DATABASE_URL = originalDatabaseUrl;
    }
  });

  it('aceita um banco cujo nome termina em _test', () => {
    process.env.DATABASE_URL = 'postgresql://user:pass@localhost:5432/app_test';

    expect(assertTestDatabaseUrl()).toBe(process.env.DATABASE_URL);
  });

  it('recusa um banco de desenvolvimento', () => {
    process.env.DATABASE_URL = 'postgresql://user:pass@localhost:5432/app';

    expect(() => assertTestDatabaseUrl()).toThrow('Limpeza recusada');
  });
});
