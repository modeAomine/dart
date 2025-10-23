import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String? id;
  final String phone;
  String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.phone,
    required this.name,
    this.createdAt,
    this.updatedAt,
  }) {
    if (!_isValidPhone(phone)) throw ArgumentError('Неверный формат телефона');
    if (name.isEmpty) throw ArgumentError('Имя не может быть пустым');
  }

  static bool _isValidPhone(String phone) {
    final regex = RegExp(r'^\+?[0-9]{10,13}$');
    return regex.hasMatch(phone.replaceAll(RegExp(r'\s+'), ''));
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      phone: json['phone'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'phone': phone,
      'name': name,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  bool get isPersisted => id != null;

  User copyWith({
    String? id,
    String? phone,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, phone, name, createdAt, updatedAt];
}