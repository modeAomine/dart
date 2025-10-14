class Order {
  final String id;
  final String userId;
  final String addressId;
  DateTime orderDate;
  DateTime pickupTime;
  int bagCount;
  double totalPrice;
  String status; // 'pending', 'accepted', 'completed', 'cancelled'
  String? comment;
  String? promoCode;
  DateTime createdAt;
  DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.addressId,
    required this.orderDate,
    required this.pickupTime,
    required this.bagCount,
    required this.totalPrice,
    required this.status,
    this.comment,
    this.promoCode,
    required this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      addressId: json['address_id'],
      orderDate: DateTime.parse(json['order_date']),
      pickupTime: DateTime.parse(json['pickup_time']),
      bagCount: json['bag_count'],
      totalPrice: json['total_price'],
      status: json['status'],
      comment: json['comment'],
      promoCode: json['promo_code'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'address_id': addressId,
      'order_date': orderDate.toIso8601String(),
      'pickup_time': pickupTime.toIso8601String(),
      'bag_count': bagCount,
      'total_price': totalPrice,
      'status': status,
      'comment': comment,
      'promo_code': promoCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get statusText {
    switch (status) {
      case 'pending': return 'Ожидание';
      case 'accepted': return 'Принят';
      case 'completed': return 'Выполнен';
      case 'cancelled': return 'Отменен';
      default: return 'Неизвестно';
    }
  }
}