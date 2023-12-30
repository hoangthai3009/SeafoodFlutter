class User {
  final int id;
  final String fullname;
  final String username;
  final String email;
  final String? address;
  final String phone;
  final String? avatarUrl;

  User({
    required this.id,
    required this.fullname,
    required this.username,
    required this.email,
    this.address,
    required this.phone,
    this.avatarUrl,
  });
}
