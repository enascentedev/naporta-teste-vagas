import 'api_client.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  /// Retorna o `access_token` em caso de sucesso.
  Future<String> login({required String email, required String password}) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return response.data!['access_token'] as String;
  }
}
