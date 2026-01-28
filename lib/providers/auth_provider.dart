import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_app/models/user.dart';
import 'package:mobile_app/database/database_helper.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> register(User user) async {
    try {
      final db = await DatabaseHelper().database;
      final newId = await db.insert('users', user.toMap());
      _currentUser = User(
        id: newId,
        username: user.username,
        email: user.email,
        password: user.password,
        fullName: user.fullName,
        phone: user.phone,
        address: user.address,
      );
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Ошибка регистрации: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final db = await DatabaseHelper().database;
      final users = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (users.isNotEmpty) {
        _currentUser = User.fromMap(users.first);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Ошибка входа: $e');
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
