import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Models/CartItem.dart';
import '../Provider/AuthProvider.dart';
import '../Provider/CartProvider.dart';

class CartPage extends StatelessWidget {
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  Widget build(BuildContext context) {
    List<CartItem> cartItems = Provider.of<CartProvider>(context).cart;
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    double totalPrice =
        cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Giỏ hàng'),
        ),
        body: const Padding(
          padding: EdgeInsets.all(50),
          child: Text(
            'Giỏ hàng của bạn đang trống. Hãy thêm sản phẩm vào giỏ hàng!',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: cartItems.length,
              separatorBuilder: (context, index) => Divider(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem cartItem) {
    TextEditingController quantityController =
        TextEditingController(text: cartItem.quantity.toString());

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
            Text(
              'Giá: ${currencyFormat.format(cartItem.price)}',
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            Text(
              'Tổng: ${currencyFormat.format(cartItem.totalPrice)}',
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                _updateQuantity(context, cartItem, -1);
              },
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
              onTap: () {
                _updateQuantity(context, cartItem, 1);
              },
              child: const Icon(Icons.add),
            ),
            Text(
              cartItem.unit,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        trailing: GestureDetector(
          onTap: () {
            _removeCartItem(context, cartItem);
          },
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
}
