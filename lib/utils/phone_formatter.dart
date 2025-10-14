class PhoneFormatter {
  static String formatPhone(String phone) {
    // Удаляем все нецифровые символы
    String digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Если номер начинается с 7 или 8, оставляем 11 цифр, иначе 10
    if (digits.startsWith('7') || digits.startsWith('8')) {
      digits = digits.length > 11 ? digits.substring(0, 11) : digits;
    } else {
      digits = digits.length > 10 ? digits.substring(0, 10) : digits;
    }

    if (digits.isEmpty) return '';

    // Форматируем номер
    if (digits.startsWith('7') || digits.startsWith('8')) {
      if (digits.length == 1) return '+7';
      if (digits.length <= 4) return '+7 (${digits.substring(1)}';
      if (digits.length <= 7) return '+7 (${digits.substring(1, 4)}) ${digits.substring(4)}';
      if (digits.length <= 9) return '+7 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
      return '+7 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7, 9)}-${digits.substring(9)}';
    } else {
      if (digits.length <= 3) return '+7 ($digits';
      if (digits.length <= 6) return '+7 (${digits.substring(0, 3)}) ${digits.substring(3)}';
      if (digits.length <= 8) return '+7 (${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
      return '+7 (${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, 8)}-${digits.substring(8)}';
    }
  }

  static String cleanPhone(String formattedPhone) {
    String digits = formattedPhone.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.startsWith('7') || digits.startsWith('8')) {
      return digits.length > 1 ? '7${digits.substring(1)}' : digits;
    } else {
      return digits.isNotEmpty ? '7$digits' : digits;
    }
  }

  static bool isValidPhone(String formattedPhone) {
    String clean = cleanPhone(formattedPhone);
    return clean.length == 11 && clean.startsWith('79');
  }
}