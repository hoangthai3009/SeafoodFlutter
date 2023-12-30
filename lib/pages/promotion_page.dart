import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:seafood_mobile_app/constants.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import '../Models/Promotion.dart';

class PromotionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã giảm giá'),
      ),
      body: FutureBuilder<List<Promotion>>(
        future: _fetchPromotions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Hiện tại không có mã giảm giá'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      snapshot.data![index].name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8.0),
                        Text(
                          'Giảm giá: ${snapshot.data![index].discount * 100}%',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Số lượng: ${snapshot.data![index].quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'HSD: ${DateFormat('dd-MM-yyyy').format(snapshot.data![index].expiredDay)}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        await Clipboard.setData(
                            ClipboardData(text: snapshot.data![index].code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã sao chép mã giảm giá'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                      ),
                      child: const Text('Lấy mã'),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Promotion>> _fetchPromotions() async {
    final String apiUrl = '$baseUrl/api/promotions';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Promotion> promotions =
          data.map((item) => Promotion.fromJson(item)).toList();
      return promotions;
    } else {
      throw Exception('Failed to load promotions');
    }
  }
}
