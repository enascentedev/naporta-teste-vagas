import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/order.dart';

/// Card da listagem, fiel ao protótipo: número do pedido em destaque,
/// previsão de entrega como subtítulo e chevron à direita.
class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  static final _forecastFormat = DateFormat("dd/MM 'às' HH:mm");

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Text(
          order.orderNumber,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Previsão de entrega em '
            '${_forecastFormat.format(order.deliveryForecast.toLocal())}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
