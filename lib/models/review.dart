class Review {
  int? id;
  int productId;
  int userId;
  String userName;
  double rating;
  String comment;
  String? createdAt;

  Review({
    this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      productId: map['product_id'],
      userId: map['user_id'],
      userName: map['user_name'],
      rating: map['rating']?.toDouble() ?? 0.0,
      comment: map['comment'],
      createdAt: map['created_at'],
    );
  }
}
