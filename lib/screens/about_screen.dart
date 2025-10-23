import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trash_removal_app/theme/colors.dart';
import 'package:trash_removal_app/theme/text_styles.dart';
import 'package:trash_removal_app/theme/button_styles.dart';
import 'package:trash_removal_app/widgets/base_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: AppBar(
        title: Text('О приложении'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppInfoCard(),
            SizedBox(height: 20),
            _buildFeaturesCard(),
            SizedBox(height: 20),
            _buildContactCard(),
            SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.delete_outline, color: AppColors.onPrimary, size: 30),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Вынос Мусора', style: AppTextStyles.headerMedium),
                      SizedBox(height: 4),
                      Text('Версия 1.0.0', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(color: AppColors.outline),
            SizedBox(height: 12),
            Text(
              'Современное приложение для заказа вывоза твердых коммунальных отходов. '
                  'Быстро, удобно и экологично!',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Возможности', style: AppTextStyles.headerSmall),
            SizedBox(height: 16),
            _buildFeatureItem(Icons.location_on, 'Выбор адреса на карте'),
            _buildFeatureItem(Icons.calendar_today, 'Гибкое расписание'),
            _buildFeatureItem(Icons.track_changes, 'Отслеживание заказов'),
            _buildFeatureItem(Icons.credit_card, 'Удобная оплата'),
            _buildFeatureItem(Icons.eco, 'Экологичный подход'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Контакты', style: AppTextStyles.headerSmall),
            SizedBox(height: 16),
            _buildContactItem(Icons.phone, 'Телефон', '+7 (999) 123-45-67'),
            _buildContactItem(Icons.email, 'Email', 'support@musor.app'),
            _buildContactItem(Icons.language, 'Сайт', 'www.musor.app'),
            _buildContactItem(Icons.access_time, 'Время работы', 'Круглосуточно'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary)),
              SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: AppButtonStyles.secondaryButton,
            onPressed: () => _showPrivacyPolicy(context),
            child: Text('Политика конфиденциальности'),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: AppButtonStyles.primaryButton,
            onPressed: () => _showContactOptions(context),
            child: Text('Связаться с нами'),
          ),
        ),
      ],
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Выберите способ связи',
              style: AppTextStyles.headerSmall,
            ),
            SizedBox(height: 20),
            _buildContactOption(
              context,
              icon: Icons.telegram,
              title: 'Telegram',
              subtitle: '@stamp_qw',
              value: '@stamp_qw',
            ),
            SizedBox(height: 12),
            _buildContactOption(
              context,
              icon: Icons.email,
              title: 'Email',
              subtitle: 'vynoz.musora.krasnodar@gmail.com',
              value: 'vynoz.musora.krasnodar@gmail.com',
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppButtonStyles.secondaryButton,
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required String value,
      }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: AppTextStyles.bodyLarge),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: Icon(Icons.content_copy, size: 20, color: AppColors.primary),
        onTap: () => _copyToClipboard(context, value, title),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String type) {
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type скопирован в буфер обмена'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AppColors.primary,
      ),
    );

    Navigator.pop(context); // Закрываем bottom sheet после копирования
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Политика конфиденциальности',
                  style: AppTextStyles.headerSmall,
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(color: AppColors.outline),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPolicySection(
                      '1. Сбор информации',
                      'Мы собираем только необходимую информацию для предоставления услуг: '
                          'контактные данные, адреса вывоза мусора, история заказов.',
                    ),
                    SizedBox(height: 16),
                    _buildPolicySection(
                      '2. Использование данных',
                      'Ваши данные используются исключительно для: '
                          '- Обработки заказов\n'
                          '- Связи с вами\n'
                          '- Улучшения сервиса\n'
                          '- Отправки уведомлений',
                    ),
                    SizedBox(height: 16),
                    _buildPolicySection(
                      '3. Защита данных',
                      'Мы используем современные методы шифрования и защиты данных. '
                          'Ваша информация хранится на защищенных серверах.',
                    ),
                    SizedBox(height: 16),
                    _buildPolicySection(
                      '4. Передача данных третьим лицам',
                      'Мы не передаем ваши персональные данные третьим лицам, '
                          'за исключением случаев, требуемых законодательством.',
                    ),
                    SizedBox(height: 16),
                    _buildPolicySection(
                      '5. Ваши права',
                      'Вы можете в любой момент:\n'
                          '- Запросить доступ к вашим данным\n'
                          '- Исправить неточности\n'
                          '- Удалить ваш аккаунт\n'
                          '- Отозвать согласие на обработку',
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Дата последнего обновления: 23.10.2025',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppButtonStyles.primaryButton,
                onPressed: () => Navigator.pop(context),
                child: Text('Понятно'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text(content, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}