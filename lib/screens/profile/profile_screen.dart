import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/screens/profile/edit_profile_screen.dart';
import 'package:mobile_app/database/database_helper.dart';
import 'package:mobile_app/screens/order/order_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      body: Column(
        children: [
          // Заголовок профиля
          Container(
            padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
            decoration: BoxDecoration(
              color: Colors.red,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 45, color: Colors.red),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? user?.username ?? 'Пользователь',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Меню профиля
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.shopping_bag,
                  title: 'Мои заказы',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrdersScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.person,
                  title: 'Личная информация',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(),
                      ),
                    );
                  },
                ),
                Divider(height: 1),
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Выйти',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () {
                    authProvider.logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.red),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final db = await DatabaseHelper().database;
    final orders = await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'order_date DESC',
    );

    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'В обработке';
      case 'processing':
        return 'Обрабатывается';
      case 'shipped':
        return 'Отправлен';
      case 'delivered':
        return 'Доставлен';
      case 'cancelled':
        return 'Отменен';
      default:
        return 'Неизвестно';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Мои заказы'),
        ),
        body: Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    if (_orders.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Мои заказы'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'У вас пока нет заказов',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Мои заказы'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView.builder(
          itemCount: _orders.length,
          itemBuilder: (context, index) {
            final order = _orders[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(order['status']).withOpacity(0.2),
                  child: Icon(
                    Icons.shopping_bag,
                    color: _getStatusColor(order['status']),
                  ),
                ),
                title: Text(
                  'Заказ #${order['id']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order['status']).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(order['status']),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(order['status']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${(order['total_amount'] as double).toStringAsFixed(0)} ₽',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    if (order['order_date'] != null)
                      Text(
                        'Дата: ${order['order_date']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailScreen(orderId: order['id'] as int),
                    ),
                  ).then((_) => _loadOrders());
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
