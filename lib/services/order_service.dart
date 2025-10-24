import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class OrderService with ChangeNotifier {
  List<dynamic> _activeOrders = [];
  List<dynamic> _orderHistory = [];
  bool _isLoading = false;

  List<dynamic> get activeOrders => _activeOrders;
  List<dynamic> get orderHistory => _orderHistory;
  bool get isLoading => _isLoading;

  Future<bool> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('orders');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        _activeOrders = data.where((order) =>
        order['status'] == 'new' || order['status'] == 'confirmed'
        ).toList();

        _orderHistory = data.where((order) =>
        order['status'] == 'completed' || order['status'] == 'cancelled'
        ).toList();

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Ошибка загрузки заказов: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> createOrder({
    required String addressId,
    required String orderDate,
    required String type,
  }) async {
    try {
      final response = await ApiService.post('orders', {
        'address_id': addressId,
        'order_date': orderDate,
        'type': type,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadOrders();
        return true;
      }
    } catch (e) {
      print('Ошибка создания заказа: $e');
    }
    return false;
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      final response = await ApiService.put('orders/$orderId/cancel', {});

      if (response.statusCode == 200) {
        await loadOrders();
        return true;
      }
    } catch (e) {
      print('Ошибка отмены заказа: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    try {
      final response = await ApiService.get('orders/$orderId');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Ошибка получения заказа: $e');
    }
    return null;
  }
}