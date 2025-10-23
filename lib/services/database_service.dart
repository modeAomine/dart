import 'package:mysql1/mysql1.dart';
import 'config.dart';

class DatabaseService {
  static MySqlConnection? _connection;
  static bool _isInitialized = false;
  static int _retryCount = 0;
  static const int _maxRetries = 3;
  static DateTime? _lastConnectionCheck;

  static Future<MySqlConnection> get connection async {
    if (_connection == null || !_isInitialized) {
      await _reconnect();
    }

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
      print('🎯 Пытаемся подключиться к MySQL...');
      print('🎯 Host: ${Config.dbHost}');
      print('🎯 Port: ${Config.dbPort}');
      print('🎯 DB: ${Config.dbName}');
      print('🎯 User: ${Config.dbUser}');

      final hosts = [Config.dbHost];
      dynamic lastException;

      for (final host in hosts) {
        try {
          if (_retryCount >= _maxRetries) {
            throw Exception('Превышено количество попыток подключения');
          }

          print('🔄 Попытка ${_retryCount + 1}/$_maxRetries - подключение к $host...');

          final settings = ConnectionSettings(
            host: host,
            port: Config.dbPort,
            user: Config.dbUser,
            password: Config.dbPass,
            db: Config.dbName,
            timeout: Duration(seconds: 10),
          );

          _connection = await MySqlConnection.connect(settings);
          _isInitialized = true;
          _retryCount = 0;
          _lastConnectionCheck = DateTime.now();

          print('✅ Успешно подключились к MySQL на $host');
          await _checkDatabaseStructure();
          return;

        } catch (e) {
          _retryCount++;
          lastException = e;
          print('❌ Ошибка подключения к $host: $e');
          await _connection?.close();
          _connection = null;

          if (_retryCount < _maxRetries) {
            await Future.delayed(Duration(seconds: 2));
          }
        }
      }

      throw lastException is Exception ? lastException : Exception('Не удалось подключиться к MySQL');
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  static Future<void> _checkDatabaseStructure() async {
    try {
      final conn = await connection;
      final tablesResult = await conn.query("SHOW TABLES LIKE 'users'");

      if (tablesResult.isEmpty) {
        print('🔄 Создаем структуру БД...');
        await _createDatabaseStructure();
      } else {
        print('✅ Структура БД проверена');
      }
    } catch (e) {
      print('⚠️ Ошибка проверки структуры БД: $e');
    }
  }

  static Future<void> _createDatabaseStructure() async {
    try {
      final conn = await connection;

      await conn.query('''
        CREATE TABLE IF NOT EXISTS users (
          id VARCHAR(36) PRIMARY KEY,
          phone VARCHAR(15) NOT NULL UNIQUE,
          name VARCHAR(100) NOT NULL,
          password_hash VARCHAR(255) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
      ''');

      await conn.query('''
        CREATE TABLE IF NOT EXISTS addresses (
          id VARCHAR(36) PRIMARY KEY,
          user_id VARCHAR(36) NOT NULL,
          title VARCHAR(100) NOT NULL,
          latitude DECIMAL(10, 8) NOT NULL,
          longitude DECIMAL(11, 8) NOT NULL,
          address_text TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          INDEX idx_user_id (user_id)
        )
      ''');

      await conn.query('''
        CREATE TABLE IF NOT EXISTS orders (
          id VARCHAR(36) PRIMARY KEY,
          user_id VARCHAR(36) NOT NULL,
          address_id VARCHAR(36) NOT NULL,
          order_date DATETIME NOT NULL,
          pickup_time DATETIME NOT NULL,
          bag_count INT NOT NULL DEFAULT 1,
          total_price DECIMAL(10, 2) NOT NULL,
          status ENUM('pending', 'accepted', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
          comment TEXT,
          promo_code VARCHAR(50),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          FOREIGN KEY (address_id) REFERENCES addresses(id) ON DELETE CASCADE,
          INDEX idx_user_id (user_id),
          INDEX idx_status (status)
        )
      ''');

      print('✅ Структура БД создана успешно');
    } catch (e) {
      print('❌ Ошибка создания структуры БД: $e');
      rethrow;
    }
  }

  static Future<bool> get isAvailable async {
    try {
      final conn = await connection;
      await conn.query('SELECT 1');
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> close() async {
    await _connection?.close();
    _isInitialized = false;
    _connection = null;
    _retryCount = 0;
    _lastConnectionCheck = null;
  }
}