import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/error_handler.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/button_styles.dart';
import '../../theme/input_styles.dart';
import '../../widgets/base_scaffold.dart';
import '../main_menu.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMeSetting();
  }

  Future<void> _loadRememberMeSetting() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() {
      _rememberMe = authService.rememberMe;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return BaseScaffold(
      body: authService.isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(height: 80),
              _buildHeader(),
              SizedBox(height: 40),
              _buildForm(context, authService),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.delete_outline, size: 50, color: AppColors.onPrimary),
        ),
        SizedBox(height: 20),
        Text('Вынос мусора', style: AppTextStyles.headerLarge.copyWith(color: AppColors.primary)),
        SizedBox(height: 8),
        Text('Экологичный сервис', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary)),
      ],
    );
  }

  Widget _buildForm(BuildContext context, AuthService authService) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: AppInputStyles.textField(
              labelText: 'Email',
              hintText: 'example@mail.ru',
              prefixIcon: Icon(Icons.email, color: AppColors.primary),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Введите email';
              if (!_isValidEmail(value)) return 'Введите корректный email';
              return null;
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            decoration: AppInputStyles.textField(
              labelText: 'Пароль',
              prefixIcon: Icon(Icons.lock, color: AppColors.primary),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Введите пароль';
              if (value.length < 6) return 'Пароль должен быть не менее 6 символов';
              return null;
            },
          ),
          SizedBox(height: 16),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Запомнить меня', style: AppTextStyles.bodyMedium),
            value: _rememberMe,
            onChanged: (value) => setState(() => _rememberMe = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: AppButtonStyles.primaryButton,
              onPressed: () => _performLogin(context, authService),
              child: Text('Войти'),
            ),
          ),
          SizedBox(height: 20),
          TextButton(
            style: AppButtonStyles.textButton,
            onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
            child: Text('Нет аккаунта? Зарегистрируйтесь'),
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  Future<void> _performLogin(BuildContext context, AuthService authService) async {
    if (_formKey.currentState!.validate()) {
      final success = await authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (success) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainMenu()));
      } else {
        String errorMessage = 'Ошибка входа';
        if (authService.lastError != null) {
          errorMessage = ErrorHandler.getUserFriendlyMessage(authService.lastError!);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: AppColors.error, duration: Duration(seconds: 3)),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}