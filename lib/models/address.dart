import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final String? id;
  final String? userId;
  final String title;
  final double latitude;
  final double longitude;
  final String addressText;

  Address({
    this.id,
    this.userId,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.addressText,
  }) {
    if (title.isEmpty) throw ArgumentError('Название адреса не может быть пустым');
    if (latitude < -90 || latitude > 90) throw ArgumentError('Широта должна быть между -90 и 90');
    if (longitude < -180 || longitude > 180) throw ArgumentError('Долгота должна быть между -180 и 180');
    if (addressText.isEmpty) throw ArgumentError('Текст адреса не может быть пустым');
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final userId = json['user_id']?.toString(); // ВОЗВРАЩАЕМ

    return Address(
      id: id,
      userId: userId,
      title: json['title'] as String,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      addressText: json['address_text'] as String,
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
      if (userId != null) 'user_id': userId, // ВОЗВРАЩАЕМ
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      'address_text': addressText,
    };
  }

  Address copyWith({
    String? id,
    String? userId,
    String? title,
    double? latitude,
    double? longitude,
    String? addressText,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressText: addressText ?? this.addressText,
    );
  }

  bool get isPersisted => id != null;

  @override
  List<Object?> get props => [id, userId, title, latitude, longitude, addressText];
}