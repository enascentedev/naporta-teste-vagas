import { ConflictException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import type { User } from '../generated/prisma/client';
import type { UsersService } from '../users/users.service';
import { buildUserPayload } from '../../test/factories/user.factory';
import { AuthService } from './auth.service';

describe('AuthService', () => {
  let service: AuthService;
  let usersService: jest.Mocked<Pick<UsersService, 'findByEmail' | 'create'>>;
  let jwtService: jest.Mocked<Pick<JwtService, 'signAsync'>>;

  beforeEach(() => {
    usersService = {
      findByEmail: jest.fn(),
      create: jest.fn(),
    };
    jwtService = { signAsync: jest.fn() };
    service = new AuthService(
      usersService as unknown as UsersService,
      jwtService as unknown as JwtService,
    );
  });

  it('registra um usuário com senha em hash e resposta sanitizada', async () => {
    const dto = buildUserPayload();
    usersService.findByEmail.mockResolvedValue(null);
    usersService.create.mockImplementation((data) =>
      Promise.resolve({
        id: 'user-id',
        createdAt: new Date('2030-01-01T00:00:00.000Z'),
        ...data,
      }),
    );

    const result = await service.register(dto);
    const persisted = usersService.create.mock.calls[0][0];

    expect(await bcrypt.compare(dto.password, persisted.password)).toBe(true);
    expect(persisted.password).not.toBe(dto.password);
    expect(result).toEqual({
      id: 'user-id',
      name: dto.name,
      email: dto.email,
      createdAt: new Date('2030-01-01T00:00:00.000Z'),
    });
    expect(result).not.toHaveProperty('password');
  });

  it('rejeita e-mail duplicado sem criar outro usuário', async () => {
    const dto = buildUserPayload();
    usersService.findByEmail.mockResolvedValue({} as User);

    await expect(service.register(dto)).rejects.toBeInstanceOf(
      ConflictException,
    );
    expect(usersService.create).not.toHaveBeenCalled();
  });

  it('retorna um JWT para credenciais válidas', async () => {
    const dto = buildUserPayload();
    const password = await bcrypt.hash(dto.password, 4);
    usersService.findByEmail.mockResolvedValue({
      id: 'user-id',
      name: dto.name,
      email: dto.email,
      password,
      createdAt: new Date(),
    });
    jwtService.signAsync.mockResolvedValue('signed-token');

    await expect(service.login(dto)).resolves.toEqual({
      access_token: 'signed-token',
    });
    expect(jwtService.signAsync).toHaveBeenCalledWith({
      sub: 'user-id',
      email: dto.email,
    });
  });

  it('rejeita senha incorreta com erro genérico', async () => {
    const dto = buildUserPayload();
    usersService.findByEmail.mockResolvedValue({
      id: 'user-id',
      name: dto.name,
      email: dto.email,
      password: await bcrypt.hash('outra-senha', 4),
      createdAt: new Date(),
    });

    await expect(service.login(dto)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
    expect(jwtService.signAsync).not.toHaveBeenCalled();
  });

  it('rejeita usuário inexistente com o mesmo erro genérico', async () => {
    usersService.findByEmail.mockResolvedValue(null);

    await expect(service.login(buildUserPayload())).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });
});
