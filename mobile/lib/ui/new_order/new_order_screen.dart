import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/order_repository.dart';
import '../../domain/models/order.dart';
import 'new_order_view_model.dart';

/// Formulário de criação de pedido, acionado pelo botão "Novo pedido" do
/// protótipo (que não define essa tela — seguimos o mesmo design system).
class NewOrderScreen extends StatelessWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          NewOrderViewModel(repository: context.read<OrderRepository>()),
      child: const _NewOrderView(),
    );
  }
}

class _NewOrderView extends StatefulWidget {
  const _NewOrderView();

  @override
  State<_NewOrderView> createState() => _NewOrderViewState();
}

class _ItemFields {
  final description = TextEditingController();
  final price = TextEditingController();

  void dispose() {
    description.dispose();
    price.dispose();
  }
}

class _NewOrderViewState extends State<_NewOrderView> {
  final _formKey = GlobalKey<FormState>();
  final _orderNumber = TextEditingController();
  final _customerName = TextEditingController();
  final _customerDocument = TextEditingController();
  final _customerEmail = TextEditingController();
  final _customerPhone = TextEditingController();
  final _deliveryAddress = TextEditingController();
  final _items = [_ItemFields()];
  DateTime _deliveryForecast = DateTime.now().add(const Duration(days: 2));

  static final _forecastFormat = DateFormat("dd/MM/yyyy 'às' HH:mm");

  @override
  void dispose() {
    _orderNumber.dispose();
    _customerName.dispose();
    _customerDocument.dispose();
    _customerEmail.dispose();
    _customerPhone.dispose();
    _deliveryAddress.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _pickForecast() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deliveryForecast,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deliveryForecast),
    );
    setState(() {
      _deliveryForecast = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 12,
        time?.minute ?? 0,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await context.read<NewOrderViewModel>().submit(
          orderNumber: _orderNumber.text.trim(),
          deliveryForecast: _deliveryForecast,
          customerName: _customerName.text.trim(),
          customerDocument: _customerDocument.text.trim(),
          customerEmail: _customerEmail.text.trim(),
          customerPhone: _customerPhone.text.trim(),
          deliveryAddress: _deliveryAddress.text.trim(),
          items: _items
              .map((item) => OrderItem(
                    description: item.description.text.trim(),
                    price: double.parse(
                      item.price.text.replaceAll(',', '.'),
                    ),
                  ))
              .toList(),
        );

    if (!mounted) return;
    result.when(
      ok: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido criado com sucesso!')),
        );
        Navigator.of(context).pop();
      },
      err: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.danger,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<NewOrderViewModel>().isSubmitting;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo pedido')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _orderNumber,
              decoration: const InputDecoration(labelText: 'Número do pedido'),
              validator: _required,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickForecast,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Previsão de entrega',
                  suffixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                ),
                child: Text(_forecastFormat.format(_deliveryForecast)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerName,
              decoration: const InputDecoration(labelText: 'Nome do cliente'),
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerDocument,
              decoration:
                  const InputDecoration(labelText: 'Documento (CPF/CNPJ)'),
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerEmail,
              keyboardType: TextInputType.emailAddress,
              decoration:
                  const InputDecoration(labelText: 'E-mail (opcional)'),
              validator: (value) =>
                  (value != null && value.isNotEmpty && !value.contains('@'))
                      ? 'E-mail inválido'
                      : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerPhone,
              keyboardType: TextInputType.phone,
              decoration:
                  const InputDecoration(labelText: 'Telefone (opcional)'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deliveryAddress,
              decoration:
                  const InputDecoration(labelText: 'Endereço de entrega'),
              validator: _required,
            ),
            const SizedBox(height: 24),
            const Text(
              'Itens do pedido',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: item.description,
                        decoration:
                            const InputDecoration(labelText: 'Descrição'),
                        validator: _required,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: item.price,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(labelText: r'Preço (R$)'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Obrigatório';
                          }
                          final parsed =
                              double.tryParse(value.replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) {
                            return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_items.length > 1)
                      IconButton(
                        onPressed: () => setState(() {
                          _items.removeAt(index).dispose();
                        }),
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: AppColors.danger,
                        ),
                      ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: () => setState(() => _items.add(_ItemFields())),
              icon: const Icon(Icons.add, color: AppColors.primary),
              label: const Text(
                'Adicionar item',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSubmitting ? null : _submit,
              child: isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Criar pedido'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  static String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Campo obrigatório' : null;
}
