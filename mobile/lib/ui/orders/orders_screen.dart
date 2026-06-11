import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../auth/auth_view_model.dart';
import '../new_order/new_order_screen.dart';
import '../order_details/details_screen.dart';
import 'orders_view_model.dart';
import 'widgets/order_card.dart';

/// Listagem de pedidos com scroll infinito (tela 1 do protótipo).
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersViewModel>().init();
    });
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 300) {
      context.read<OrdersViewModel>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrdersViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(
            onNewOrder: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NewOrderScreen()),
            ),
            onLogout: () => context.read<AuthViewModel>().logout(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                const Text(
                  'Pedidos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (viewModel.isOffline)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<OrdersViewModel>().refresh(),
              child: _buildList(viewModel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(OrdersViewModel viewModel) {
    if (viewModel.isLoadingFirstPage) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (viewModel.orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.inbox_outlined, size: 56, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Center(
            child: Text(
              'Nenhum pedido encontrado.\nPuxe para atualizar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: viewModel.orders.length + (viewModel.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= viewModel.orders.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        final order = viewModel.orders[index];
        return OrderCard(
          order: order,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetailsScreen(orderId: order.id),
            ),
          ),
        );
      },
    );
  }
}

/// Header laranja do protótipo: logo à esquerda, botão pílula "Novo pedido"
/// à direita.
class _Header extends StatelessWidget {
  const _Header({required this.onNewOrder, required this.onLogout});

  final VoidCallback onNewOrder;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Row(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 36,
            ),
            const Spacer(),
            FilledButton(
              onPressed: onNewOrder,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Novo pedido',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: onLogout,
              tooltip: 'Sair',
              icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
