import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/cart_provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/database/database_helper.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _promoCodeController = TextEditingController();
  String _paymentMethod = 'card';
  double _discount = 0.0;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final subtotal = cartProvider.cartItems.fold(0.0, (sum, item) {
      return sum + (item.product!.price * item.quantity);
    });
    final discountAmount = subtotal * _discount;
    final total = subtotal - discountAmount;

    return Scaffold(
      appBar: AppBar(title: Text('Оформление заказа')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Контактная информация',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Телефон',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите телефон';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Адрес доставки',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите адрес доставки';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              Text(
                'Промокод',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _promoCodeController,
                      decoration: InputDecoration(
                        labelText: 'Введите промокод',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_offer),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final code = _promoCodeController.text.trim().toUpperCase();
                      if (code.isNotEmpty) {
                        setState(() {
                          _discount = 0.0;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Промокод "${code}" не найден. Функция будет доступна в будущем.'),
                          ),
                        );
                      }
                    },
                    child: Text('Применить'),
                  ),
                ],
              ),
              if (_discount > 0)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Скидка: ${(_discount * 100).toStringAsFixed(0)}%',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              SizedBox(height: 24),
              Text(
                'Способ оплаты',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              RadioListTile(
                title: Text('Банковская карта'),
                value: 'card',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value.toString();
                  });
                },
              ),
              RadioListTile(
                title: Text('Наличные при получении'),
                value: 'cash',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value.toString();
                  });
                },
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Товары:', style: TextStyle(fontSize: 16)),
                        Text('${subtotal.toStringAsFixed(0)} ₽'),
                      ],
                    ),
                    if (_discount > 0) ...[
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Скидка:', style: TextStyle(fontSize: 16, color: Colors.green)),
                          Text(
                            '-${discountAmount.toStringAsFixed(0)} ₽',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Доставка:', style: TextStyle(fontSize: 16)),
                        Text('Бесплатно'),
                      ],
                    ),
                    Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Итого к оплате:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${total.toStringAsFixed(0)} ₽',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final orderId = await _createOrder(total);
                      
                      if (orderId != null && mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 28),
                                SizedBox(width: 8),
                                Expanded(child: Text('Заказ оформлен!')),
                              ],
                            ),
                            content: Text(
                              'Ваш заказ успешно оформлен.\nНомер заказа: #$orderId',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.popUntil(
                                    context,
                                    (route) => route.isFirst,
                                  );
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Подтвердить заказ',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int?> _createOrder(double total) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      
      if (userId == null) return null;

      final db = await DatabaseHelper().database;
      
      final orderId = await db.insert('orders', {
        'user_id': userId,
        'total_amount': total,
        'status': 'pending',
        'shipping_address': _addressController.text,
        'phone': _phoneController.text,
      });

      for (var item in cartProvider.cartItems) {
        await db.insert('order_items', {
          'order_id': orderId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.product!.price,
        });
      }

      for (var item in cartProvider.cartItems) {
        await cartProvider.removeFromCart(item);
      }
      
      return orderId;
    } catch (e) {
      print('Ошибка создания заказа: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка создания заказа: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }
}
