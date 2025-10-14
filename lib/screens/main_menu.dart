import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../theme/button_styles.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded( // ДОБАВЬ Expanded здесь
            child: _buildMenuContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Вынос мусора',
            style: AppTextStyles.headerLarge.copyWith(
              color: AppColors.onPrimary,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Экологичный сервис',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuContent(BuildContext context) {
    return SingleChildScrollView( // ИЗМЕНИ на SingleChildScrollView
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMenuButton(
            icon: Icons.person,
            title: 'Профиль',
            subtitle: 'Личные данные и адреса',
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          SizedBox(height: 16),
          _buildMenuButton(
            icon: Icons.calendar_today,
            title: 'Расписание вывоза',
            subtitle: 'Посмотреть график вывоза мусора',
            onTap: () {},
          ),
          SizedBox(height: 16),
          _buildMenuButton(
            icon: Icons.location_on,
            title: 'Пункты приема',
            subtitle: 'Карта пунктов приема вторсырья',
            onTap: () {},
          ),
          SizedBox(height: 16),
          _buildMenuButton(
            icon: Icons.receipt_long,
            title: 'Мои заявки',
            subtitle: 'История и статус заявок',
            onTap: () {},
          ),
          SizedBox(height: 16),
          _buildMenuButton(
            icon: Icons.info,
            title: 'О приложении',
            subtitle: 'Информация и инструкции',
            onTap: () {},
          ),
          SizedBox(height: 32), // УВЕЛИЧЬ отступ
          ElevatedButton(
            style: AppButtonStyles.secondaryButton,
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('Выйти'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.headerSmall,
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.primary,
          size: 16,
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }
}