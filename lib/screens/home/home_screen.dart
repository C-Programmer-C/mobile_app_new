import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/screens/catalog/catalog_screen.dart';
import 'package:mobile_app/screens/cart/cart_screen.dart';
import 'package:mobile_app/screens/profile/profile_screen.dart';
import 'package:mobile_app/providers/cart_provider.dart';
import 'package:mobile_app/database/database_helper.dart';
import 'package:mobile_app/models/product.dart';
import 'package:mobile_app/screens/catalog/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
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
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: ProductSearchDelegate());
              },
            ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
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

class ProductSearchDelegate extends SearchDelegate<String> {
  List<Product> _products = [];
  bool _isLoading = false;

  Future<void> _loadProducts() async {
    if (query.isEmpty) {
      _products = [];
      return;
    }

    _isLoading = true;
    final db = await DatabaseHelper().database;
    final productMaps = await db.query(
      'products',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    _products = productMaps.map((map) => Product.fromMap(map)).toList();
    _isLoading = false;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
            _products = [];
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('Введите запрос для поиска'));
    }

    return FutureBuilder<void>(
      future: _loadProducts(),
      builder: (context, snapshot) {
        if (_isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (_products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Ничего не найдено',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Попробуйте изменить запрос',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return ListTile(
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.photo, color: Colors.grey);
                          },
                        ),
                      )
                    : Icon(Icons.photo, color: Colors.grey),
              ),
              title: Text(product.name),
              subtitle: Text(
                '${product.price.toStringAsFixed(0)} ₽',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                close(context, '');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Начните вводить название товара',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return buildResults(context);
  }
}
