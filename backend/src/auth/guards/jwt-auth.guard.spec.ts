import type { ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { JwtAuthGuard } from './jwt-auth.guard';

describe('JwtAuthGuard', () => {
  const handler = (): void => undefined;
  class TestController {}

  const context = {
    getHandler: () => handler,
    getClass: () => TestController,
  } as unknown as ExecutionContext;

  afterEach(() => jest.restoreAllMocks());

  it('libera explicitamente uma rota marcada como pública', () => {
    const reflector = {
      getAllAndOverride: jest.fn().mockReturnValue(true),
    };
    const guard = new JwtAuthGuard(reflector as unknown as Reflector);

    expect(guard.canActivate(context)).toBe(true);
    expect(reflector.getAllAndOverride).toHaveBeenCalledWith('isPublic', [
      handler,
      TestController,
    ]);
  });

  it('delega ao guard JWT quando a rota não é pública', () => {
    const reflector = {
      getAllAndOverride: jest.fn().mockReturnValue(false),
    };
    const passportGuardPrototype = Object.getPrototypeOf(
      JwtAuthGuard.prototype,
    ) as { canActivate: (executionContext: ExecutionContext) => boolean };
    const passportCanActivate = jest
      .spyOn(passportGuardPrototype, 'canActivate')
      .mockReturnValue(true);
    const guard = new JwtAuthGuard(reflector as unknown as Reflector);

    expect(guard.canActivate(context)).toBe(true);
    expect(passportCanActivate).toHaveBeenCalledWith(context);
  });
});
