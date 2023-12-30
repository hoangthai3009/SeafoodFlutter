import 'package:flutter/material.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/CartItem.dart';
import '../Provider/AuthProvider.dart';
import '../Provider/CartProvider.dart';
import 'package:seafood_mobile_app/constants.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedPaymentMethod = 'COD';
  double selectedValue = 1;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  Widget build(BuildContext context) {
    CartProvider cartProvider = Provider.of<CartProvider>(context);
    List<CartItem> cartItems = cartProvider.cart;
    AuthProvider authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length + 1,
              itemBuilder: (context, index) {
                if (index < cartItems.length) {
                  return _buildCartItem(context, cartItems[index]);
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _inputAddress(context, _addressController),
                        const SizedBox(width: 16.0),
                        IconButton(
                          icon: const Icon(Icons.note_add),
                          onPressed: () {
                            _showNoteModal(context, _noteController);
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          _checkoutBar(context, cartProvider, authProvider),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem cartItem) {
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
          ],
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Số lượng:',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
            const SizedBox(width: 4.0),
            Text(
              '${cartItem.quantity} ${cartItem.unit}',
              style: const TextStyle(
                fontSize: 14.0,
              ),
            ),
          ],
        ),
        trailing: Text(
          currencyFormat.format(cartItem.totalPrice),
          style: const TextStyle(
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  Widget _inputAddress(BuildContext context, TextEditingController controller) {
    return Expanded(
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: "Địa chỉ giao",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _showNoteModal(BuildContext context, TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thêm ghi chú:'),
              const SizedBox(height: 8.0),
              TextField(
                maxLines: null,
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Lưu ghi chú'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _checkoutBar(BuildContext context, CartProvider cartProvider,
      AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Phương thức thanh toán: ',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              DropdownButton<String>(
                value: selectedPaymentMethod,
                items: <String>['COD', 'PayPal']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPaymentMethod = newValue!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 4.0),
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
            'Tổng cộng: ${currencyFormat.format(cartProvider.totalPay)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_addressController.text.isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Lỗi'),
                      content: const Text('Vui lòng nhập địa chỉ.'),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                if (selectedPaymentMethod == 'COD') {
                  selectedValue = 0;
                  cartProvider
                      .setTotalPaid(cartProvider.totalPay * selectedValue);
                  _sendCheckoutRequest(context, cartProvider, authProvider);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title:
                            const Text('Bạn muốn thanh toán trước bao nhiêu?'),
                        content: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return DropdownButton<double>(
                            value: selectedValue,
                            items: <double>[0.5, 0.7, 1]
                                .map<DropdownMenuItem<double>>((double value) {
                              return DropdownMenuItem<double>(
                                value: value,
                                child: Text('${(value * 100).toInt()}%'),
                              );
                            }).toList(),
                            onChanged: (double? newValue) {
                              setState(() {
                                selectedValue = newValue!;
                                cartProvider.setTotalPaid(
                                    cartProvider.totalPay * selectedValue);
                              });
                            },
                          );
                        }),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    PaypalCheckout(
                                  sandboxMode: true,
                                  clientId:
                                      "AauH8esyIJU865PwyxnygvrbjjF7NGw9pBbEi9vjjnAc-_hyiio5_hjw4_WJDACrI3i1vUbOf0otvSmv",
                                  secretKey:
                                      "EBlg7frWEhrVohJxX2eUJWmsDmQevEFsH6dBvugLO27Dr1z9l10XcFVxiOu-WZAVF6d7LD8GHkCtGO2D",
                                  returnURL: "success.snippetcoder.com",
                                  cancelURL: "cancel.snippetcoder.com",
                                  transactions: [
                                    {
                                      "amount": {
                                        "total": cartProvider.totalPaid,
                                        "currency": "USD",
                                        "details": {
                                          "subtotal": cartProvider.totalPaid,
                                          "shipping": '0',
                                          "shipping_discount": 0,
                                        }
                                      },
                                    },
                                  ],
                                  note:
                                      "Contact us for any questions on your order.",
                                  onSuccess: (Map params) async {
                                    _sendCheckoutRequest(
                                        context, cartProvider, authProvider);
                                  },
                                  onError: (error) {
                                    print("onError: $error");
                                    Navigator.pop(context);
                                  },
                                  onCancel: () {
                                    print('cancelled:');
                                  },
                                ),
                              ));
                            },
                            child: const Text('Đồng ý'),
                          ),
                        ],
                      );
                    },
                  );
                }
              }
            },
            child: const Text('Thanh toán'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendCheckoutRequest(BuildContext context,
      CartProvider cartProvider, AuthProvider authProvider) async {
    final url = Uri.parse('$baseUrl/api/checkout');

    final requestData = {
      "totalPrice": cartProvider.totalPrice,
      "discount": cartProvider.discount,
      "totalPay": cartProvider.totalPay,
      "totalPaid": cartProvider.totalPaid,
      "paidPercentage": selectedValue,
      "paymentMethod": selectedPaymentMethod,
      "note": "Updated note",
      "address": _addressController.text,
      "userId": authProvider.currentUser?.id,
      "billDetails": cartProvider.cart.map((item) {
        return {
          "seafood": {"id": item.seafoodId},
          "quantity": item.quantity,
          "price": item.price,
        };
      }).toList(),
    };
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        Provider.of<CartProvider>(context, listen: false).clearAllData();
        Navigator.pushReplacementNamed(context, '/success');
      } else {
        print('Error during checkout. Status code: ${response.statusCode}');
        print('Error message: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
