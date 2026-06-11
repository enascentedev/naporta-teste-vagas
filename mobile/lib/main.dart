import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/local/app_database.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/order_repository.dart';
import 'data/services/api_client.dart';
import 'data/services/orders_api.dart';
import 'ui/auth/auth_view_model.dart';
import 'ui/login/login_screen.dart';
import 'ui/orders/orders_screen.dart';
import 'ui/orders/orders_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final database = AppDatabase();
  final authViewModel = AuthViewModel(
    repository: AuthRepository(client: apiClient),
  );
  // Sessão expirada (401) derruba o usuário para a tela de login.
  apiClient.onUnauthorized = authViewModel.onSessionExpired;

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        Provider.value(value: database),
        Provider(
          create: (_) => OrderRepository(
            database: database,
            api: OrdersApi(apiClient),
          ),
        ),
        ChangeNotifierProvider.value(value: authViewModel..init()),
      ],
      child: const NaPortaApp(),
    ),
  );
}

class NaPortaApp extends StatelessWidget {
  const NaPortaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'naPorta Pedidos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _Root(),
    );
  }
}

/// Decide entre login e listagem conforme o estado de autenticação.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    if (!auth.initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!auth.isLoggedIn) return const LoginScreen();

    return ChangeNotifierProvider(
      create: (context) =>
          OrdersViewModel(repository: context.read<OrderRepository>()),
      child: const OrdersScreen(),
    );
  }
}
