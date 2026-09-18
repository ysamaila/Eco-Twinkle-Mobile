class LeaderboardEntry {
  final int userId;
  final String firstName;
  final String lastName;
  final int count;

  const LeaderboardEntry({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.count,
  });

  String get fullName => '$firstName $lastName';

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as int? ?? 0,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'count': count,
      };
}
