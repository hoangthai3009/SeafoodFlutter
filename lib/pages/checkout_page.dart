import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seafood_mobile_app/constants.dart';
import '../Models/CartItem.dart';
import '../Provider/AuthProvider.dart';
import '../Provider/CartProvider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CheckoutPage extends StatelessWidget {
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  Widget build(BuildContext context) {
    List<CartItem> cartItems = Provider.of<CartProvider>(context).cart;
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    double totalPrice =
        cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

    final requestData = {
      "totalPrice": totalPrice,
      "note": "Updated note",
      "address": "Updated address",
      "userId": authProvider.currentUser?.id,
      "billDetails": cartItems.map((item) {
        return {
          "seafood": {"id": item.seafoodId},
          "quantity": item.quantity,
          "price": item.price,
        };
      }).toList(),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: cartItems.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return _buildCartItem(context, cartItems[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng cộng: ${currencyFormat.format(totalPrice)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _sendCheckoutRequest(requestData, context);
                  },
                  child: const Text('Thanh toán'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem cartItem) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Image.network(
          cartItem.image,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cartItem.seafoodName,
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Số lượng:',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(width: 4.0),
            Text(
              cartItem.quantity.toString(),
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(width: 4.0),
            Text(
              cartItem.unit,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        trailing: Text(
          currencyFormat.format(cartItem.price),
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Future<void> _sendCheckoutRequest(
      Map<String, dynamic> requestData, BuildContext context) async {
    final url = Uri.parse('$baseUrl/api/checkout');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/main');
        Provider.of<CartProvider>(context, listen: false).clearCart();
      } else {
        print('Error during checkout. Status code: ${response.statusCode}');
        print('Error message: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
