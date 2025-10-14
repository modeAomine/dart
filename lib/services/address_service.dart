import 'package:flutter/foundation.dart';
import 'package:postgres/postgres.dart';
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
        WHERE user_id = @userId
        ORDER BY created_at DESC
      ''', substitutionValues: {'userId': userId});

      _addresses = result.map((row) {
        return Address(
          id: row[0] as String,
          userId: row[1] as String,
          title: row[2] as String,
          latitude: (row[3] as num).toDouble(),
          longitude: (row[4] as num).toDouble(),
          addressText: row[5] as String,
          createdAt: row[6] as DateTime,
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

  Future<bool> addAddress(Address address) async {
    try {
      final connection = await DatabaseService.connection;

      await connection.execute('''
        INSERT INTO addresses (
          user_id, title, latitude, longitude, address_text
        ) VALUES (
          @userId, @title, @latitude, @longitude, @addressText
        )
      ''', substitutionValues: {
        'userId': address.userId,
        'title': address.title,
        'latitude': address.latitude,
        'longitude': address.longitude,
        'addressText': address.addressText,
      });

      await loadUserAddresses(address.userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId, String userId) async {
    try {
      final connection = await DatabaseService.connection;

      await connection.execute(
        'DELETE FROM addresses WHERE id = @id',
        substitutionValues: {'id': addressId},
      );

      await loadUserAddresses(userId);
      return true;
    } catch (e) {
      return false;
    }
  }
}