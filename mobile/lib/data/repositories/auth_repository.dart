import 'package:dio/dio.dart';

import '../../core/result.dart';
import '../services/api_client.dart';
import '../services/auth_api.dart';

class AuthRepository {
  AuthRepository({required ApiClient client, AuthApi? api})
      : _client = client,
        _api = api ?? AuthApi(client);

  final ApiClient _client;
  final AuthApi _api;

  Future<bool> get isLoggedIn async => await _client.readToken() != null;

  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    try {
      final token = await _api.login(email: email, password: password);
      await _client.saveToken(token);
      return const Ok(null);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        return const Err('E-mail ou senha incorretos.');
      }
      return const Err(
        'Não foi possível conectar ao servidor. Verifique sua conexão.',
      );
    }
  }

  Future<void> logout() => _client.clearToken();
}
