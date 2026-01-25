import 'package:mobile_app/models/product.dart';

class CartItem {
  int? id;
  int userId;
  int productId;
  int quantity;
  Product? product;

  CartItem({
    this.id,
    required this.userId,
    required this.productId,
    this.quantity = 1,
    this.product,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      userId: map['user_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
    );
  }
}
