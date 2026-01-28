import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/screens/catalog/catalog_screen.dart';
import 'package:mobile_app/screens/cart/cart_screen.dart';
import 'package:mobile_app/screens/profile/profile_screen.dart';
import 'package:mobile_app/providers/cart_provider.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    CatalogScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Каталог'
              : _selectedIndex == 1
              ? 'Корзина'
              : 'Профиль',
        ),
        actions: [],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        selectedIconTheme: IconThemeData(color: Colors.red),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            activeIcon: Icon(Icons.store, color: Colors.red),
            label: 'Каталог',
          ),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (context, cartProvider, _) {
                final count = cartProvider.cartItems.length;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.shopping_bag_outlined),
                    if (count > 0)
                      Positioned(
                        right: -8,
                        top: -8,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            count > 99 ? '99+' : count.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            activeIcon: Consumer<CartProvider>(
              builder: (context, cartProvider, _) {
                final count = cartProvider.cartItems.length;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.shopping_bag, color: Colors.red),
                    if (count > 0)
                      Positioned(
                        right: -8,
                        top: -8,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            count > 99 ? '99+' : count.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: 'Корзина',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle, color: Colors.red),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
