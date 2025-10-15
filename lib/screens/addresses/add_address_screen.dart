import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../services/address_service.dart';
import '../../services/network_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/button_styles.dart';
import '../../theme/input_styles.dart';
import 'yandex_map_address_screen.dart';
import '../../widgets/network_status_banner.dart';

class AddAddressScreen extends StatefulWidget {
  final String userId;

  const AddAddressScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  double _latitude = 0.0;
  double _longitude = 0.0;
  String _addressText = '';
  bool _hasLocation = false;

  @override
  Widget build(BuildContext context) {
    final networkService = Provider.of<NetworkService>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Добавить адрес'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Column(
        children: [
          // Баннер сети
          if (!networkService.isConnected) NetworkStatusBanner(),

          // Основной контент
          Expanded(
            child: SingleChildScrollView(
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
                                Text('Выбор адреса', style: AppTextStyles.bodyLarge),
                              ],
                            ),
                            SizedBox(height: 12),
                            if (!_hasLocation)
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: AppButtonStyles.primaryButton.copyWith(
                                    backgroundColor: MaterialStateProperty.all(
                                      networkService.isConnected ? AppColors.primary : AppColors.secondary,
                                    ),
                                  ),
                                  onPressed: networkService.isConnected ? _selectAddressOnMap : null,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.map, size: 20),
                                      SizedBox(width: 8),
                                      Text('Выбрать на карте'),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Выбранный адрес:',
                                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    _addressText,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Широта: ${_latitude.toStringAsFixed(6)}',
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Долгота: ${_longitude.toStringAsFixed(6)}',
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: networkService.isConnected ? _selectAddressOnMap : null,
                                      child: Text('Изменить адрес'),
                                    ),
                                  ),
                                ],
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
                        style: AppButtonStyles.primaryButton.copyWith(
                          backgroundColor: MaterialStateProperty.all(
                            networkService.isConnected ? AppColors.primary : AppColors.secondary,
                          ),
                        ),
                        onPressed: networkService.isConnected ? _saveAddress : null,
                        child: Text('Сохранить адрес'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAddressOnMap() async {
    final networkService = Provider.of<NetworkService>(context, listen: false);

    // Проверяем сеть перед открытием карты
    if (!networkService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Нет подключения к интернету')),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YandexMapAddressScreen(
          onAddressSelected: (lat, lng, address) {
            setState(() {
              _latitude = lat;
              _longitude = lng;
              _addressText = address;
              _hasLocation = true;
            });
          },
        ),
      ),
    );
  }

  void _saveAddress() async {
    final networkService = Provider.of<NetworkService>(context, listen: false);

    // Проверяем сеть перед сохранением
    if (!networkService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Нет подключения к интернету')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (!_hasLocation) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Пожалуйста, выберите адрес на карте')),
        );
        return;
      }

      final addressService = Provider.of<AddressService>(context, listen: false);

      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

      final address = Address(
        id: tempId,
        userId: widget.userId,
        title: _titleController.text,
        latitude: _latitude,
        longitude: _longitude,
        addressText: _addressText,
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
    super.dispose();
  }
}