import 'package:flutter/material.dart';

import '../core/theme.dart';

enum AppButtonVariant { primary, outline, danger, text, onDark }

/// The one button used everywhere in the app.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final bool compact;

  bool get _filled =>
      variant == AppButtonVariant.primary || variant == AppButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final spinnerColor = _filled || variant == AppButtonVariant.onDark
        ? Colors.white
        : AppColors.primary;

    final Widget content = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: spinnerColor),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );

    final minimumSize = Size(expand ? double.infinity : 0, compact ? 40 : 48);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radius),
    );
    final padding = EdgeInsets.symmetric(horizontal: compact ? 12 : 18);
    final onTap = loading ? null : onPressed;

    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        final bg = variant == AppButtonVariant.primary
            ? AppColors.primary
            : AppColors.danger;
        return ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: Colors.white,
            disabledBackgroundColor: variant == AppButtonVariant.primary
                ? AppColors.primaryDisabled
                : AppColors.dangerSoft,
            disabledForegroundColor: Colors.white,
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
            elevation: 0,
          ),
          child: content,
        );
      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
          ),
          child: content,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
          ),
          child: content,
        );
      case AppButtonVariant.onDark:
        return TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            minimumSize: minimumSize,
            padding: padding,
            shape: shape,
          ),
          child: content,
        );
    }
  }
}
