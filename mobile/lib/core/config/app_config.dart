/// Configurações globais do app.
///
/// A URL da API pode ser sobrescrita em tempo de build:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.0.10:3000/api`
///
/// O padrão usa `10.0.2.2`, que é como o emulador Android enxerga o
/// `localhost` da máquina hospedeira.
abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  /// Servidor público de rotas (OSRM) usado para desenhar a rota no mapa.
  static const osrmBaseUrl = String.fromEnvironment(
    'OSRM_BASE_URL',
    defaultValue: 'https://router.project-osrm.org',
  );

  /// Tamanho de página usado na sincronização com a API.
  static const pageSize = 20;
}
