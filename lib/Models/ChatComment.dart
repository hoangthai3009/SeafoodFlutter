class ChatComment {
  final int id;
  final String content;
  final DateTime createAt;
  final int seafoodId;
  final String userName;

  ChatComment({
    required this.id,
    required this.content,
    required this.createAt,
    required this.seafoodId,
    required this.userName,
  });
  factory ChatComment.fromJson(Map<String, dynamic> json) {
    return ChatComment(
      id: json['commentId'],
      content: json['content'],
      createAt: DateTime.parse(json['createdAt']),
      seafoodId: json['seafood']['id'],
      userName: json['user']['username'],
    );
  }
}
