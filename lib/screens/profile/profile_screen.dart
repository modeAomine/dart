import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/address_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/button_styles.dart';
import '../addresses/add_address_screen.dart';
import '../../widgets/base_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _initialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialLoad) {
      _initialLoad = true;
      _loadAddresses();
    }
  }

  void _loadAddresses() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final addressService = Provider.of<AddressService>(context, listen: false);

    if (authService.currentUser != null &&
        addressService.addresses.isEmpty &&
        !addressService.isLoading) {
      addressService.loadUserAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final addressService = Provider.of<AddressService>(context);
    final user = authService.currentUser;

    // Автоматическая загрузка адресов при появлении пользователя
    if (user != null && addressService.addresses.isEmpty && !addressService.isLoading && _initialLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        addressService.loadUserAddresses();
      });
    }

    return BaseScaffold(
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
            _buildAddressesSection(context, addressService, user),
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
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Icon(Icons.person, color: AppColors.onPrimary, size: 30),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: AppTextStyles.headerMedium),
                      SizedBox(height: 4),
                      Text(user.email, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary)),
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
                Icon(Icons.person_pin, size: 20, color: AppColors.primary),
                SizedBox(width: 12),
                Text('ID пользователя:', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary)),
                Spacer(),
                Text(
                  user.id ?? 'Не указан',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressesSection(BuildContext context, AddressService addressService, User user) {
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
                Text('Мои адреса', style: AppTextStyles.headerSmall),
              ],
            ),
            SizedBox(height: 16),
            if (addressService.isLoading)
              Center(child: CircularProgressIndicator())
            else if (addressService.addresses.isEmpty)
              _buildEmptyAddresses()
            else
              _buildAddressesList(context, addressService),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: AppButtonStyles.primaryButton,
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddAddressScreen(userId: user.id.toString()))
                ),
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
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(Icons.location_off, size: 50, color: AppColors.secondary),
          SizedBox(height: 12),
          Text('Адреса не добавлены', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary)),
          SizedBox(height: 8),
          Text('Добавьте адрес для заказа вывоза мусора', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAddressesList(BuildContext context, AddressService addressService) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: addressService.addresses.length,
      itemBuilder: (context, index) {
        final address = addressService.addresses[index];
        return _buildAddressCard(context, address, addressService);
      },
    );
  }

  Widget _buildAddressCard(BuildContext context, Address address, AddressService addressService) {
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
                Expanded(child: Text(address.title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600))),
                IconButton(
                  icon: Icon(Icons.delete, size: 20, color: AppColors.error),
                  onPressed: () => _showDeleteDialog(context, address, addressService),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(address.addressText, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Address address, AddressService addressService) {
    if (address.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: адрес не имеет ID')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить адрес?'),
        content: Text('Вы уверены, что хотите удалить адрес "${address.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Отмена')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await addressService.deleteAddress(address.id!);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Адрес удален')));
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при удалении адреса')));
              }
            },
            child: Text('Удалить', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}