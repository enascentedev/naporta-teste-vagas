import 'package:naporta_pedidos/domain/models/order.dart';

Order makeOrder({
  String? id,
  String? orderNumber,
  DateTime? createdAt,
  OrderStatus status = OrderStatus.pending,
  bool withCoordinates = true,
}) {
  final suffix = id ?? 'order-1';
  return Order(
    id: suffix,
    orderNumber: orderNumber ?? 'ORD-$suffix',
    deliveryForecast: DateTime.utc(2026, 6, 20, 12),
    customerName: 'Cliente Teste',
    customerDocument: '123.456.789-00',
    customerEmail: 'cliente@teste.com',
    customerPhone: '+55 11 90000-0000',
    originAddress: 'Depósito naPorta - RJ',
    originLat: withCoordinates ? -22.8975 : null,
    originLng: withCoordinates ? -43.2245 : null,
    deliveryAddress: 'Rua Teste, 100 - Rio de Janeiro - RJ',
    deliveryLat: withCoordinates ? -22.8625 : null,
    deliveryLng: withCoordinates ? -43.252 : null,
    status: status,
    createdAt: createdAt ?? DateTime.utc(2026, 6, 10),
    items: const [
      OrderItem(description: 'Produto A', price: 99.9),
      OrderItem(description: 'Produto B', price: 10.1),
    ],
  );
}
