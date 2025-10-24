import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/button_styles.dart';
import '../../theme/input_styles.dart';
import '../../widgets/base_scaffold.dart';
import '../main_menu.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
              SizedBox(height: 60),
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_add, size: 40, color: AppColors.onPrimary),
        ),
        SizedBox(height: 20),
        Text('Регистрация', style: AppTextStyles.headerLarge.copyWith(color: AppColors.primary)),
        SizedBox(height: 8),
        Text('Создайте новый аккаунт', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary)),
      ],
    );
  }

  Widget _buildForm(BuildContext context, AuthService authService) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: AppInputStyles.textField(
              labelText: 'Имя',
              prefixIcon: Icon(Icons.person, color: AppColors.primary),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Введите имя' : null,
          ),
          SizedBox(height: 16),
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
          SizedBox(height: 16),
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
          TextFormField(
            controller: _confirmPasswordController,
            decoration: AppInputStyles.textField(
              labelText: 'Подтвердите пароль',
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Подтвердите пароль';
              if (value != _passwordController.text) return 'Пароли не совпадают';
              return null;
            },
          ),
          SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: AppButtonStyles.primaryButton,
              onPressed: () => _performRegistration(context),
              child: Text('Зарегистрироваться'),
            ),
          ),
          SizedBox(height: 20),
          TextButton(
            style: AppButtonStyles.textButton,
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: Text('Уже есть аккаунт? Войдите'),
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  Future<void> _performRegistration(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);

      final success = await authService.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text,
      );

      if (success && context.mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainMenu()));
      } else if (context.mounted) {
        String errorMessage = 'Ошибка регистрации';
        if (authService.lastError != null) {
          errorMessage = authService.lastError!.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}