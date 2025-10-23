import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get dbHost => _get('DB_HOST');
  static int get dbPort => int.parse(_get('DB_PORT'));
  static String get dbName => _get('DB_NAME');
  static String get dbUser => _get('DB_USER');
  static String get dbPass => _get('DB_PASS');
  static String get dbCharset => _get('DB_CHARSET');

  static String get apiBaseUrl => _get('API_BASE_URL');
  static int get apiTimeout => int.parse(_get('API_TIMEOUT'));

  static bool get isDebug => _get('APP_DEBUG').toLowerCase() == 'true';
  static String get appName => _get('APP_NAME');

  static String _get(String key) {
    final value = dotenv.env[key];
    if (value == null) {
      throw Exception('❌ Конфиг $key не найден в .env файле');
    }
    return value;
  }

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }
}