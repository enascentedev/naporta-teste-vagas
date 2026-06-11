import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/result.dart';
import '../../data/repositories/order_repository.dart';
import '../../domain/models/order.dart';

class NewOrderViewModel extends ChangeNotifier {
  NewOrderViewModel({required OrderRepository repository})
      : _repository = repository;

  final OrderRepository _repository;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<Result<Order>> submit({
    required String orderNumber,
    required DateTime deliveryForecast,
    required String customerName,
    required String customerDocument,
    String? customerEmail,
    String? customerPhone,
    required String deliveryAddress,
    required List<OrderItem> items,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final order = await _repository.createOrder({
        'orderNumber': orderNumber,
        'deliveryForecast': deliveryForecast.toUtc().toIso8601String(),
        'customerName': customerName,
        'customerDocument': customerDocument,
        if (customerEmail != null && customerEmail.isNotEmpty)
          'customerEmail': customerEmail,
        if (customerPhone != null && customerPhone.isNotEmpty)
          'customerPhone': customerPhone,
        'deliveryAddress': deliveryAddress,
        'items': items.map((item) => item.toJson()).toList(),
      });
      return Ok(order);
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        return const Err('Já existe um pedido com esse número.');
      }
      if (error.response?.statusCode == 400) {
        return const Err('Dados inválidos. Revise os campos.');
      }
      return const Err(
        'Não foi possível criar o pedido. Verifique sua conexão.',
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
