import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:naporta_pedidos/core/config/app_config.dart';
import 'package:naporta_pedidos/data/repositories/order_repository.dart';
import 'package:naporta_pedidos/domain/models/order.dart';
import 'package:naporta_pedidos/ui/orders/orders_view_model.dart';

import '../helpers/fixtures.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late _MockOrderRepository repository;
  late OrdersViewModel viewModel;
  late StreamController<List<Order>> ordersController;

  setUp(() {
    repository = _MockOrderRepository();
    ordersController = StreamController<List<Order>>.broadcast();
    when(() => repository.watchOrders(limit: any(named: 'limit')))
        .thenAnswer((_) => ordersController.stream);
    viewModel = OrdersViewModel(repository: repository);
  });

  tearDown(() {
    viewModel.dispose();
    ordersController.close();
  });

  test('init sincroniza a primeira página e observa o banco local', () async {
    when(() => repository.syncPage(1)).thenAnswer(
      (_) async => const SyncResult(online: true, hasMoreRemote: true),
    );

    await viewModel.init();
    ordersController.add([makeOrder(id: '1'), makeOrder(id: '2')]);
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.orders, hasLength(2));
    expect(viewModel.isOffline, isFalse);
    verify(() => repository.syncPage(1)).called(1);
  });

  test('falha de rede no refresh marca o estado offline', () async {
    when(() => repository.syncPage(1)).thenAnswer(
      (_) async => const SyncResult(online: false, hasMoreRemote: false),
    );

    await viewModel.init();

    expect(viewModel.isOffline, isTrue);
  });

  test('loadMore busca a página seguinte da API', () async {
    when(() => repository.syncPage(any())).thenAnswer(
      (_) async => const SyncResult(online: true, hasMoreRemote: true),
    );
    when(() => repository.countLocalOrders())
        .thenAnswer((_) async => AppConfig.pageSize * 2);

    await viewModel.init();
    await viewModel.loadMore();

    verify(() => repository.syncPage(2)).called(1);
  });

  test('loadMore offline ainda expande o limite local', () async {
    when(() => repository.syncPage(any())).thenAnswer(
      (_) async => const SyncResult(online: false, hasMoreRemote: false),
    );
    when(() => repository.countLocalOrders())
        .thenAnswer((_) async => AppConfig.pageSize * 3);

    await viewModel.init();
    await viewModel.loadMore();

    expect(viewModel.isOffline, isTrue);
    // Observa o banco local com um limite maior (2ª chamada de watchOrders).
    verify(() => repository.watchOrders(limit: AppConfig.pageSize)).called(1);
    verify(() => repository.watchOrders(limit: AppConfig.pageSize * 2))
        .called(1);
  });

  test('loadMore não dispara quando não há mais dados', () async {
    when(() => repository.syncPage(1)).thenAnswer(
      (_) async => const SyncResult(online: true, hasMoreRemote: false),
    );
    when(() => repository.countLocalOrders()).thenAnswer((_) async => 2);

    await viewModel.init();
    ordersController.add([makeOrder(id: '1'), makeOrder(id: '2')]);
    await Future<void>.delayed(Duration.zero);

    await viewModel.loadMore();

    verifyNever(() => repository.syncPage(2));
  });
}
