class Category {
  final int id;
  final String name;
  final String img;

  Category({
    required this.id,
    required this.name,
    required this.img,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      img: json['img'],
    );
  }
}