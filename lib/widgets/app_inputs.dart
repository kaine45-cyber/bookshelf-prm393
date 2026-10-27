import 'package:flutter/material.dart';

import '../core/theme.dart';

/// The one text input used everywhere in the app.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.validator,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.minLines = 1,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final FormFieldValidator<String>? validator;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int minLines;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      enableSuggestions: !obscure,
      autocorrect: !obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      minLines: obscure ? 1 : minLines,
      maxLines: obscure ? 1 : maxLines,
      enabled: enabled,
      onChanged: onChanged,
      decoration: AppTheme.input(label, hint: hint, icon: icon),
    );
  }
}

/// Builds the dropdown inside an input-styled box. The first item is the
/// "empty" choice (value null) with [placeholder] as its text.
Widget _dropdownBox({
  required String label,
  required String placeholder,
  required List<String> options,
  required String? value,
  required ValueChanged<String?>? onChanged,
  String? errorText,
  bool mutedPlaceholder = true,
}) {
  final safeValue = options.contains(value) ? value : null;
  return InputDecorator(
    decoration: AppTheme.input(label, errorText: errorText),
    isEmpty: false,
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        value: safeValue,
        isExpanded: true,
        isDense: true,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: Text(
              placeholder,
              style: mutedPlaceholder ? AppText.muted : AppText.body,
            ),
          ),
          ...options.map(
            (o) => DropdownMenuItem<String?>(
              value: o,
              child: Text(o, style: AppText.body),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    ),
  );
}

/// Dropdown that takes part in a Form (validation, reset).
class AppDropdownField extends FormField<String?> {
  AppDropdownField({
    super.key,
    required String label,
    required String placeholder,
    required List<String> options,
    super.initialValue,
    super.validator,
    super.enabled,
    ValueChanged<String?>? onChanged,
  }) : super(
          builder: (field) => _dropdownBox(
            label: label,
            placeholder: placeholder,
            options: options,
            value: field.value,
            errorText: field.errorText,
            onChanged: field.widget.enabled
                ? (v) {
                    field.didChange(v);
                    onChanged?.call(v);
                  }
                : null,
          ),
        );
}

/// Dropdown controlled from outside (filters). null = [placeholder] ("All").
class AppSelect extends StatelessWidget {
  const AppSelect({
    super.key,
    required this.label,
    required this.placeholder,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String placeholder;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _dropdownBox(
      label: label,
      placeholder: placeholder,
      options: options,
      value: value,
      onChanged: onChanged,
      mutedPlaceholder: false, // "All" is a real choice, not a placeholder
    );
  }
}
