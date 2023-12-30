import 'package:flutter/material.dart';
import '../Models/CartItem.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cart = [];
  String _code = '';
  double _discount = 0;
  double _totalPrice = 0;
  double _totalPay = 0;
  double _totalPaid = 0;

  List<CartItem> get cart => _cart;
  String get code => _code;
  double get discount => _discount;
  double get totalPrice => _totalPrice;
  double get totalPay => _totalPay;
  double get totalPaid => _totalPaid;

  void addToCart(CartItem cartItem) {
    int existingIndex =
        _cart.indexWhere((item) => item.seafoodId == cartItem.seafoodId);

    if (existingIndex != -1) {
      _cart[existingIndex].quantity += cartItem.quantity;
    } else {
      _cart.add(cartItem);
    }

    _updateCartValues();
  }

  void updateQuantity(CartItem cartItem, int change) {
    int index = _cart.indexOf(cartItem);
    if (index != -1) {
      _cart[index].quantity += change;
      if (_cart[index].quantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].totalPrice = _cart[index].price * _cart[index].quantity;
      }
      _updateCartValues();
    }
  }

  void removeCartItem(CartItem item) {
    _cart.remove(item);
    _updateCartValues();
  }

  void clearCart() {
    _cart.clear();
    _updateCartValues();
  }

  void clearAllData() {
    _cart.clear();
    _code = '';
    _discount = 0;
    _totalPrice = 0;
    _totalPay = 0;
    notifyListeners();
  }

  void setCode(String code) {
    _code = code;
    notifyListeners();
  }

  void setDiscount(double discount) {
    _discount = discount;
    notifyListeners();
  }

  void setTotalPrice(double totalPrice) {
    _totalPrice = totalPrice;
    notifyListeners();
  }

  void setTotalPay(double totalPay) {
    _totalPay = totalPay;
    notifyListeners();
  }

  void setTotalPaid(double totalPaid) {
    _totalPaid = totalPaid;
    notifyListeners();
  }

  void _updateCartValues() {
    _totalPrice =
        _cart.fold(0, (sum, item) => sum + item.price * item.quantity);
    _totalPay = _calculateTotalPay();
    notifyListeners();
  }

  double _calculateTotalPay() {
    return _totalPrice * (1 - _discount);
  }
}
