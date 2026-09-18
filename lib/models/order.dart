import '../core/constants.dart';
import 'user.dart';

enum OrderStatus {
  pending,
  approved,
  completed,
  cancelled;

  static OrderStatus fromString(String s) {
    switch (s.toUpperCase()) {
      case 'ACCEPTED': // treat legacy accepted as pending
      case 'PENDING':
        return OrderStatus.pending;
      case 'APPROVED':
        return OrderStatus.approved;
      case 'COMPLETED':
        return OrderStatus.completed;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String toApiString() => name.toUpperCase();

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.approved:
        return 'Approved';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class Order {
  final int id;
  final String service;
  final String item;
  final String date;
  final String time;
  final OrderStatus status;
  final double price;
  final String? receiptFile;
  final String? generatedReceiptPath;
  final bool discountApplied;
  final DateTime createdAt;
  // Customer
  final User? user;
  // Admin actors
  final User? approvedBy;
  final User? completedBy;

  // Convenience getters kept for backward compat
  String? get userFirstName => user?.firstName;
  String? get userLastName  => user?.lastName;
  String? get userEmail     => user?.email;
  String  get userName      => user?.fullName ?? '';

  const Order({
    required this.id,
    required this.service,
    required this.item,
    required this.date,
    required this.time,
    required this.status,
    required this.price,
    this.receiptFile,
    this.generatedReceiptPath,
    required this.discountApplied,
    required this.createdAt,
    this.user,
    this.approvedBy,
    this.completedBy,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // price arrives as a String e.g. "3000.00" from the backend
    final rawPrice = json['price'];
    final price = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0;

    User? _parseUser(dynamic raw) {
      if (raw is Map<String, dynamic>) return User.fromJson(raw);
      return null;
    }

    return Order(
      id: (json['id'] is num)
          ? (json['id'] as num).toInt()
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      service: json['service'] as String? ?? '',
      item: json['item'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      status: OrderStatus.fromString(json['status'] as String? ?? 'PENDING'),
      price: price,
      receiptFile: json['receiptFile'] as String?,
      generatedReceiptPath: json['generatedReceiptPath'] as String?,
      discountApplied: json['discountApplied'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      user: _parseUser(json['user']),
      approvedBy: _parseUser(json['approvedBy']),
      completedBy: _parseUser(json['completedBy']),
    );
  }

  String? get receiptUrl {
    if (receiptFile == null) return null;
    final path = receiptFile!.replaceAll('\\', '/');
    return '${AppConstants.baseUrl}/$path';
  }
}
