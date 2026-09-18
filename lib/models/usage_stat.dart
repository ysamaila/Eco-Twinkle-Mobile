class UsageStat {
  final String month;
  final int count;

  const UsageStat({
    required this.month,
    required this.count,
  });

  factory UsageStat.fromJson(Map<String, dynamic> json) {
    return UsageStat(
      month: json['month'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'count': count,
      };
}
