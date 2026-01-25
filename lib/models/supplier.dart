class Supplier {
  int? id;
  String name;
  String? description;
  String? phone;
  String? email;
  String? address;
  double? rating;
  int? totalProducts;

  Supplier({
    this.id,
    required this.name,
    this.description,
    this.phone,
    this.email,
    this.address,
    this.rating,
    this.totalProducts,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'phone': phone,
      'email': email,
      'address': address,
      'rating': rating,
      'total_products': totalProducts,
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      rating: map['rating']?.toDouble(),
      totalProducts: map['total_products'],
    );
  }
}
