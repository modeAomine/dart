import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/network_service.dart';
import '../../services/auth_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/button_styles.dart';
import '../auth/login_screen.dart';
import '../main_menu.dart';

class NetworkErrorScreen extends StatefulWidget {
  @override
  _NetworkErrorScreenState createState() => _NetworkErrorScreenState();
}

class _NetworkErrorScreenState extends State<NetworkErrorScreen> {
  bool _isChecking = false;

  Future<void> _checkConnection(BuildContext context) async {
    setState(() {
      _isChecking = true;
    });

    final networkService = Provider.of<NetworkService>(context, listen: false);
    await networkService.manualCheck();

    await Future.delayed(Duration(milliseconds: 1000));

    setState(() {
      _isChecking = false;
    });

    if (networkService.isConnected) {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (authService.currentUser != null && authService.rememberMe) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainMenu()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 120,
                  color: AppColors.secondary.withOpacity(0.7),
                ),
                SizedBox(height: 32),
                Text(
                  'Нет подключения к интернету',
                  style: AppTextStyles.headerLarge.copyWith(
                    color: AppColors.primary,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Проверьте подключение к интернету и попробуйте снова',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: AppButtonStyles.primaryButton.copyWith(
                      backgroundColor: MaterialStateProperty.all(
                        _isChecking ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                    onPressed: _isChecking ? null : () => _checkConnection(context),
                    child: _isChecking
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Попробовать снова',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_isChecking)
                  Text(
                    'Проверяем подключение...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}