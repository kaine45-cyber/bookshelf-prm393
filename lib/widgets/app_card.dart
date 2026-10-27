import 'package:flutter/material.dart';

import '../core/theme.dart';

/// The one card used everywhere in the app.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius + 2),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Small rounded label (genre, status).
class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.color = AppColors.primaryDark,
    this.background = AppColors.primarySoft,
  });

  /// Coloured tag for a reading status.
  factory AppTag.status(String status) {
    switch (status) {
      case 'Reading':
        return AppTag(
            label: status,
            color: AppColors.orange,
            background: AppColors.orangeSoft);
      case 'Finished':
        return AppTag(
            label: status,
            color: AppColors.success,
            background: AppColors.successSoft);
      default:
        return AppTag(
            label: status,
            color: AppColors.blue,
            background: AppColors.blueSoft);
    }
  }

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

/// Success / error message shown on a form (below the submit button).
class FormMessage extends StatelessWidget {
  const FormMessage.error(this.text, {super.key}) : success = false;
  const FormMessage.success(this.text, {super.key}) : success = true;

  final String text;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final color = success ? AppColors.success : AppColors.danger;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: success ? AppColors.successSoft : AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(success ? Icons.check_circle : Icons.error_outline,
              color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
