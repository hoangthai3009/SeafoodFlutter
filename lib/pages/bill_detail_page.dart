import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../Models/BillDetail.dart';
import '../constants.dart';

class BillDetailsPage extends StatelessWidget {
  final int billId;

  const BillDetailsPage({Key? key, required this.billId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn #$billId'),
      ),
      body: FutureBuilder<List<BillDetail>>(
        future: fetchBillDetails(billId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No bill details available'),
            );
          }

          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              var billDetail = snapshot.data![index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    billDetail.seafoodNane,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Số lượng: ${billDetail.quantity}'),
                      Text('Giá: ${currencyFormat.format(billDetail.price)}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<BillDetail>> fetchBillDetails(int billId) async {
    final url = '$baseUrl/api/userOrderDetail/$billId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = jsonDecode(responseBody);
      return data.map((json) => BillDetail.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bill details');
    }
  }
}
