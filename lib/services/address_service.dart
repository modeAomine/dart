import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/address.dart';
import 'api_service.dart';

class AddressService with ChangeNotifier {
  List<Address> _addresses = [];
  bool _isLoading = false;

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;

  Future<bool> loadUserAddresses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('addresses');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _addresses = (data as List).map((item) => Address.fromJson(item)).toList();

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Ошибка загрузки адресов: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> addAddress(Address address) async {
    try {
      final response = await ApiService.post('addresses', {
        'title': address.title,
        'address_text': address.addressText,
        'latitude': address.latitude,
        'longitude': address.longitude,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadUserAddresses();
        return true;
      }
    } catch (e) {
      print('Ошибка добавления адреса: $e');
    }
    return false;
  }

  Future<bool> updateAddress(Address address) async {
    try {
      if (address.id == null) return false;

      final response = await ApiService.put('addresses/${address.id}', {
        'title': address.title,
        'address_text': address.addressText,
      });

      if (response.statusCode == 200) {
        await loadUserAddresses();
        return true;
      }
    } catch (e) {
      print('Ошибка обновления адреса: $e');
    }
    return false;
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      final response = await ApiService.delete('addresses/$addressId');

      if (response.statusCode == 200) {
        await loadUserAddresses();
        return true;
      }
    } catch (e) {
      print('Ошибка удаления адреса: $e');
    }
    return false;
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