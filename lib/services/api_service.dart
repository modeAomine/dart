import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://aea2c1-94-77-146-177.ru.tuna.am/api';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<http.Response> _handleRequest(Future<http.Response> request) async {
    try {
      final response = await request;
      print('📡 API Response: ${response.statusCode} ${response.request?.url}');
      print('📡 API Response body: ${response.body}');

      if (response.statusCode == 301 || response.statusCode == 302) {
        final location = response.headers['location'];
        print('🔄 Redirect detected to: $location');
        throw Exception('Server redirected to: $location');
      }

      if (response.statusCode == 401) {
        print('🔐 Token expired, clearing storage');
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('user_data');
        throw Exception('Authentication failed: Token expired or invalid');
      }

      return response;
    } catch (e) {
      print('❌ API Request error: $e');
      rethrow;
    }
  }

  static Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final url = endpoint.startsWith('http') ? endpoint : '$baseUrl/$endpoint';
    return await _handleRequest(
        http.get(Uri.parse(url), headers: headers)
    );
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final url = endpoint.startsWith('http') ? endpoint : '$baseUrl/$endpoint';
    return await _handleRequest(
        http.post(Uri.parse(url), headers: headers, body: json.encode(data))
    );
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final url = endpoint.startsWith('http') ? endpoint : '$baseUrl/$endpoint';
    return await _handleRequest(
        http.put(Uri.parse(url), headers: headers, body: json.encode(data))
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final url = endpoint.startsWith('http') ? endpoint : '$baseUrl/$endpoint';
    return await _handleRequest(
        http.delete(Uri.parse(url), headers: headers)
    );
  }
}