class Product {
  int? id;
  int categoryId;
  int? supplierId;
  String name;
  String description;
  double price;
  double? originalPrice;
  double rating;
  int reviewCount;
  String? imageUrl;
  int stockQuantity;
  String? specifications;
  String? brand;
  String? warranty;
  String? color;
  String? dimensions;
  String? weight;
  bool isNew;
  bool isPopular;
  double? discount;

  Product({
    this.id,
    required this.categoryId,
    this.supplierId,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    this.rating = 0,
    this.reviewCount = 0,
    this.imageUrl,
    this.stockQuantity = 0,
    this.specifications,
    this.brand,
    this.warranty,
    this.color,
    this.dimensions,
    this.weight,
    this.isNew = false,
    this.isPopular = false,
    this.discount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'supplier_id': supplierId,
      'name': name,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'rating': rating,
      'review_count': reviewCount,
      'image_url': imageUrl,
      'stock_quantity': stockQuantity,
      'specifications': specifications,
      'brand': brand,
      'warranty': warranty,
      'color': color,
      'dimensions': dimensions,
      'weight': weight,
      'is_new': isNew ? 1 : 0,
      'is_popular': isPopular ? 1 : 0,
      'discount': discount,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      categoryId: map['category_id'],
      supplierId: map['supplier_id'],
      name: map['name'],
      description: map['description'],
      price: map['price']?.toDouble() ?? 0.0,
      originalPrice: map['original_price']?.toDouble(),
      rating: map['rating']?.toDouble() ?? 0.0,
      reviewCount: map['review_count'] ?? 0,
      imageUrl: map['image_url'],
      stockQuantity: map['stock_quantity'] ?? 0,
      specifications: map['specifications'],
      brand: map['brand'],
      warranty: map['warranty'],
      color: map['color'],
      dimensions: map['dimensions'],
      weight: map['weight'],
      isNew: (map['is_new'] ?? 0) == 1,
      isPopular: (map['is_popular'] ?? 0) == 1,
      discount: map['discount']?.toDouble(),
    );
  }

  double get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }
}
