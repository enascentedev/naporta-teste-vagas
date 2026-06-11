/// Status do pedido, espelhando o enum da API.
enum OrderStatus {
  pending('PENDING', 'Pendente'),
  inTransit('IN_TRANSIT', 'Em trânsito'),
  delivered('DELIVERED', 'Entregue'),
  cancelled('CANCELLED', 'Cancelado');

  const OrderStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static OrderStatus fromApi(String value) => OrderStatus.values.firstWhere(
        (s) => s.apiValue == value,
        orElse: () => OrderStatus.pending,
      );
}

class OrderItem {
  const OrderItem({required this.description, required this.price});

  final String description;
  final double price;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        description: json['description'] as String,
        // A API serializa Decimal como string (ex.: "1199.9").
        price: double.tryParse(json['price'].toString()) ?? 0,
      );

  Map<String, dynamic> toJson() => {'description': description, 'price': price};
}

class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.deliveryForecast,
    required this.customerName,
    required this.customerDocument,
    this.customerEmail,
    this.customerPhone,
    this.originAddress,
    this.originLat,
    this.originLng,
    required this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    required this.status,
    required this.createdAt,
    this.items = const [],
  });

  final String id;
  final String orderNumber;
  final DateTime deliveryForecast;
  final String customerName;
  final String customerDocument;
  final String? customerEmail;
  final String? customerPhone;
  final String? originAddress;
  final double? originLat;
  final double? originLng;
  final String deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final OrderStatus status;
  final DateTime createdAt;
  final List<OrderItem> items;

  bool get hasRouteCoordinates =>
      originLat != null &&
      originLng != null &&
      deliveryLat != null &&
      deliveryLng != null;

  double get totalPrice =>
      items.fold(0, (total, item) => total + item.price);

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        orderNumber: json['orderNumber'] as String,
        deliveryForecast: DateTime.parse(json['deliveryForecast'] as String),
        customerName: json['customerName'] as String,
        customerDocument: json['customerDocument'] as String,
        customerEmail: json['customerEmail'] as String?,
        customerPhone: json['customerPhone'] as String?,
        originAddress: json['originAddress'] as String?,
        originLat: (json['originLat'] as num?)?.toDouble(),
        originLng: (json['originLng'] as num?)?.toDouble(),
        deliveryAddress: json['deliveryAddress'] as String,
        deliveryLat: (json['deliveryLat'] as num?)?.toDouble(),
        deliveryLng: (json['deliveryLng'] as num?)?.toDouble(),
        status: OrderStatus.fromApi(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        items: (json['items'] as List<dynamic>? ?? [])
            .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
