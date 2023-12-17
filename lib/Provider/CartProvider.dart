import 'package:flutter/material.dart';

import '../Models/CartItem.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cart = [];

  List<CartItem> get cart => _cart;

  void addToCart(CartItem cartItem) {
    int existingIndex =
        _cart.indexWhere((item) => item.seafoodId == cartItem.seafoodId);

    if (existingIndex != -1) {
      _cart[existingIndex].quantity += cartItem.quantity;
    } else {
      _cart.add(cartItem);
    }

    notifyListeners();
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
      notifyListeners();
    }
  }

  void removeCartItem(CartItem item) {
    _cart.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
