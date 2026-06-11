import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/order.dart';

/// Timeline "Saindo em…" / "Chegando em…" da tela de detalhes do protótipo.
class RouteTimeline extends StatelessWidget {
  const RouteTimeline({super.key, required this.order});

  final Order order;

  static final _dateFormat = DateFormat("dd/MM/yyyy 'às' HH:mm");

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TimelineStep(
          icon: Icons.local_shipping_outlined,
          title: 'Saindo em ${order.originAddress ?? 'origem não informada'}',
          subtitle: _dateFormat.format(order.createdAt.toLocal()),
          showConnector: true,
        ),
        _TimelineStep(
          icon: Icons.inventory_2_outlined,
          title: 'Chegando em ${order.deliveryAddress}',
          subtitle: _dateFormat.format(order.deliveryForecast.toLocal()),
          showConnector: false,
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.showConnector,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              if (showConnector)
                Expanded(
                  child: Container(width: 2, color: AppColors.divider),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showConnector ? 20 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
