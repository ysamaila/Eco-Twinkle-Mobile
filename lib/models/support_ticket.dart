class SupportTicket {
  final int id;
  final int userId;
  final String content;
  final String? response;
  final int? respondedById;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.content,
    this.response,
    this.respondedById,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['userId'] is int
          ? json['userId']
          : int.parse(json['userId'].toString()),
      content: json['content'] as String,
      response: json['response'] as String?,
      respondedById: json['respondedById'] != null
          ? (json['respondedById'] is int
              ? json['respondedById']
              : int.tryParse(json['respondedById'].toString()))
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'response': response,
      'respondedById': respondedById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
