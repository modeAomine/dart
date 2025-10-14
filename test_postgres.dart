import 'package:postgres/postgres.dart';

void main() async {
  print('🧪 Тестируем подключение к PostgreSQL...');

  try {
    final connection = PostgreSQLConnection(
      'localhost',
      5432,
      'dart',
      username: 'postgres',
      password: '1234', // Убедитесь, что пароль правильный
      // encoding должен быть строкой, а не объектом Utf8Codec
      // encoding: 'UTF8', // Этот параметр может быть причиной проблемы
    );

    await connection.open();
    print('✅ Подключение успешно!');

    // Пробуем создать таблицу
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS test_table (
        id SERIAL PRIMARY KEY,
        name TEXT,
        created_at TIMESTAMP DEFAULT NOW()
      )
    ''');
    print('✅ Таблица создана/проверена');

    // Тестируем вставку данных
    await connection.execute(
      'INSERT INTO test_table (name) VALUES (@name)',
      substitutionValues: {'name': 'Test Name'},
    );
    print('✅ Данные добавлены');

    await connection.close();
    print('✅ Подключение закрыто');

  } catch (e) {
    print('❌ Ошибка: $e');

    // Проверяем что PostgreSQL запущен
    print('\n🔧 Советы по устранению:');
    print('1. Убедись что PostgreSQL запущен: psql -U postgres -c "SELECT version();"');
    print('2. Проверь что база "dart" существует: createdb -U postgres dart');
    print('3. Проверь пароль пользователя postgres');
    print('4. Попробуй убрать параметр encoding из подключения');
  }
}