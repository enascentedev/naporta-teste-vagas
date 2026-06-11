import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import '../../core/config/app_config.dart';

/// Busca a geometria da rota de carro entre dois pontos usando o OSRM
/// (gratuito, sem chave de API).
class RoutingService {
  RoutingService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<List<LatLng>> fetchRoute(LatLng origin, LatLng destination) async {
    final coords = '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}';
    final response = await _dio.get<Map<String, dynamic>>(
      '${AppConfig.osrmBaseUrl}/route/v1/driving/$coords',
      queryParameters: {'overview': 'full', 'geometries': 'geojson'},
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );

    final routes = response.data!['routes'] as List<dynamic>;
    if (routes.isEmpty) return [origin, destination];

    final geometry = routes.first['geometry'] as Map<String, dynamic>;
    return (geometry['coordinates'] as List<dynamic>)
        .map((pair) => LatLng(
              (pair[1] as num).toDouble(),
              (pair[0] as num).toDouble(),
            ))
        .toList();
  }
}
