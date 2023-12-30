class Promotion {
  final String code;
  final int quantity;
  final String name;
  final String description;
  final double discount;
  final DateTime expiredDay;

  Promotion({
    required this.code,
    required this.quantity,
    required this.name,
    required this.description,
    required this.discount,
    required this.expiredDay,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      code: json['code'],
      quantity: json['quantity'],
      name: json['name'],
      description: json['description'],
      discount: json['discount'],
      expiredDay: DateTime.parse(json['expired_day']),
    );
  }
}