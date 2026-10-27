import 'package:flutter/material.dart';

/// One palette, one spacing scale, one set of text styles for every screen.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF3F51B5);
  static const primaryDark = Color(0xFF283593);
  static const primarySoft = Color(0xFFE8EAF6);
  static const primaryDisabled = Color(0xFF9FA8DA);
  static const background = Color(0xFFF4F5FA);
  static const surface = Colors.white;
  static const border = Color(0xFFDDE0EC);
  static const text = Color(0xFF1F2333);
  static const textMuted = Color(0xFF6B7085);
  static const success = Color(0xFF2E7D32);
  static const successSoft = Color(0xFFE8F5E9);
  static const danger = Color(0xFFC62828);
  static const dangerSoft = Color(0xFFFFEBEE);
  static const star = Color(0xFFFFA000);
  static const blue = Color(0xFF1565C0);
  static const blueSoft = Color(0xFFE3F2FD);
  static const orange = Color(0xFFE65100);
  static const orangeSoft = Color(0xFFFFF3E0);
}

class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const radius = 12.0;
}

class AppText {
  AppText._();

  static const display = TextStyle(
      fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.text);
  static const title = TextStyle(
      fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text);
  static const section = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text);
  static const body = TextStyle(fontSize: 15, color: AppColors.text);
  static const muted = TextStyle(fontSize: 14, color: AppColors.textMuted);
  static const label = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
      );

  static OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        borderSide: BorderSide(color: color, width: width),
      );

  /// The one input style used by every text field and dropdown.
  static InputDecoration input(
    String label, {
    String? hint,
    IconData? icon,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
      errorMaxLines: 3,
      prefixIcon: icon == null ? null : Icon(icon, size: 20),
      filled: true,
      fillColor: AppColors.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: _border(AppColors.border),
      enabledBorder: _border(AppColors.border),
      disabledBorder: _border(AppColors.border),
      focusedBorder: _border(AppColors.primary, 1.6),
      errorBorder: _border(AppColors.danger),
      focusedErrorBorder: _border(AppColors.danger, 1.6),
    );
  }
}

/// The one app bar style used by every screen.
AppBar buildAppBar({
  required String title,
  List<Widget>? actions,
  PreferredSizeWidget? bottom,
}) {
  return AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    actions: actions,
    bottom: bottom,
  );
}
