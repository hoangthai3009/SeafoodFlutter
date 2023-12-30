class BillDetail {
  final int seafoodId;
  final String seafoodNane;
  final String categoryName;
  final double price;
  final int quantity;

  BillDetail({
    required this.seafoodId,
    required this.price,
    required this.quantity,
    required this.seafoodNane,
    required this.categoryName,
  });

  factory BillDetail.fromJson(Map<String, dynamic> json) {
    return BillDetail(
      seafoodId: json['id']['seafoodId'],
      seafoodNane: json['seafood']['name'],
      categoryName: json['seafood']['category']['name'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }
}
