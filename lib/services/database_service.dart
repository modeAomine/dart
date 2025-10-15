import 'package:postgres/postgres.dart';

class DatabaseService {
  static PostgreSQLConnection? _connection;
  static bool _isInitialized = false;
  static int _retryCount = 0;
  static const int _maxRetries = 3;
  static DateTime? _lastConnectionCheck;

  static Future<PostgreSQLConnection> get connection async {
    // Проверяем, нужно ли переподключение
    if (_connection == null || _connection!.isClosed || !_isInitialized) {
      await _reconnect();
    }

    // Периодически проверяем живое ли соединение
    if (_shouldCheckConnection()) {
      final isAlive = await _checkConnectionHealth();
      if (!isAlive) {
        await _reconnect();
      }
    }

    return _connection!;
  }

  static bool _shouldCheckConnection() {
    if (_lastConnectionCheck == null) return true;
    return DateTime.now().difference(_lastConnectionCheck!) > Duration(seconds: 30);
  }

  static Future<bool> _checkConnectionHealth() async {
    try {
      await _connection!.query('SELECT 1');
      _lastConnectionCheck = DateTime.now();
      return true;
    } catch (e) {
      print('⚠️ Проверка соединения: соединение неактивно');
      return false;
    }
  }

  static Future<void> _reconnect() async {
    _retryCount = 0;
    _isInitialized = false;
    await initialize();
  }

  static Future<void> initialize() async {
    try {
      print('🔄 Пытаемся подключиться к PostgreSQL...');

      final hosts = ['localhost', '10.0.2.2', '127.0.0.1'];
      Exception? lastException;

      for (final host in hosts) {
        try {
          if (_retryCount >= _maxRetries) {
            throw Exception('Превышено количество попыток подключения');
          }

          print('🔄 Попытка ${_retryCount + 1}/$_maxRetries - подключение к $host...');

          _connection = PostgreSQLConnection(
            host,
            5432,
            'dart',
            username: 'postgres',
            password: '1234',
            timeoutInSeconds: 10,
            queryTimeoutInSeconds: 15,
          );

          await _connection!.open();
          _isInitialized = true;
          _retryCount = 0;
          _lastConnectionCheck = DateTime.now();

          print('✅ База данных подключена к $host');
          return;

        } catch (e) {
          _retryCount++;
          lastException = e as Exception?;
          print('❌ Не удалось подключиться к $host: $e');
          await _connection?.close();
          _connection = null;

          if (_retryCount < _maxRetries) {
            await Future.delayed(Duration(seconds: 2));
          }
        }
      }

      throw lastException ?? Exception('Не удалось подключиться к PostgreSQL');

    } catch (e) {
      print('❌ Критическая ошибка подключения к базе данных: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  // ✅ ДОБАВЛЕНО: Метод для безопасной проверки доступности БД
  static Future<bool> get isAvailable async {
    try {
      final conn = await connection;
      await conn.query('SELECT 1');
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> testConnection() async {
    try {
      final conn = await connection;
      final result = await conn.query('SELECT 1');
      return result.isNotEmpty;
    } catch (e) {
      print('❌ Ошибка тестирования подключения: $e');
      return false;
    }
  }

  static Future<bool> isConnectionAlive() async {
    try {
      if (_connection == null || _connection!.isClosed) {
        return false;
      }
      await _connection!.query('SELECT 1');
      _lastConnectionCheck = DateTime.now();
      return true;
    } catch (e) {
      print('⚠️ Соединение неактивно: $e');
      _isInitialized = false;
      return false;
    }
  }

  static Future<void> close() async {
    await _connection?.close();
    _isInitialized = false;
    _connection = null;
    _retryCount = 0;
    _lastConnectionCheck = null;
    print('✅ Подключение к БД закрыто');
  }
}