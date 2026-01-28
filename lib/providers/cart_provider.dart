import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_app/models/cart_item.dart';
import 'package:mobile_app/models/product.dart';
import 'package:mobile_app/database/database_helper.dart';
import 'package:mobile_app/providers/auth_provider.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];
  AuthProvider? _authProvider;

  List<CartItem> get cartItems => _cartItems;

  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    final id = _authProvider?.currentUser?.id;
    if (id != null) {
      loadCartItems(id);
    } else {
      clearCart();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<void> loadCartItems(int userId) async {
    _cartItems.clear();
    final db = await DatabaseHelper().database;
    final cartMaps = await db.query(
      'cart',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Загружаем информацию о товарах
    for (var map in cartMaps) {
      final productMaps = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [map['product_id']],
      );

      if (productMaps.isNotEmpty) {
        _cartItems.add(
          CartItem(
            id: map['id'] as int?,
            userId: map['user_id'] as int,
            productId: map['product_id'] as int,
            quantity: map['quantity'] as int,
            product: Product.fromMap(productMaps.first),
          ),
        );
      }
    }

    notifyListeners();
  }

  Future<void> addToCart(Product product) async {
    try {
      if (_authProvider == null) return;
      final userId = _authProvider!.currentUser?.id;
      if (userId == null) return;

      final db = await DatabaseHelper().database;
      
      final existingCart = await db.query(
        'cart',
        where: 'user_id = ? AND product_id = ?',
        whereArgs: [userId, product.id],
      );

      if (existingCart.isNotEmpty) {
        final currentQuantity = existingCart.first['quantity'] as int;
        await db.update(
          'cart',
          {'quantity': currentQuantity + 1},
          where: 'id = ?',
          whereArgs: [existingCart.first['id']],
        );
      } else {
        await db.insert('cart', {
          'user_id': userId,
          'product_id': product.id,
          'quantity': 1,
        });
      }

      await loadCartItems(userId);
    } catch (e) {
      print('Ошибка добавления в корзину: $e');
    }
  }

  Future<void> removeFromCart(CartItem item) async {
    try {
      if (item.id == null) return;
      final db = await DatabaseHelper().database;
      await db.delete('cart', where: 'id = ?', whereArgs: [item.id]);
      _cartItems.removeWhere((cartItem) => cartItem.id == item.id);
      notifyListeners();
    } catch (e) {
      print('Ошибка удаления из корзины: $e');
    }
  }

  Future<void> clearAllCartItems() async {
    try {
      if (_authProvider == null) return;
      final userId = _authProvider!.currentUser?.id;
      if (userId == null) return;

      final db = await DatabaseHelper().database;
      await db.delete('cart', where: 'user_id = ?', whereArgs: [userId]);
      _cartItems.clear();
      notifyListeners();
    } catch (e) {
      print('Ошибка очистки корзины: $e');
    }
  }

  Future<void> updateQuantity(CartItem item, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(item);
        return;
      }

      final db = await DatabaseHelper().database;
      await db.update(
        'cart',
        {'quantity': newQuantity},
        where: 'id = ?',
        whereArgs: [item.id],
      );

      final index = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
      if (index != -1) {
        _cartItems[index].quantity = newQuantity;
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка обновления количества: $e');
    }
  }
}
