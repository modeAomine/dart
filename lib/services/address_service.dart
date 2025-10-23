import 'package:flutter/foundation.dart';
import '../models/address.dart';
import 'database_service.dart';

class AddressService with ChangeNotifier {
  List<Address> _addresses = [];
  bool _isLoading = false;

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;

  Future<void> loadUserAddresses(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final connection = await DatabaseService.connection;

      final result = await connection.query('''
        SELECT id, user_id, title, latitude, longitude, address_text, created_at
        FROM addresses 
        WHERE user_id = ?
        ORDER BY created_at DESC
      ''', [userId]);

      _addresses = result.map((row) {
        final fields = row.fields;
        return Address(
          id: fields['id']?.toString(),
          userId: fields['user_id']?.toString(),
          title: fields['title']?.toString() ?? '',
          latitude: _parseDouble(fields['latitude']),
          longitude: _parseDouble(fields['longitude']),
          addressText: fields['address_text']?.toString() ?? '',
          createdAt: fields['created_at'] != null ? (fields['created_at'] is DateTime ? fields['created_at'] as DateTime : DateTime.parse(fields['created_at'].toString())) : null,
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    if (value == null) throw FormatException('Значение не может быть null');
    throw FormatException('Невозможно преобразовать $value в double');
  }

  Future<bool> addAddress(Address address) async {
    try {
      final connection = await DatabaseService.connection;

      if (address.userId == null) {
        throw ArgumentError('User ID не может быть null при добавлении адреса');
      }

      await connection.query('''
        INSERT INTO addresses (
          user_id, title, latitude, longitude, address_text
        ) VALUES (
          ?, ?, ?, ?, ?
        )
      ''', [
        address.userId!,
        address.title,
        address.latitude,
        address.longitude,
        address.addressText,
      ]);

      await loadUserAddresses(address.userId!);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при добавлении адреса: $e');
      }
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId, String userId) async {
    try {
      final connection = await DatabaseService.connection;

      await connection.query(
        'DELETE FROM addresses WHERE id = ?',
        [addressId],
      );

      await loadUserAddresses(userId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при удалении адреса: $e');
      }
      return false;
    }
  }

  Future<bool> updateAddress(Address address) async {
    try {
      final connection = await DatabaseService.connection;

      if (address.id == null) {
        throw ArgumentError('Address ID не может быть null при обновлении');
      }

      await connection.query('''
        UPDATE addresses 
        SET title = ?, latitude = ?, longitude = ?, address_text = ?
        WHERE id = ?
      ''', [
        address.title,
        address.latitude,
        address.longitude,
        address.addressText,
        address.id!,
      ]);

      if (address.userId != null) {
        await loadUserAddresses(address.userId!);
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при обновлении адреса: $e');
      }
      return false;
    }
  }

  Address? findAddressById(String? addressId) {
    if (addressId == null) return null;
    try {
      return _addresses.firstWhere((address) => address.id == addressId);
    } catch (e) {
      return null;
    }
  }

  void clearAddresses() {
    _addresses.clear();
    notifyListeners();
  }
}