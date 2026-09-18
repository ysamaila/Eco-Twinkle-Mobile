class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? whatsappNumber;
  final String role;
  final String status;
  final int points;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.whatsappNumber,
    required this.role,
    required this.status,
    required this.points,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';
  bool get isAdmin => role == 'ADMIN' || role == 'SUPPORT';
  bool get isActive => status == 'ACTIVE';
  bool get hasLoyaltyDiscount => points >= 100;

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper: parse int from num or String safely
    int parseInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '0') ?? 0;

    return User(
      id: parseInt(json['id']),
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      whatsappNumber: json['whatsappNumber'] as String?,
      role: json['role'] as String? ?? 'CUSTOMER',
      status: json['status'] as String? ?? 'ACTIVE',
      points: parseInt(json['points']),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'whatsappNumber': whatsappNumber,
        'role': role,
        'status': status,
        'points': points,
        'createdAt': createdAt.toIso8601String(),
      };

  User copyWith({
    String? firstName,
    String? lastName,
    String? whatsappNumber,
    int? points,
    String? status,
  }) =>
      User(
        id: id,
        email: email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        whatsappNumber: whatsappNumber ?? this.whatsappNumber,
        role: role,
        status: status ?? this.status,
        points: points ?? this.points,
        createdAt: createdAt,
      );
}
