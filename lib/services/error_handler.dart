class AppError implements Exception {
  final String message;
  final ErrorType type;

  AppError(this.message, {this.type = ErrorType.unknown});

  @override
  String toString() => message;
}

enum ErrorType {
  network,      // Нет интернета
  database,     // Проблемы с БД
  authentication, // Ошибки авторизации
  validation,   // Ошибки валидации
  server,       // Ошибки сервера
  unknown       // Неизвестная ошибка
}

class ErrorHandler {
  static AppError handleError(dynamic error) {
    print('🔴 Обработка ошибки: $error');

    if (error is AppError) {
      return error;
    }

    final errorString = error.toString().toLowerCase();

    // Определяем тип ошибки по содержимому
    if (errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('host') ||
        errorString.contains('internet')) {
      return AppError('Нет подключения к интернету', type: ErrorType.network);
    }

    if (errorString.contains('postgresql') ||
        errorString.contains('database') ||
        errorString.contains('connection is not open') ||
        errorString.contains('timeout')) {
      return AppError('Проблемы с подключением к базе данных', type: ErrorType.database);
    }

    if (errorString.contains('password') ||
        errorString.contains('auth') ||
        errorString.contains('user') ||
        errorString.contains('login')) {
      return AppError('Ошибка авторизации', type: ErrorType.authentication);
    }

    return AppError('Произошла неизвестная ошибка', type: ErrorType.unknown);
  }

  static String getUserFriendlyMessage(AppError error) {
    switch (error.type) {
      case ErrorType.network:
        return 'Проверьте подключение к интернету';
      case ErrorType.database:
        return 'Сервер временно недоступен. Попробуйте позже';
      case ErrorType.authentication:
        return 'Неверный номер телефона или пароль';
      case ErrorType.validation:
        return 'Проверьте правильность введенных данных';
      case ErrorType.server:
        return 'Внутренняя ошибка сервера';
      case ErrorType.unknown:
        return 'Произошла непредвиденная ошибка';
    }
  }
}