class CartItem {
  final int seafoodId;
  final String seafoodName;
  final double price;
  final String image;
  final String unit;
  final String categoryName;
  int quantity;
  double totalPrice;

  CartItem({
    required this.seafoodId,
    required this.seafoodName,
    required this.price,
    required this.image,
    required this.unit,
    required this.categoryName,
    required this.quantity,
  }) : totalPrice = price * quantity;
}
