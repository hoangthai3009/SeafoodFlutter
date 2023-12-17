import 'package:seafood_mobile_app/Models/Category.dart';

class Seafood {
  final int id;
  final String name;
  final String origin;
  final String description;
  final double price;
  final String mainImage;
  final String extraImage1;
  final String extraImage2;
  final String extraImage3;
  final int quantity;
  final DateTime manufacturingDate;
  final String unit;
  final Category category;

  Seafood({
    required this.id,
    required this.name,
    required this.origin,
    required this.description,
    required this.price,
    required this.mainImage,
    required this.extraImage1,
    required this.extraImage2,
    required this.extraImage3,
    required this.quantity,
    required this.manufacturingDate,
    required this.unit,
    required this.category,
  });

  factory Seafood.fromJson(Map<String, dynamic> json) {
    return Seafood(
      id: json['id'],
      name: json['name'],
      origin: json['origin'],
      description: json['description'],
      price: json['price'].toDouble(),
      mainImage: json['mainImage'],
      extraImage1: json['extraImage1'],
      extraImage2: json['extraImage2'],
      extraImage3: json['extraImage3'],
      quantity: json['quantity'],
      manufacturingDate: DateTime.parse(json['manufacturing_date']),
      unit: json['unit'],
      category: Category.fromJson(json['category']),
    );
  }
}
