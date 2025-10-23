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
          'SELECT id FROM users WHERE phone = ?',
          [phone]
      );

      if (checkResult.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final userId = _generateUserId();

      await connection.query(
          'INSERT INTO users (id, phone, name, password_hash) VALUES (?, ?, ?, ?)',
          [userId, phone, name, _hashPassword(password)]
      );

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _hashPassword(String password) {
    return password;
  }
}