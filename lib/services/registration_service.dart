import 'package:flutter/foundation.dart';
import 'database_service.dart';

class RegistrationService with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<bool> registerUser(String phone, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      final connection = await DatabaseService.connection;

      final checkResult = await connection.query(
        'SELECT id FROM users WHERE phone = @phone',
        substitutionValues: {'phone': phone},
      );

      if (checkResult.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final result = await connection.query(
        'INSERT INTO users (phone, name, password_hash) VALUES (@phone, @name, @password) RETURNING id, created_at',
        substitutionValues: {
          'phone': phone,
          'name': name,
          'password': _hashPassword(password),
        },
      );

      if (result.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Ошибка регистрации: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _hashPassword(String password) {
    return password;
  }
}