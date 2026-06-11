import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../data/repositories/order_repository.dart';
import '../../domain/models/order.dart';

class DetailsViewModel extends ChangeNotifier {
  DetailsViewModel({
    required OrderRepository repository,
    required this.orderId,
  }) : _repository = repository;

  final OrderRepository _repository;
  final String orderId;

  StreamSubscription<Order?>? _subscription;
  Order? _order;
  List<LatLng> _route = const [];
  bool _isLoadingRoute = false;

  Order? get order => _order;
  List<LatLng> get route => _route;
  bool get isLoadingRoute => _isLoadingRoute;

  void init() {
    _subscription = _repository.watchOrder(orderId).listen((order) {
      final shouldLoadRoute = _order == null && order != null;
      _order = order;
      notifyListeners();
      if (shouldLoadRoute) _loadRoute(order);
    });
  }

  Future<void> _loadRoute(Order order) async {
    if (!order.hasRouteCoordinates) return;
    _isLoadingRoute = true;
    notifyListeners();

    _route = await _repository.getDeliveryRoute(order);

    _isLoadingRoute = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
