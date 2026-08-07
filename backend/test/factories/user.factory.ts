import type { RegisterDto } from '../../src/auth/dto/register.dto';

let userSequence = 0;

export function buildUserPayload(
  overrides: Partial<RegisterDto> = {},
): RegisterDto {
  userSequence += 1;

  return {
    name: 'Usuário de Teste',
    email: `usuario-${userSequence}@example.com`,
    password: 'senha123',
    ...overrides,
  };
}
