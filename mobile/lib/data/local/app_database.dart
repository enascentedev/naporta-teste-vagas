import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/models/order.dart';

part 'app_database.g.dart';

/// Tabela local de pedidos. Os itens são embutidos como JSON porque só são
/// exibidos junto do pedido (nunca consultados separadamente). A coluna
/// [routeGeometryJson] guarda a rota OSRM em cache para o mapa funcionar
/// offline após a primeira visualização.
class OrderRows extends Table {
  TextColumn get id => text()();
  TextColumn get orderNumber => text()();
  DateTimeColumn get deliveryForecast => dateTime()();
  TextColumn get customerName => text()();
  TextColumn get customerDocument => text()();
  TextColumn get customerEmail => text().nullable()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get originAddress => text().nullable()();
  RealColumn get originLat => real().nullable()();
  RealColumn get originLng => real().nullable()();
  TextColumn get deliveryAddress => text()();
  RealColumn get deliveryLat => real().nullable()();
  RealColumn get deliveryLng => real().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get itemsJson => text()();
  TextColumn get routeGeometryJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [OrderRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
          driftDatabase(
            name: 'naporta_pedidos',
            // Necessário apenas na web: aponta para os assets em web/
            // (sqlite3.wasm e drift_worker.js). Ignorado nas demais plataformas.
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
        );

  /// Construtor para testes (banco em memória).
  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 1;

  /// Pedidos mais recentes primeiro, mesma ordenação da API.
  Stream<List<Order>> watchOrders({required int limit}) {
    final query = (select(orderRows)
      ..orderBy([
        (row) =>
            OrderingTerm(expression: row.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(limit));
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Stream<Order?> watchOrder(String id) {
    final query = select(orderRows)..where((row) => row.id.equals(id));
    return query.watchSingleOrNull().map(
          (row) => row == null ? null : _toDomain(row),
        );
  }

  Future<int> countOrders() async {
    final countExp = orderRows.id.count();
    final query = selectOnly(orderRows)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<void> upsertOrders(List<Order> orders) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        orderRows,
        orders.map(_toRow).toList(),
      );
    });
  }

  Future<void> saveRouteGeometry(String orderId, List<LatLng> route) async {
    final json = jsonEncode(
      route.map((point) => [point.latitude, point.longitude]).toList(),
    );
    await (update(orderRows)..where((row) => row.id.equals(orderId)))
        .write(OrderRowsCompanion(routeGeometryJson: Value(json)));
  }

  Future<List<LatLng>?> getRouteGeometry(String orderId) async {
    final query = select(orderRows)..where((row) => row.id.equals(orderId));
    final row = await query.getSingleOrNull();
    if (row?.routeGeometryJson == null) return null;
    final decoded = jsonDecode(row!.routeGeometryJson!) as List<dynamic>;
    return decoded
        .map((pair) => LatLng(
              (pair[0] as num).toDouble(),
              (pair[1] as num).toDouble(),
            ))
        .toList();
  }

  Order _toDomain(OrderRow row) => Order(
        id: row.id,
        orderNumber: row.orderNumber,
        deliveryForecast: row.deliveryForecast,
        customerName: row.customerName,
        customerDocument: row.customerDocument,
        customerEmail: row.customerEmail,
        customerPhone: row.customerPhone,
        originAddress: row.originAddress,
        originLat: row.originLat,
        originLng: row.originLng,
        deliveryAddress: row.deliveryAddress,
        deliveryLat: row.deliveryLat,
        deliveryLng: row.deliveryLng,
        status: OrderStatus.fromApi(row.status),
        createdAt: row.createdAt,
        items: (jsonDecode(row.itemsJson) as List<dynamic>)
            .map((json) => OrderItem.fromJson(json as Map<String, dynamic>))
            .toList(),
      );

  OrderRowsCompanion _toRow(Order order) => OrderRowsCompanion.insert(
        id: order.id,
        orderNumber: order.orderNumber,
        deliveryForecast: order.deliveryForecast,
        customerName: order.customerName,
        customerDocument: order.customerDocument,
        customerEmail: Value(order.customerEmail),
        customerPhone: Value(order.customerPhone),
        originAddress: Value(order.originAddress),
        originLat: Value(order.originLat),
        originLng: Value(order.originLng),
        deliveryAddress: order.deliveryAddress,
        deliveryLat: Value(order.deliveryLat),
        deliveryLng: Value(order.deliveryLng),
        status: order.status.apiValue,
        createdAt: order.createdAt,
        itemsJson: jsonEncode(
          order.items.map((item) => item.toJson()).toList(),
        ),
      );
}
