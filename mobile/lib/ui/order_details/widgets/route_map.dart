import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/order.dart';

/// Mapa com a rota de entrega (OpenStreetMap + rota OSRM), com marcadores
/// laranja de origem (caminhão) e destino (caixa), como no protótipo.
class RouteMap extends StatelessWidget {
  const RouteMap({super.key, required this.order, required this.route});

  final Order order;
  final List<LatLng> route;

  @override
  Widget build(BuildContext context) {
    if (!order.hasRouteCoordinates) {
      return Container(
        height: 200,
        color: AppColors.divider,
        alignment: Alignment.center,
        child: const Text(
          'Rota indisponível para este pedido',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final origin = LatLng(order.originLat!, order.originLng!);
    final destination = LatLng(order.deliveryLat!, order.deliveryLng!);
    final boundsSource = route.isNotEmpty ? route : [origin, destination];

    return SizedBox(
      height: 220,
      child: FlutterMap(
        options: MapOptions(
          initialCameraFit: CameraFit.coordinates(
            coordinates: boundsSource,
            padding: const EdgeInsets.all(40),
          ),
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'br.com.naporta.naporta_pedidos',
          ),
          if (route.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: route,
                  color: AppColors.primary,
                  strokeWidth: 4,
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              _marker(origin, Icons.local_shipping_outlined),
              _marker(destination, Icons.inventory_2_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Marker _marker(LatLng point, IconData icon) => Marker(
        point: point,
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      );
}
