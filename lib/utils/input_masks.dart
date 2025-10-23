import 'package:flutter/services.dart';

class InputMasks {
  static final passportSeries = TextInputFormatter.withFunction(
        (oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
      if (text.length > 4) return oldValue;
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    },
  );

  static final passportNumber = TextInputFormatter.withFunction(
        (oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
      if (text.length > 6) return oldValue;
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    },
  );

  static final bankCardNumber = TextInputFormatter.withFunction(
        (oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'[^\d\s]'), '').replaceAll(' ', '');
      if (text.length > 16) return oldValue;

      final buffer = StringBuffer();
      for (int i = 0; i < text.length; i++) {
        if (i > 0 && i % 4 == 0) buffer.write(' ');
        buffer.write(text[i]);
      }

      return TextEditingValue(
        text: buffer.toString(),
        selection: TextSelection.collapsed(offset: buffer.length),
      );
    },
  );

  static final bankAccount = TextInputFormatter.withFunction(
        (oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
      if (text.length > 20) return oldValue;
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    },
  );

  static final dateMask = TextInputFormatter.withFunction(
        (oldValue, newValue) {
      final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
      if (text.length > 8) return oldValue;

      final buffer = StringBuffer();
      for (int i = 0; i < text.length; i++) {
        if (i == 2 || i == 4) buffer.write('.');
        buffer.write(text[i]);
      }

      return TextEditingValue(
        text: buffer.toString(),
        selection: TextSelection.collapsed(offset: buffer.length),
      );
    },
  );
}