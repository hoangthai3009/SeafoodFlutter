class Bill {
  final int id;
  final double totalPrice;
  final double totalPay;
  final double totalPaid;
  final double paidPercentage;
  final double discount;
  final String paymentMethod;
  final String note;
  final String address;
  final DateTime createAt;

  Bill(
      {required this.id,
      required this.totalPrice,
      required this.totalPay,
      required this.totalPaid,
      required this.paidPercentage,
      required this.paymentMethod,
      required this.discount,
      required this.note,
      required this.address,
      required this.createAt});

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      totalPrice: json['totalPrice'],
      totalPay: json['totalPay'],
      discount: json['discount'],
      totalPaid: json['totalPaid'],
      paymentMethod: json['paymentMethod'],
      paidPercentage: json['paidPercentage'],
      note: json['note'],
      address: json['address'],
      createAt: DateTime.parse(json['createdAt']),
    );
  }
}
