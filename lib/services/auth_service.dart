import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'error_handler.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _rememberMe = true;
  AppError? _lastError;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  AppError? get lastError => _lastError;

  AuthService() {
    _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');

      if (userJson != null) {
        final userMap = json.decode(userJson);
        _currentUser = User.fromJson(userMap);
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка загрузки пользователя: $e');
      await _clearStoredData();
    }
  }

  Future<bool> loginWithEmail(String email, String password, {bool rememberMe = true}) async {
    _isLoading = true;
    _rememberMe = rememberMe;
    _lastError = null;
    notifyListeners();

    try {
      print('🔐 Attempting login with email: $email');
      final response = await ApiService.post('login', {
        'email': email,
        'password': password,
      });

      print('📨 Login response status: ${response.statusCode}');
      print('📨 Login response body: ${response.body}');

      if (response.body.isEmpty) {
        throw AppError('Сервер вернул пустой ответ', type: ErrorType.server);
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['user'] != null) {
          final user = User.fromJson(responseData['user']);
          _currentUser = user;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', json.encode(responseData['user']));
          await prefs.setBool('is_logged_in', true);

          print('✅ Login successful for user: ${user.name}');
        } else {
          throw AppError('Данные пользователя не получены', type: ErrorType.server);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorMessage = responseData['message'] ?? responseData['error'] ?? 'Ошибка авторизации';
        throw AppError(errorMessage, type: ErrorType.authentication);
      }
    } catch (e) {
      print('💥 Login error: $e');
      _lastError = ErrorHandler.handleError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithEmail(String email, String password, String name) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      print('📝 Attempting registration with email: $email, name: $name');
      final response = await ApiService.post('register', {
        'email': email,
        'password': password,
        'name': name,
      });

      print('📨 Registration response status: ${response.statusCode}');
      print('📨 Registration response body: ${response.body}');

      if (response.body.isEmpty) {
        throw AppError('Сервер вернул пустой ответ при регистрации', type: ErrorType.server);
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['user'] != null) {
          final user = User.fromJson(responseData['user']);
          _currentUser = user;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', json.encode(responseData['user']));
          await prefs.setBool('is_logged_in', true);

          print('✅ Registration successful for user: ${user.name}');
        } else {
          throw AppError('Данные пользователя не получены при регистрации', type: ErrorType.server);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorMessage = responseData['message'] ?? responseData['error'] ?? 'Ошибка регистрации';
        throw AppError(errorMessage, type: ErrorType.authentication);
      }
    } catch (e) {
      print('💥 Registration error: $e');
      _lastError = ErrorHandler.handleError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> getProfile() async {
    try {
      final response = await ApiService.get('auth/me');

      if (response.body.isEmpty) {
        print('⚠️ Empty response from profile endpoint');
        return;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUser = User.fromJson(data);

        if (_rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', json.encode(data));
        }

        notifyListeners();
      } else if (response.statusCode == 401) {
        await logout();
      }
    } catch (e) {
      print('Ошибка получения профиля: $e');
    }
  }

  Future<void> _clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('is_logged_in');
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _clearStoredData();
      _currentUser = null;
      _lastError = null;
      notifyListeners();
    } catch (e) {
      print('Ошибка logout: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }
}