import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Models/ChatComment.dart';
import '../Models/Seafood.dart';
import '../Models/CartItem.dart';
import '../Models/User.dart';
import '../Provider/AuthProvider.dart';
import '../Provider/CartProvider.dart';
import '../constants.dart';

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
  final TextEditingController _commentController = TextEditingController();

  Future<List<ChatComment>> fetchComments(int seafoodId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/comment/$seafoodId'));

      if (response.statusCode == 200) {
        List commentsJson = json.decode(response.body);
        return commentsJson.map((json) => ChatComment.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load comments. Server returned ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load comments. $e');
    }
  }

  Future<void> submitComment(int seafoodId) async {
    final String commentContent = _commentController.text.trim();
    User? currentUser =
        Provider.of<AuthProvider>(context, listen: false).currentUser;

    if (commentContent.isNotEmpty) {
      final Map<String, dynamic> commentData = {
        'content': commentContent,
        'userId': currentUser!.id,
      };

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/comment/$seafoodId/add'),
          body: jsonEncode(commentData),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 201) {
          setState(() {
            _commentController.clear();
          });
        } else {
          throw Exception(
              'Failed to submit comment. Server returned ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Failed to submit comment. $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
                  const SizedBox(height: 26),
                  FutureBuilder<List<ChatComment>>(
                    future: fetchComments(widget.seafood.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading comments: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bình luận:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildCommentsList(snapshot.data!),
                            if(authProvider.isAuthenticated)
                            _buildCommentInput(widget.seafood.id),
                          ],
                        );
                      }
                    },
                  ),
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
        borderRadius: BorderRadius.circular(12.0),
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
        const SizedBox(height: 12),
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
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildQuantitySelector(),
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
        Container(
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

  Widget _buildCommentsList(List<ChatComment> comments) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        comments[index].userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm')
                            .format(comments[index].createAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    comments[index].content,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentInput(int seafoodId) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () => submitComment(seafoodId),
            child: const Text('Submit'),
          ),
        ],
      ),
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
