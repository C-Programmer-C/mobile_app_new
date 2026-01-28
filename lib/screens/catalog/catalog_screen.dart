import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/models/product.dart';
import 'package:mobile_app/database/database_helper.dart';
import 'package:mobile_app/screens/catalog/product_detail_screen.dart';
import 'package:mobile_app/providers/cart_provider.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Product> _products = [];
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await DatabaseHelper().database;

    final categories = await db.query('categories');
    setState(() {
      _categories = categories;
    });

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final db = await DatabaseHelper().database;
    List<Map<String, dynamic>> productMaps;

    if (_selectedCategoryId == null) {
      productMaps = await db.query('products');
    } else {
      productMaps = await db.query(
        'products',
        where: 'category_id = ?',
        whereArgs: [_selectedCategoryId],
      );
    }

    setState(() {
      _products = productMaps.map((map) => Product.fromMap(map)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Категории
        Container(
          height: 70,
          padding: EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategoryId == category['id'];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (category['icon'] != null)
                        Text(
                          category['icon'],
                          style: TextStyle(fontSize: 18),
                        ),
                      SizedBox(width: 4),
                      Text(category['name']),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryId = selected ? category['id'] : null;
                      _loadProducts();
                    });
                  },
                  selectedColor: Colors.red,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),
        Divider(height: 1),
        // Список товаров
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return ProductCard(product: product);
            },
          ),
        ),
      ],
    );
  }
}

Widget _buildProductImage(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return Icon(Icons.photo, size: 50, color: Colors.grey);
  }
  
  return ColoredBox(
    color: Colors.white,
    child: Image.asset(
      imageUrl,
      fit: BoxFit.contain,
      width: double.infinity,
      alignment: Alignment.center,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: Icon(Icons.photo, size: 50, color: Colors.grey),
        );
      },
    ),
  );
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение товара
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? ColoredBox(
                          color: Colors.white,
                          child: Image.asset(
                            product.imageUrl!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            alignment: Alignment.center,
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.photo, size: 50, color: Colors.grey),
                              );
                            },
                          ),
                        )
                      : Icon(Icons.photo, size: 50, color: Colors.grey),
                ),
              ),
            ),
            // Информация о товаре
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      SizedBox(width: 2),
                      Text(
                        product.rating.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(0)} ₽',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final cartProvider = Provider.of<CartProvider>(context, listen: false);
                        cartProvider.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Товар добавлен в корзину'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(Icons.shopping_cart, size: 18),
                      label: Text('В корзину'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
