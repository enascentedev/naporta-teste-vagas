import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/order_repository.dart';
import 'details_view_model.dart';
import 'widgets/route_map.dart';
import 'widgets/route_timeline.dart';

/// Detalhes do pedido (tela 2 do protótipo): mapa com rota, timeline,
/// dados do pedido e do cliente.
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DetailsViewModel(
        repository: context.read<OrderRepository>(),
        orderId: orderId,
      )..init(),
      child: const _DetailsView(),
    );
  }
}

class _DetailsView extends StatelessWidget {
  const _DetailsView();

  static final _priceFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DetailsViewModel>();
    final order = viewModel.order;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(order == null ? 'Pedido' : 'Pedido ${order.orderNumber}'),
      ),
      body: order == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    RouteMap(order: order, route: viewModel.route),
                    if (viewModel.isLoadingRoute)
                      const Positioned(
                        top: 12,
                        child: Chip(
                          avatar: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          label: Text(
                            'Calculando rota…',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RouteTimeline(order: order),
                      const SizedBox(height: 24),
                      const _SectionLabel('Pedido'),
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.status.label,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _SectionLabel('Cliente'),
                      Text(order.customerName, style: _valueStyle),
                      if (order.customerEmail != null)
                        Text(order.customerEmail!, style: _mutedStyle),
                      if (order.customerPhone != null)
                        Text(order.customerPhone!, style: _mutedStyle),
                      Text(order.customerDocument, style: _mutedStyle),
                      const SizedBox(height: 24),
                      const _SectionLabel('Itens'),
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child:
                                    Text(item.description, style: _valueStyle),
                              ),
                              Text(
                                _priceFormat.format(item.price),
                                style: _mutedStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(color: AppColors.divider),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Total',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            _priceFormat.format(order.totalPrice),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  static const _valueStyle = TextStyle(
    fontSize: 15,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const _mutedStyle = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.5,
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
