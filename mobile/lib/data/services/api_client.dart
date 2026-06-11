import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config/app_config.dart';

/// Cliente HTTP central: injeta o Bearer token e notifica quando a sessão
/// expira (401), para que o app volte para a tela de login.
class ApiClient {
  ApiClient({
    Dio? dio,
    FlutterSecureStorage? storage,
    this.onUnauthorized,
  })  : dio = dio ?? Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl)),
        _storage = storage ?? const FlutterSecureStorage() {
    this.dio.options.connectTimeout = const Duration(seconds: 5);
    this.dio.options.receiveTimeout = const Duration(seconds: 10);
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final isLoginCall =
              error.requestOptions.path.contains('/auth/login');
          if (error.response?.statusCode == 401 && !isLoginCall) {
            await clearToken();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  static const _tokenKey = 'access_token';

  final Dio dio;
  final FlutterSecureStorage _storage;

  /// Chamado quando uma requisição autenticada retorna 401.
  void Function()? onUnauthorized;

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
