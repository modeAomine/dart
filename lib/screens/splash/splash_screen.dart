import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/network_service.dart';
import '../../theme/colors.dart';
import '../auth/login_screen.dart';
import '../main_menu.dart';
import '../network/network_error_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final networkService = Provider.of<NetworkService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    await networkService.manualCheck();

    await Future.delayed(Duration(milliseconds: 2000));

    if (!mounted) return;

    if (!networkService.isConnected) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NetworkErrorScreen()));
      return;
    }

    if (authService.currentUser != null && authService.rememberMe) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainMenu()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.onPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Вынос мусора',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Экологичный сервис',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}