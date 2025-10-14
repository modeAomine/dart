import 'package:flutter/material.dart';
import '../theme/input_styles.dart';
import '../utils/phone_formatter.dart';

class PhoneTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PhoneTextField({
    Key? key,
    required this.controller,
    this.labelText,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  _PhoneTextFieldState createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<PhoneTextField> {
  String _previousText = '';

  @override
  void initState() {
    super.initState();
    // Форматируем начальное значение если оно есть
    if (widget.controller.text.isNotEmpty) {
      widget.controller.text = PhoneFormatter.formatPhone(widget.controller.text);
    }
    _previousText = widget.controller.text;
  }

  void _onTextChanged(String text) {
    // Если текст стал короче (удаление символов), не форматируем
    if (text.length < _previousText.length) {
      _previousText = text;
      widget.onChanged?.call(text);
      return;
    }

    // Форматируем номер
    final formatted = PhoneFormatter.formatPhone(text);

    if (formatted != text) {
      widget.controller.value = widget.controller.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    _previousText = formatted;
    widget.onChanged?.call(formatted);
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите номер телефона';
    }

    final cleanPhone = PhoneFormatter.cleanPhone(value);
    if (cleanPhone.length != 11) {
      return 'Номер должен содержать 11 цифр';
    }

    if (!cleanPhone.startsWith('79')) {
      return 'Номер должен начинаться с 79';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: AppInputStyles.textField(
        labelText: widget.labelText ?? 'Номер телефона',
        prefixIcon: Icon(Icons.phone, color: Theme.of(context).primaryColor),
      ),
      keyboardType: TextInputType.phone,
      onChanged: _onTextChanged,
      validator: widget.validator ?? _defaultValidator,
    );
  }
}