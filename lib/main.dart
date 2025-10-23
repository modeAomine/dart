import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash_removal_app/screens/auth/login_screen.dart';
import 'package:trash_removal_app/screens/auth/registration_screen.dart';
import 'package:trash_removal_app/screens/main_menu.dart';
import 'package:trash_removal_app/screens/profile/profile_screen.dart';
import 'package:trash_removal_app/screens/about_screen.dart';
import 'package:trash_removal_app/screens/work_screen.dart';
import 'services/auth_service.dart';
import 'services/registration_service.dart';
import 'services/address_service.dart';
import 'services/network_service.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/colors.dart';
import 'services/config.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Config.load();

  try {
    await DatabaseService.initialize();
    print('✅ DatabaseService инициализирован');
  } catch (e) {
    print('❌ Ошибка инициализации БД: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => RegistrationService()),
        ChangeNotifierProvider(create: (_) => AddressService()),
        ChangeNotifierProvider(create: (_) => NetworkService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Вынос мусора',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        primaryColorDark: AppColors.primaryDark,
        primaryColorLight: AppColors.primaryLight,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/main': (context) => MainMenu(),
        '/profile': (context) => ProfileScreen(),
        '/about': (context) => AboutScreen(),
        '/work': (context) => WorkScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}