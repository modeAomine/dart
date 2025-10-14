import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppInputStyles {
  static InputDecoration textField({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.secondary),
      hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.secondary.withOpacity(0.6)),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      filled: true,
      fillColor: AppColors.surface,
    );
  }
}