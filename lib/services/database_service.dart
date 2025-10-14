import 'package:postgres/postgres.dart';

class DatabaseService {
  static PostgreSQLConnection? _connection;
  static bool _isInitialized = false;

  static Future<PostgreSQLConnection> get connection async {
    if (!_isInitialized) {
      await initialize();
    }
    return _connection!;
  }

  static Future<void> initialize() async {
    try {
      print('🔄 Пытаемся подключиться к PostgreSQL...');

      // Пробуем разные хосты
      final hosts = ['localhost', '10.0.2.2', '127.0.0.1'];
      Exception? lastException;

      for (final host in hosts) {
        try {
          print('🔄 Пробуем подключиться к $host...');

          _connection = PostgreSQLConnection(
            host,
            5432,
            'dart', // имя базы данных
            username: 'postgres', // пользователь
            password: '1234', // пароль
            timeoutInSeconds: 10, // таймаут 10 секунд
          );

          await _connection!.open();
          _isInitialized = true;
          print('✅ База данных подключена к $host');
          return; // Успешно подключились

        } catch (e) {
          lastException = e as Exception?;
          print('❌ Не удалось подключиться к $host: $e');
          await _connection?.close();
          _connection = null;
        }
      }

      // Если ни один хост не сработал
      throw lastException ?? Exception('Не удалось подключиться к PostgreSQL');

    } catch (e) {
      print('❌ Критическая ошибка подключения к базе данных: $e');
      rethrow;
    }
  }

  static Future<void> close() async {
    await _connection?.close();
    _isInitialized = false;
    _connection = null;
    print('✅ Подключение к БД закрыто');
  }

  // Метод для проверки подключения
  static Future<bool> testConnection() async {
    try {
      final conn = await connection;
      final result = await conn.query('SELECT 1');
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}