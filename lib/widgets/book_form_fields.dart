import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../core/validators.dart';
import '../models/book.dart';
import 'app_inputs.dart';

/// The values of the Add / Edit book form. Lives in the screen's State so the
/// typed text survives rebuilds (collapsing the card, saving, ...).
class BookFormData {
  final title = TextEditingController();
  final author = TextEditingController();
  final rating = TextEditingController();
  final notes = TextEditingController();
  String? genre;
  String? status;

  void fillFrom(Book b) {
    title.text = b.title;
    author.text = b.author;
    rating.text = b.rating?.toString() ?? '';
    notes.text = b.notes;
    genre = b.genre;
    status = b.status;
  }

  void clear() {
    title.clear();
    author.clear();
    rating.clear();
    notes.clear();
    genre = null;
    status = null;
  }

  /// Call only after the form validated.
  BookInput toInput() {
    final r = rating.text.trim();
    return BookInput(
      title: title.text.trim(),
      author: author.text.trim(),
      genre: genre!,
      status: status!,
      rating: r.isEmpty ? null : int.parse(r),
      notes: notes.text.trim(),
    );
  }

  void dispose() {
    title.dispose();
    author.dispose();
    rating.dispose();
    notes.dispose();
  }
}

/// The six book fields, shared by the Add Book form and the Detail edit mode
/// so both use the same validation rules and messages.
class BookFormFields extends StatelessWidget {
  const BookFormFields({super.key, required this.data, this.enabled = true});

  final BookFormData data;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.md);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: data.title,
          label: Strings.title,
          icon: Icons.menu_book_outlined,
          validator: Validators.title,
          enabled: enabled,
          textInputAction: TextInputAction.next,
        ),
        gap,
        AppTextField(
          controller: data.author,
          label: Strings.author,
          icon: Icons.person_outline,
          validator: Validators.author,
          enabled: enabled,
          textInputAction: TextInputAction.next,
        ),
        gap,
        AppDropdownField(
          label: Strings.genre,
          placeholder: Strings.chooseGenre,
          options: BookOptions.genres,
          initialValue: data.genre,
          validator: Validators.genre,
          enabled: enabled,
          onChanged: (v) => data.genre = v,
        ),
        gap,
        AppDropdownField(
          label: Strings.status,
          placeholder: Strings.chooseStatus,
          options: BookOptions.statuses,
          initialValue: data.status,
          validator: Validators.status,
          enabled: enabled,
          onChanged: (v) => data.status = v,
        ),
        gap,
        AppTextField(
          controller: data.rating,
          label: '${Strings.rating} (optional, 0-5)',
          icon: Icons.star_outline,
          validator: Validators.rating,
          enabled: enabled,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        gap,
        AppTextField(
          controller: data.notes,
          label: '${Strings.notes} (optional)',
          icon: Icons.notes,
          validator: Validators.notes,
          enabled: enabled,
          keyboardType: TextInputType.multiline,
          minLines: 2,
          maxLines: 5,
        ),
      ],
    );
  }
}
