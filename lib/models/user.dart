class User {
  int? id;
  String username;
  String email;
  String password;
  String? fullName;
  String? phone;
  String? address;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.fullName,
    this.phone,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone': phone,
      'address': address,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      fullName: map['full_name'],
      phone: map['phone'],
      address: map['address'],
    );
  }
}
