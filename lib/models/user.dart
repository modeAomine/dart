import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String? id;
  final String email;
  final String name;
  final String? phone;

  User({
    this.id,
    required this.email,
    required this.name,
    this.phone,
  }) {
    if (name.isEmpty) throw ArgumentError('Имя не может быть пустым');
    if (!_isValidEmail(email)) throw ArgumentError('Неверный формат email');
  }

  static bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();

    return User(
      id: id,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'name': name,
      if (phone != null) 'phone': phone,
    };
  }

  bool get isPersisted => id != null;

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [id, email, name, phone];
}