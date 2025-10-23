import 'package:flutter/foundation.dart';
import '../models/employee_application.dart';
import 'database_service.dart';

class EmployeeService with ChangeNotifier {
  EmployeeApplication? _currentApplication;
  bool _isLoading = false;

  EmployeeApplication? get currentApplication => _currentApplication;
  bool get isLoading => _isLoading;

  Future<void> loadUserApplication(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final connection = await DatabaseService.connection;
      final result = await connection.query(
          'SELECT * FROM employee_applications WHERE user_id = ? ORDER BY created_at DESC LIMIT 1',
          [userId]
      );

      if (result.isNotEmpty) {
        final row = result.first;
        _currentApplication = EmployeeApplication.fromJson(row.fields);
      }
    } catch (e) {
      print('Ошибка загрузки заявки: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveApplication(EmployeeApplication application) async {
    try {
      final connection = await DatabaseService.connection;

      if (application.id == null) {
        // Новая заявка
        await connection.query('''
          INSERT INTO employee_applications 
          (user_id, passport_series, passport_number, passport_issue_date, passport_issued_by, 
           registration_address, bank_name, bank_account, bank_card_number, desired_position, 
           work_experience, additional_info, status)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          application.userId,
          application.passportSeries,
          application.passportNumber,
          application.passportIssueDate?.toIso8601String(),
          application.passportIssuedBy,
          application.registrationAddress,
          application.bankName,
          application.bankAccount,
          application.bankCardNumber,
          application.desiredPosition,
          application.workExperience,
          application.additionalInfo,
          application.status.name,
        ]);
      } else {
        // Обновление существующей
        await connection.query('''
          UPDATE employee_applications SET
          passport_series = ?, passport_number = ?, passport_issue_date = ?, passport_issued_by = ?,
          registration_address = ?, bank_name = ?, bank_account = ?, bank_card_number = ?,
          desired_position = ?, work_experience = ?, additional_info = ?, status = ?, updated_at = CURRENT_TIMESTAMP
          WHERE id = ?
        ''', [
          application.passportSeries,
          application.passportNumber,
          application.passportIssueDate?.toIso8601String(),
          application.passportIssuedBy,
          application.registrationAddress,
          application.bankName,
          application.bankAccount,
          application.bankCardNumber,
          application.desiredPosition,
          application.workExperience,
          application.additionalInfo,
          application.status.name,
          application.id,
        ]);
      }

      await loadUserApplication(application.userId);
      return true;
    } catch (e) {
      print('Ошибка сохранения заявки: $e');
      return false;
    }
  }
}