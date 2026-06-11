import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import '../../core/config/app_config.dart';
import '../../domain/models/order.dart';
import '../local/app_database.dart';
import '../services/orders_api.dart';
import '../services/routing_service.dart';

/// Resultado de uma tentativa de sincronização com a API.
class SyncResult {
  const SyncResult({required this.online, required this.hasMoreRemote});

  final bool online;
  final bool hasMoreRemote;
}

/// Repositório offline first: o banco local (Drift) é a única fonte da
/// verdade para a UI; a API apenas alimenta o banco quando há conexão.
class OrderRepository {
  OrderRepository({
    required AppDatabase database,
    required OrdersApi api,
    RoutingService? routingService,
  })  : _database = database,
        _api = api,
        _routingService = routingService ?? RoutingService();

  final AppDatabase _database;
  final OrdersApi _api;
  final RoutingService _routingService;

  Stream<List<Order>> watchOrders({required int limit}) =>
      _database.watchOrders(limit: limit);

  Stream<Order?> watchOrder(String id) => _database.watchOrder(id);

  Future<int> countLocalOrders() => _database.countOrders();

  /// Busca uma página da API e grava no banco local. Em caso de falha de
  /// rede, retorna `online: false` e a UI continua com os dados locais.
  Future<SyncResult> syncPage(int page) async {
    try {
      final remote =
          await _api.fetchOrders(page: page, limit: AppConfig.pageSize);
      await _database.upsertOrders(remote.orders);
      return SyncResult(online: true, hasMoreRemote: remote.hasMore);
    } on DioException {
      return const SyncResult(online: false, hasMoreRemote: false);
    }
  }

  /// Cria o pedido na API e persiste a resposta localmente.
  Future<Order> createOrder(Map<String, dynamic> payload) async {
    final created = await _api.createOrder(payload);
    await _database.upsertOrders([created]);
    return created;
  }

  /// Rota de entrega para o mapa: tenta o cache local primeiro (offline
  /// first); se não houver, busca no OSRM e guarda em cache.
  Future<List<LatLng>> getDeliveryRoute(Order order) async {
    if (!order.hasRouteCoordinates) return const [];

    final cached = await _database.getRouteGeometry(order.id);
    if (cached != null && cached.isNotEmpty) return cached;

    final origin = LatLng(order.originLat!, order.originLng!);
    final destination = LatLng(order.deliveryLat!, order.deliveryLng!);
    try {
      final route = await _routingService.fetchRoute(origin, destination);
      await _database.saveRouteGeometry(order.id, route);
      return route;
    } on DioException {
      // Sem rede e sem cache: liga os dois pontos em linha reta.
      return [origin, destination];
    }
  }
}
