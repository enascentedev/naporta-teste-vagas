import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:naporta_pedidos/data/local/app_database.dart';
import 'package:naporta_pedidos/data/repositories/order_repository.dart';
import 'package:naporta_pedidos/data/services/orders_api.dart';
import 'package:naporta_pedidos/data/services/routing_service.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_database.dart';

class _MockOrdersApi extends Mock implements OrdersApi {}

class _MockRoutingService extends Mock implements RoutingService {}

DioException _networkError() => DioException(
      requestOptions: RequestOptions(path: '/orders'),
      type: DioExceptionType.connectionError,
    );

void main() {
  late AppDatabase database;
  late _MockOrdersApi api;
  late _MockRoutingService routing;
  late OrderRepository repository;

  setUpAll(() {
    registerFallbackValue(const LatLng(0, 0));
  });

  setUp(() {
    database = createInMemoryDatabase();
    api = _MockOrdersApi();
    routing = _MockRoutingService();
    repository = OrderRepository(
      database: database,
      api: api,
      routingService: routing,
    );
  });

  tearDown(() => database.close());

  test('syncPage persiste os pedidos da API no banco local', () async {
    when(() => api.fetchOrders(page: 1, limit: any(named: 'limit')))
        .thenAnswer(
      (_) async => OrdersPage(
        orders: [makeOrder(id: 'a'), makeOrder(id: 'b')],
        page: 1,
        lastPage: 2,
        total: 30,
      ),
    );

    final result = await repository.syncPage(1);

    expect(result.online, isTrue);
    expect(result.hasMoreRemote, isTrue);
    expect(await repository.countLocalOrders(), 2);
  });

  test('syncPage atualiza pedidos já existentes (upsert)', () async {
    when(() => api.fetchOrders(page: 1, limit: any(named: 'limit')))
        .thenAnswer(
      (_) async => OrdersPage(
        orders: [makeOrder(id: 'a')],
        page: 1,
        lastPage: 1,
        total: 1,
      ),
    );
    await repository.syncPage(1);

    when(() => api.fetchOrders(page: 1, limit: any(named: 'limit')))
        .thenAnswer(
      (_) async => OrdersPage(
        orders: [makeOrder(id: 'a', orderNumber: 'ORD-ATUALIZADO')],
        page: 1,
        lastPage: 1,
        total: 1,
      ),
    );
    await repository.syncPage(1);

    final orders = await repository.watchOrders(limit: 10).first;
    expect(orders, hasLength(1));
    expect(orders.single.orderNumber, 'ORD-ATUALIZADO');
  });

  test('syncPage offline mantém os dados locais (offline first)', () async {
    when(() => api.fetchOrders(page: 1, limit: any(named: 'limit')))
        .thenAnswer(
      (_) async => OrdersPage(
        orders: [makeOrder(id: 'a')],
        page: 1,
        lastPage: 1,
        total: 1,
      ),
    );
    await repository.syncPage(1);

    when(() => api.fetchOrders(page: any(named: 'page'), limit: any(named: 'limit')))
        .thenThrow(_networkError());

    final result = await repository.syncPage(1);

    expect(result.online, isFalse);
    expect(await repository.countLocalOrders(), 1,
        reason: 'dados locais sobrevivem à falha de rede');
  });

  test('watchOrders ordena do mais recente para o mais antigo', () async {
    await database.upsertOrders([
      makeOrder(id: 'antigo', createdAt: DateTime.utc(2026, 1, 1)),
      makeOrder(id: 'recente', createdAt: DateTime.utc(2026, 6, 1)),
    ]);

    final orders = await repository.watchOrders(limit: 10).first;

    expect(orders.first.id, 'recente');
  });

  test('getDeliveryRoute busca no OSRM e usa cache na segunda chamada',
      () async {
    final order = makeOrder(id: 'a');
    await database.upsertOrders([order]);
    when(() => routing.fetchRoute(any(), any())).thenAnswer(
      (_) async => const [LatLng(-22.89, -43.22), LatLng(-22.86, -43.25)],
    );

    final first = await repository.getDeliveryRoute(order);
    final second = await repository.getDeliveryRoute(order);

    expect(first, hasLength(2));
    expect(second, first);
    verify(() => routing.fetchRoute(any(), any())).called(1);
  });

  test('getDeliveryRoute sem rede e sem cache liga origem e destino',
      () async {
    final order = makeOrder(id: 'a');
    await database.upsertOrders([order]);
    when(() => routing.fetchRoute(any(), any())).thenThrow(_networkError());

    final route = await repository.getDeliveryRoute(order);

    expect(route, [
      LatLng(order.originLat!, order.originLng!),
      LatLng(order.deliveryLat!, order.deliveryLng!),
    ]);
  });

  test('getDeliveryRoute sem coordenadas retorna vazio', () async {
    final order = makeOrder(id: 'a', withCoordinates: false);

    final route = await repository.getDeliveryRoute(order);

    expect(route, isEmpty);
    verifyNever(() => routing.fetchRoute(any(), any()));
  });
}
