import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/address_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/button_styles.dart';
import 'add_address_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final addressService = Provider.of<AddressService>(context);
    final user = authService.currentUser;

    if (user != null && addressService.addresses.isEmpty && !addressService.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        addressService.loadUserAddresses(user.id);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Профиль'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUserCard(user),
            SizedBox(height: 24),
            _buildAddressesSection(context, addressService, user.id),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(User user) {
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
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppColors.onPrimary,
                    size: 30,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: AppTextStyles.headerMedium,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '+7 ${user.phone}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  'Зарегистрирован:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                Spacer(),
                Text(
                  '${user.createdAt.day.toString().padLeft(2, '0')}.${user.createdAt.month.toString().padLeft(2, '0')}.${user.createdAt.year}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressesSection(BuildContext context, AddressService addressService, String userId) {
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
                Icon(Icons.location_on, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Мои адреса',
                  style: AppTextStyles.headerSmall,
                ),
              ],
            ),
            SizedBox(height: 16),
            if (addressService.isLoading)
              Center(child: CircularProgressIndicator())
            else if (addressService.addresses.isEmpty)
              _buildEmptyAddresses()
            else
              _buildAddressesList(context, addressService, userId),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: AppButtonStyles.primaryButton,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddAddressScreen(userId: userId),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: 8),
                    Text('Добавить адрес'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAddresses() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.location_off, size: 50, color: AppColors.secondary),
          SizedBox(height: 12),
          Text(
            'Адреса не добавлены',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary),
          ),
          SizedBox(height: 8),
          Text(
            'Добавьте адрес для заказа вывоза мусора',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressesList(BuildContext context, AddressService addressService, String userId) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: addressService.addresses.length,
      itemBuilder: (context, index) {
        final address = addressService.addresses[index];
        return _buildAddressCard(context, address, addressService, userId);
      },
    );
  }

  Widget _buildAddressCard(BuildContext context, Address address, AddressService addressService, String userId) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home, size: 20, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.title,
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 20, color: AppColors.error),
                  onPressed: () => _showDeleteDialog(context, address, addressService, userId),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              address.addressText,
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Добавлен: ${address.createdAt.day.toString().padLeft(2, '0')}.${address.createdAt.month.toString().padLeft(2, '0')}.${address.createdAt.year}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Address address, AddressService addressService, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить адрес?'),
        content: Text('Вы уверены, что хотите удалить адрес "${address.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await addressService.deleteAddress(address.id, userId);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Адрес удален')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка при удалении адреса')),
                );
              }
            },
            child: Text('Удалить', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}