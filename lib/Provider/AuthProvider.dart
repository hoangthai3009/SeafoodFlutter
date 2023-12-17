import 'package:flutter/material.dart';
import '../Models/User.dart';

class AuthProvider with ChangeNotifier {
  bool _authenticated = false;
  User? _currentUser;

  bool get isAuthenticated => _authenticated;
  User? get currentUser => _currentUser;

  void setAuthenticated(bool value) {
    _authenticated = value;
    notifyListeners();
  }

  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }
}
