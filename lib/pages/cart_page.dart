import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../Models/CartItem.dart';
import '../Provider/AuthProvider.dart';
import '../Provider/CartProvider.dart';
import '../constants.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final TextEditingController _promotionCodeController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    CartProvider cartProvider = Provider.of<CartProvider>(context);
    List<CartItem> cartItems = cartProvider.cart;
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    _promotionCodeController.text = cartProvider.code;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
      ),
      body: _buildCartBody(context, cartItems, authProvider, cartProvider),
    );
  }

  Widget _buildCartBody(BuildContext context, List<CartItem> cartItems,
      AuthProvider authProvider, CartProvider cartProvider) {
    if (cartItems.isEmpty) {
      return _buildEmptyCart();
    }

    return Column(
      children: [
        Expanded(
          child: _buildCartItemList(context, cartItems),
        ),
        _buildCartSummary(context, authProvider, cartProvider),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(50),
        child: Text(
          'Giỏ hàng của bạn đang trống. Hãy thêm sản phẩm vào giỏ hàng!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildCartItemList(BuildContext context, List<CartItem> cartItems) {
    return ListView.separated(
      itemCount: cartItems.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return _buildCartItem(context, cartItems[index]);
      },
    );
  }

  Widget _buildCartSummary(BuildContext context, AuthProvider authProvider,
      CartProvider cartProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _promotionCodeController,
            onChanged: (value) {
              _findPromotion(value, cartProvider);
              cartProvider.setCode(value);
            },
            decoration: const InputDecoration(
              labelText: 'Mã giảm giá',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Tổng: ${currencyFormat.format(cartProvider.totalPrice)}',
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 8.0),
          if (cartProvider.discount != 0)
            Text(
              'Tổng giảm giá: ${currencyFormat.format(cartProvider.totalPrice * cartProvider.discount)} (${cartProvider.discount * 100} %)',
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
          const SizedBox(height: 8.0),
          Text(
            'Tổng tiền: ${currencyFormat.format(cartProvider.totalPay)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (authProvider.isAuthenticated) {
                Navigator.pushNamed(context, '/checkout');
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
            child: const Text('Thanh toán'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem cartItem) {
    TextEditingController quantityController =
        TextEditingController(text: cartItem.quantity.toString());

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8.0),
        leading: SizedBox(
          width: 80,
          height: 80,
          child: Image.network(
            cartItem.image,
            fit: BoxFit.cover,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cartItem.seafoodName,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Giá: ${currencyFormat.format(cartItem.price)}',
              style: const TextStyle(
                fontSize: 14.0,
              ),
            ),
            Text(
              'Tổng: ${currencyFormat.format(cartItem.totalPrice)}',
              style: const TextStyle(
                fontSize: 14.0,
              ),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _updateQuantity(context, cartItem, -1),
              child: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 30.0,
              child: TextFormField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                controller: quantityController,
                onEditingComplete: () {
                  int newQuantity = int.tryParse(quantityController.text) ??
                      cartItem.quantity;
                  int change = newQuantity - cartItem.quantity;

                  _updateQuantity(context, cartItem, change);
                },
              ),
            ),
            GestureDetector(
              onTap: () => _updateQuantity(context, cartItem, 1),
              child: const Icon(Icons.add),
            ),
            Text(
              cartItem.unit,
              style: const TextStyle(
                fontSize: 14.0,
              ),
            ),
          ],
        ),
        trailing: GestureDetector(
          onTap: () => _removeCartItem(context, cartItem),
          child: const Icon(Icons.delete),
        ),
      ),
    );
  }

  void _updateQuantity(BuildContext context, CartItem cartItem, int change) {
    Provider.of<CartProvider>(context, listen: false)
        .updateQuantity(cartItem, change);
  }

  void _removeCartItem(BuildContext context, CartItem cartItem) {
    Provider.of<CartProvider>(context, listen: false).removeCartItem(cartItem);
  }

  Future<void> _findPromotion(String code, CartProvider cartProvider) async {
    final url = Uri.parse('$baseUrl/api/promotions/find?code=$code');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> data = json.decode(responseBody);
        cartProvider.setDiscount(data['discount']); // Use CartProvider
        cartProvider.setTotalPay(_calculateTotalPay(cartProvider));

        print(response.body);
      } else {
        cartProvider.setDiscount(0); // Use CartProvider
        cartProvider.setTotalPay(_calculateTotalPay(cartProvider));
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  double _calculateTotalPay(CartProvider cartProvider) {
    return cartProvider.totalPrice * (1 - cartProvider.discount);
  }
}
