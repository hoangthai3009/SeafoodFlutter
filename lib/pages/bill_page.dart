import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seafood_mobile_app/constants.dart';
import 'dart:convert';
import '../Models/Bill.dart';
import '../Provider/AuthProvider.dart';
import 'bill_detail_page.dart';

class BillPage extends StatelessWidget {
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng'),
      ),
      body: FutureBuilder<List<Bill>>(
        future: _fetchBill(authProvider.currentUser!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Hiện tại không có đơn hàng'));
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Địa chỉ')),
                  DataColumn(label: Text('Tổng tiền')),
                  DataColumn(label: Text('Khuyến mãi')),
                  DataColumn(label: Text('Tổng phải trả')),
                  DataColumn(label: Text('Phương thức thanh toán')),
                  DataColumn(label: Text('Phần trăm cọc')),
                  DataColumn(label: Text('Tiền đã trả')),
                  DataColumn(label: Text('Ngày thanh toán')),
                  DataColumn(label: Text('')),
                ],
                rows: snapshot.data!
                    .map(
                      (bill) => DataRow(cells: [
                        DataCell(Text(bill.address)),
                        DataCell(
                            Text(currencyFormat.format(bill.totalPrice))),
                        DataCell(Text('${bill.discount} %')),
                        DataCell(
                            Text(currencyFormat.format(bill.totalPay))),
                        DataCell(Text(bill.paymentMethod)),
                        DataCell(Text('${(bill.paidPercentage*100).toInt()} %')),
                        DataCell(
                            Text(currencyFormat.format(bill.totalPaid))),
                        DataCell(Text('${bill.createAt}')),
                        DataCell(
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BillDetailsPage(
                                        billId: bill.id)),
                              );
                            },
                            child: const Text('Chi tiết'),
                          ),
                        ),
                      ]),
                    )
                    .toList(),
              ),
            );
          }
        },
      ),
    );
  }

  Future<List<Bill>> _fetchBill(int userId) async {
    final String apiUrl = '$baseUrl/api/userOrder/$userId';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Bill> bills = data.map((item) => Bill.fromJson(item)).toList();
      return bills;
    } else {
      throw Exception('Failed to load Bills');
    }
  }
}
