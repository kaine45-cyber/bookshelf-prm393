import 'constants.dart';

/// Shared by Login, Register, the Add Book form and the Detail edit form.
class Validators {
  Validators._();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return Strings.emailRequired;
    if (!_emailPattern.hasMatch(v)) return Strings.emailInvalid;
    return null;
  }

  /// Login only checks that a password was typed.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return Strings.passwordRequired;
    return null;
  }

  static String? registerPassword(String? value) {
    if (value == null || value.isEmpty) return Strings.passwordRequired;
    if (value.length < Limits.passwordMin) return Strings.passwordTooShort;
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() password) {
    return (String? value) {
      if (value == null || value.isEmpty) return Strings.confirmRequired;
      if (value != password()) return Strings.passwordsDoNotMatch;
      return null;
    };
  }

  static String? title(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return Strings.titleRequired;
    if (v.length > Limits.titleMax) return Strings.titleTooLong;
    return null;
  }

  static String? author(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return Strings.authorRequired;
    if (v.length > Limits.authorMax) return Strings.authorTooLong;
    return null;
  }

  static String? genre(String? value) {
    if (value == null || !BookOptions.genres.contains(value)) {
      return Strings.genreRequired;
    }
    return null;
  }

  static String? status(String? value) {
    if (value == null || !BookOptions.statuses.contains(value)) {
      return Strings.statusRequired;
    }
    return null;
  }

  /// Optional: only checked when something was typed.
  static String? rating(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null || n < Limits.ratingMin || n > Limits.ratingMax) {
      return Strings.ratingInvalid;
    }
    return null;
  }

  static String? notes(String? value) {
    final v = value?.trim() ?? '';
    if (v.length > Limits.notesMax) return Strings.notesTooLong;
    return null;
  }
}
