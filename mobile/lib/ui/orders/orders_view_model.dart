import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';
import '../../data/repositories/order_repository.dart';
import '../../domain/models/order.dart';

/// ViewModel da listagem com scroll infinito offline first: a lista exibida
/// vem sempre do banco local; cada "página" a mais aumenta o limite local e,
/// quando online, sincroniza a página seguinte da API.
class OrdersViewModel extends ChangeNotifier {
  OrdersViewModel({required OrderRepository repository})
      : _repository = repository;

  final OrderRepository _repository;

  StreamSubscription<List<Order>>? _subscription;
  List<Order> _orders = [];
  bool _isLoadingFirstPage = true;
  bool _isLoadingMore = false;
  bool _isOffline = false;
  bool _hasMoreRemote = true;
  int _visibleLimit = AppConfig.pageSize;
  int _remotePage = 1;

  List<Order> get orders => _orders;
  bool get isLoadingFirstPage => _isLoadingFirstPage;
  bool get isLoadingMore => _isLoadingMore;
  bool get isOffline => _isOffline;

  /// Ainda há mais para carregar (na API ou já persistido localmente)?
  bool get hasMore => _hasMoreRemote || _orders.length >= _visibleLimit;

  Future<void> init() async {
    _watchLocal();
    await refresh();
  }

  void _watchLocal() {
    _subscription?.cancel();
    _subscription =
        _repository.watchOrders(limit: _visibleLimit).listen((orders) {
      _orders = orders;
      _isLoadingFirstPage = false;
      notifyListeners();
    });
  }

  /// Pull-to-refresh: volta para a primeira página da API.
  Future<void> refresh() async {
    final result = await _repository.syncPage(1);
    _remotePage = 1;
    _isOffline = !result.online;
    _hasMoreRemote = result.hasMoreRemote;
    _isLoadingFirstPage = false;
    notifyListeners();
  }

  /// Chamado quando o usuário se aproxima do fim da lista.
  Future<void> loadMore() async {
    if (_isLoadingMore || _isLoadingFirstPage) return;
    final localCount = await _repository.countLocalOrders();
    final reachedLocalEnd = _orders.length >= localCount;
    if (reachedLocalEnd && !_hasMoreRemote) return;

    _isLoadingMore = true;
    notifyListeners();

    _visibleLimit += AppConfig.pageSize;
    if (_hasMoreRemote) {
      final result = await _repository.syncPage(_remotePage + 1);
      if (result.online) {
        _remotePage++;
        _hasMoreRemote = result.hasMoreRemote;
        _isOffline = false;
      } else {
        _isOffline = true;
      }
    }
    _watchLocal();

    _isLoadingMore = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
