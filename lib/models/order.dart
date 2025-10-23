import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending('pending', 'Ожидание', 0),
  accepted('accepted', 'Принят', 1),
  inProgress('in_progress', 'В работе', 2),
  completed('completed', 'Выполнен', 3),
  cancelled('cancelled', 'Отменен', 4);

  const OrderStatus(this.value, this.displayName, this.priority);
  final String value;
  final String displayName;
  final int priority;

  static OrderStatus fromValue(String value) {
    return OrderStatus.values.firstWhere(
          (status) => status.value == value,
      orElse: () => throw ArgumentError('Неизвестный статус заказа: $value'),
    );
  }
}

class Order extends Equatable {
  final String? id;
  final String? userId;
  final String? addressId;
  final DateTime orderDate;
  final DateTime pickupTime;
  final int bagCount;
  final double totalPrice;
  final OrderStatus status;
  final String? comment;
  final String? promoCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    this.id,
    this.userId,
    this.addressId,
    required this.orderDate,
    required this.pickupTime,
    required this.bagCount,
    required this.totalPrice,
    required this.status,
    this.comment,
    this.promoCode,
    this.createdAt,
    this.updatedAt,
  }) {
    if (bagCount <= 0) throw ArgumentError('Количество мешков должно быть больше 0');
    if (totalPrice < 0) throw ArgumentError('Стоимость не может быть отрицательной');
    if (!pickupTime.isAfter(orderDate)) throw ArgumentError('Время вывоза должно быть после даты заказа');
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      addressId: json['address_id'] as String?,
      orderDate: DateTime.parse(json['order_date'] as String),
      pickupTime: DateTime.parse(json['pickup_time'] as String),
      bagCount: json['bag_count'] as int,
      totalPrice: _parseDouble(json['total_price']),
      status: OrderStatus.fromValue(json['status'] as String),
      comment: json['comment'] as String?,
      promoCode: json['promo_code'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    throw FormatException('Невозможно преобразовать $value в double');
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (addressId != null) 'address_id': addressId,
      'order_date': orderDate.toIso8601String(),
      'pickup_time': pickupTime.toIso8601String(),
      'bag_count': bagCount,
      'total_price': totalPrice,
      'status': status.value,
      if (comment != null) 'comment': comment,
      if (promoCode != null) 'promo_code': promoCode,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  bool get canBeCancelled => status.priority <= OrderStatus.accepted.priority;
  bool get isCompleted => status == OrderStatus.completed;
  bool get isActive => status.priority <= OrderStatus.inProgress.priority;
  bool get isPersisted => id != null;

  String get statusText => status.displayName;

  Order copyWith({
    String? id,
    String? userId,
    String? addressId,
    DateTime? orderDate,
    DateTime? pickupTime,
    int? bagCount,
    double? totalPrice,
    OrderStatus? status,
    String? comment,
    String? promoCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      addressId: addressId ?? this.addressId,
      orderDate: orderDate ?? this.orderDate,
      pickupTime: pickupTime ?? this.pickupTime,
      bagCount: bagCount ?? this.bagCount,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      comment: comment ?? this.comment,
      promoCode: promoCode ?? this.promoCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, userId, addressId, orderDate, pickupTime,
    bagCount, totalPrice, status, comment, promoCode,
    createdAt, updatedAt
  ];
}