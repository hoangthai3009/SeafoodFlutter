import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Models/Seafood.dart';
import '../Models/CartItem.dart';
import '../Provider/CartProvider.dart';

class SeafoodDetailPage extends StatefulWidget {
  final Seafood seafood;

  SeafoodDetailPage({required this.seafood});

  @override
  _SeafoodDetailPageState createState() => _SeafoodDetailPageState();
}

class _SeafoodDetailPageState extends State<SeafoodDetailPage> {
  int _quantity = 1;
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.seafood.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainImage(),
                  const SizedBox(height: 16),
                  _buildSeafoodInfo(),
                  const SizedBox(height: 16),
                  const Text(
                    'Ảnh khác:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildExtraImages(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildMainImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(widget.seafood.mainImage),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildSeafoodInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.seafood.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Giá: ${currencyFormat.format(widget.seafood.price)}',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Mô tả:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.seafood.description,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildExtraImages() {
    return Row(
      children: [
        _buildExtraImage(widget.seafood.extraImage1),
        const SizedBox(width: 8),
        _buildExtraImage(widget.seafood.extraImage2),
        const SizedBox(width: 8),
        _buildExtraImage(widget.seafood.extraImage3),
      ],
    );
  }

  Widget _buildExtraImage(String imageUrl) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildQuantitySelector(),
          Text(widget.seafood.unit),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              _addToCart(context);
            },
            child: const Text('Thêm vào giỏ hàng'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            if (_quantity > 1) {
              setState(() {
                _quantity--;
              });
            }
          },
        ),
        SizedBox(
          width: 40,
          child: TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: '$_quantity'),
            onChanged: (newValue) {
              if (newValue.isNotEmpty) {
                setState(() {
                  _quantity = int.parse(newValue);
                });
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              _quantity++;
            });
          },
        ),
      ],
    );
  }

  void _addToCart(BuildContext context) {
    CartItem cartItem = CartItem(
      seafoodId: widget.seafood.id,
      seafoodName: widget.seafood.name,
      price: widget.seafood.price,
      image: widget.seafood.mainImage,
      unit: widget.seafood.unit,
      categoryName: widget.seafood.category.name,
      quantity: _quantity,
    );

    Provider.of<CartProvider>(context, listen: false).addToCart(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.seafood.name} đã được thêm vào giỏ hàng.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
