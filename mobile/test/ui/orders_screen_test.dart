import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:naporta_pedidos/data/repositories/auth_repository.dart';
import 'package:naporta_pedidos/data/repositories/order_repository.dart';
import 'package:naporta_pedidos/ui/auth/auth_view_model.dart';
import 'package:naporta_pedidos/ui/orders/orders_screen.dart';
import 'package:naporta_pedidos/ui/orders/orders_view_model.dart';
import 'package:naporta_pedidos/ui/orders/widgets/order_card.dart';
import 'package:provider/provider.dart';

import '../helpers/fixtures.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockOrderRepository orderRepository;
  late _MockAuthRepository authRepository;

  setUp(() {
    orderRepository = _MockOrderRepository();
    authRepository = _MockAuthRepository();
    when(() => orderRepository.watchOrders(limit: any(named: 'limit')))
        .thenAnswer(
      (_) => Stream.value([
        makeOrder(id: '1', orderNumber: 'ORD-0001'),
        makeOrder(id: '2', orderNumber: 'ORD-0002'),
      ]),
    );
    when(() => orderRepository.syncPage(any())).thenAnswer(
      (_) async => const SyncResult(online: true, hasMoreRemote: false),
    );
    when(() => orderRepository.countLocalOrders()).thenAnswer((_) async => 2);
  });

  Widget buildScreen() => MultiProvider(
        providers: [
          Provider<OrderRepository>.value(value: orderRepository),
          ChangeNotifierProvider(
            create: (_) => AuthViewModel(repository: authRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => OrdersViewModel(repository: orderRepository),
          ),
        ],
        child: const MaterialApp(home: OrdersScreen()),
      );

  testWidgets('exibe os pedidos vindos do banco local', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('ORD-0001'), findsOneWidget);
    expect(find.text('ORD-0002'), findsOneWidget);
    expect(find.byType(OrderCard), findsNWidgets(2));
    expect(find.textContaining('Previsão de entrega em'), findsNWidgets(2));
  });

  testWidgets('exibe o badge offline quando a sincronização falha',
      (tester) async {
    when(() => orderRepository.syncPage(any())).thenAnswer(
      (_) async => const SyncResult(online: false, hasMoreRemote: false),
    );

    await tester.pumpWidget(buildScreen());
    await tester.pump();

    expect(find.text('Offline'), findsOneWidget);
  });

  testWidgets('header tem o botão Novo pedido', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    expect(find.text('Novo pedido'), findsOneWidget);
  });
}
