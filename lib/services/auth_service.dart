import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'database_service.dart';
import 'error_handler.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _rememberMe = false;
  AppError? _lastError;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  AppError? get lastError => _lastError;

  AuthService() {
    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('remembered_user');
      _rememberMe = prefs.getBool('remember_me') ?? false;

      if (userJson != null && _rememberMe) {
        final userMap = json.decode(userJson);
        _currentUser = User.fromJson(userMap);
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка загрузки пользователя: $e');
    }
  }

  Future<bool> loginWithPhone(String phone, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    _rememberMe = rememberMe;
    _lastError = null;
    notifyListeners();

    try {
      final isDbAlive = await DatabaseService.isConnectionAlive();
      if (!isDbAlive) {
        throw AppError('Нет подключения к базе данных', type: ErrorType.database);
      }

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

        if (rememberMe) {
          await _saveUserData();
        } else {
          await _clearUserData();
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw AppError('Неверный номер телефона или пароль', type: ErrorType.authentication);
      }
    } catch (e) {
      _lastError = ErrorHandler.handleError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setString('remembered_user', json.encode(_currentUser!.toJson()));
      await prefs.setBool('remember_me', _rememberMe);
    }
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remembered_user');
    await prefs.setBool('remember_me', false);
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _clearUserData();
    _currentUser = null;
    _rememberMe = false;
    _lastError = null;
    notifyListeners();
  }

  String _hashPassword(String password) {
    return password;
  }
}