import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkService with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool get isConnected => _isConnected;

  NetworkService() {
    _init();
  }

  Future<void> _init() async {
    await _checkConnection();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final newStatus = result != ConnectivityResult.none;
    if (_isConnected != newStatus) {
      _isConnected = newStatus;
      notifyListeners();
    }
  }

  Future<void> manualCheck() async {
    await _checkConnection();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}