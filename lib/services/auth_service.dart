import 'package:flutter/foundation.dart';
import 'database_service.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<bool> loginWithPhone(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final connection = await DatabaseService.connection;

      final result = await connection.query(
        'SELECT id, phone, name, created_at, updated_at FROM users WHERE phone = @phone AND password_hash = @password',
        substitutionValues: {
          'phone': phone,
          'password': _hashPassword(password),
        },
      );

      if (result.isNotEmpty) {
        final row = result.first;
        _currentUser = User(
          id: row[0] as String,
          phone: row[1] as String,
          name: row[2] as String,
          createdAt: row[3] as DateTime,
          updatedAt: row[4] as DateTime?,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Ошибка входа: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  String _hashPassword(String password) {
    return password;
  }
}