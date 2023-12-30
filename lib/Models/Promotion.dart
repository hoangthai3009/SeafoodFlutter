class Promotion {
  final String code;
  final int quantity;
  final String name;
  final String description;
  final double discount;

  Promotion({
    required this.code,
    required this.quantity,
    required this.name,
    required this.description,
    required this.discount,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      code: json['code'],
      quantity: json['quantity'],
      name: json['name'],
      description: json['description'],
      discount: json['discount'],
    );
  }
}