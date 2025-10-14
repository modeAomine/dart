import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../services/address_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/button_styles.dart';
import '../../theme/input_styles.dart';

class AddAddressScreen extends StatefulWidget {
  final String userId;

  const AddAddressScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();

  double _latitude = 55.7558;
  double _longitude = 37.6173;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Добавить адрес'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Новый адрес',
                style: AppTextStyles.headerMedium,
              ),
              SizedBox(height: 8),
              Text(
                'Добавьте адрес для вывоза мусора',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: AppInputStyles.textField(
                  labelText: 'Название адреса',
                  hintText: 'Например: Дом, Работа, Квартира',
                  prefixIcon: Icon(Icons.title, color: AppColors.primary),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название адреса';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: AppInputStyles.textField(
                  labelText: 'Адрес',
                  hintText: 'Введите полный адрес',
                  prefixIcon: Icon(Icons.location_on, color: AppColors.primary),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите адрес';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.map, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('Координаты', style: AppTextStyles.bodyLarge),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Широта: ${_latitude.toStringAsFixed(6)}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Долгота: ${_longitude.toStringAsFixed(6)}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Для демонстрации используются координаты Москвы. В реальном приложении здесь будет карта.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: AppButtonStyles.primaryButton,
                  onPressed: _saveAddress,
                  child: Text('Сохранить адрес'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      final addressService = Provider.of<AddressService>(context, listen: false);

      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

      final address = Address(
        id: tempId,
        userId: widget.userId,
        title: _titleController.text,
        latitude: _latitude,
        longitude: _longitude,
        addressText: _addressController.text,
        createdAt: DateTime.now(),
      );

      final success = await addressService.addAddress(address);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Адрес успешно добавлен')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при добавлении адреса')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}