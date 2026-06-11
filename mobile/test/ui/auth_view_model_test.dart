import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:naporta_pedidos/core/result.dart';
import 'package:naporta_pedidos/data/repositories/auth_repository.dart';
import 'package:naporta_pedidos/ui/auth/auth_view_model.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late AuthViewModel viewModel;

  setUp(() {
    repository = _MockAuthRepository();
    viewModel = AuthViewModel(repository: repository);
  });

  test('init carrega o estado de login persistido', () async {
    when(() => repository.isLoggedIn).thenAnswer((_) async => true);

    await viewModel.init();

    expect(viewModel.initialized, isTrue);
    expect(viewModel.isLoggedIn, isTrue);
  });

  test('login com sucesso marca usuário como autenticado', () async {
    when(() => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Ok(null));

    await viewModel.login(email: 'admin@naporta.com', password: 'naporta123');

    expect(viewModel.isLoggedIn, isTrue);
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.isLoading, isFalse);
  });

  test('login com falha expõe mensagem de erro', () async {
    when(() => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Err('E-mail ou senha incorretos.'));

    await viewModel.login(email: 'admin@naporta.com', password: 'errada');

    expect(viewModel.isLoggedIn, isFalse);
    expect(viewModel.errorMessage, 'E-mail ou senha incorretos.');
  });

  test('logout limpa a sessão', () async {
    when(() => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Ok(null));
    when(() => repository.logout()).thenAnswer((_) async {});

    await viewModel.login(email: 'a@a.com', password: 'x');
    await viewModel.logout();

    expect(viewModel.isLoggedIn, isFalse);
    verify(() => repository.logout()).called(1);
  });

  test('onSessionExpired derruba o usuário autenticado', () async {
    when(() => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Ok(null));

    await viewModel.login(email: 'a@a.com', password: 'x');
    viewModel.onSessionExpired();

    expect(viewModel.isLoggedIn, isFalse);
  });
}
