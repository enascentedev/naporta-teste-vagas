import '../../domain/models/order.dart';
import 'api_client.dart';

class OrdersPage {
  const OrdersPage({
    required this.orders,
    required this.page,
    required this.lastPage,
    required this.total,
  });

  final List<Order> orders;
  final int page;
  final int lastPage;
  final int total;

  bool get hasMore => page < lastPage;
}

class OrdersApi {
  OrdersApi(this._client);

  final ApiClient _client;

  Future<OrdersPage> fetchOrders({required int page, required int limit}) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/orders',
      queryParameters: {'page': page, 'limit': limit},
    );
    final body = response.data!;
    final meta = body['meta'] as Map<String, dynamic>;
    return OrdersPage(
      orders: (body['data'] as List<dynamic>)
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList(),
      page: meta['page'] as int,
      lastPage: meta['lastPage'] as int,
      total: meta['total'] as int,
    );
  }

  Future<Order> createOrder(Map<String, dynamic> payload) async {
    final response =
        await _client.dio.post<Map<String, dynamic>>('/orders', data: payload);
    return Order.fromJson(response.data!);
  }
}
