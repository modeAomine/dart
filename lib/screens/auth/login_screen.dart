import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/button_styles.dart';
import '../../theme/input_styles.dart';
import '../../utils/phone_formatter.dart';
import '../../widgets/phone_text_field.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.delete_outline,
            size: 50,
            color: AppColors.onPrimary,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Вынос мусора',
          style: AppTextStyles.headerLarge.copyWith(color: AppColors.primary),
        ),
        SizedBox(height: 8),
        Text(
          'Экологичный сервис',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, AuthService authService) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          PhoneTextField(
            controller: _phoneController,
            labelText: 'Номер телефона',
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
              if (value == null || value.isEmpty) {
                return 'Введите пароль';
              }
              if (value.length < 6) {
                return 'Пароль должен быть не менее 6 символов';
              }
              return null;
            },
          ),
          SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: AppButtonStyles.primaryButton,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final cleanPhone = PhoneFormatter.cleanPhone(_phoneController.text);

                  final success = await authService.loginWithPhone(
                    cleanPhone.substring(1), // убираем 7 для базы данных
                    _passwordController.text,
                  );

                  if (success) {
                    Navigator.pushReplacementNamed(context, '/main');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ошибка входа'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: Text('Войти'),
            ),
          ),
          SizedBox(height: 20),
          TextButton(
            style: AppButtonStyles.textButton,
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/register');
            },
            child: Text('Нет аккаунта? Зарегистрируйтесь'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}