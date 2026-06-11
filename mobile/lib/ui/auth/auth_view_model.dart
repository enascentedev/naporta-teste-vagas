import 'package:flutter/foundation.dart';

import '../../data/repositories/auth_repository.dart';

/// Estado de autenticação do app inteiro: decide entre a tela de login e a
/// listagem, e executa login/logout.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  bool _initialized = false;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get initialized => _initialized;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    _isLoggedIn = await _repository.isLoggedIn;
    _initialized = true;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.login(email: email, password: password);
    result.when(
      ok: (_) => _isLoggedIn = true,
      err: (message) => _errorMessage = message,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.logout();
    _isLoggedIn = false;
    notifyListeners();
  }

  /// Chamado pelo ApiClient quando uma requisição retorna 401.
  void onSessionExpired() {
    if (!_isLoggedIn) return;
    _isLoggedIn = false;
    notifyListeners();
  }
}
