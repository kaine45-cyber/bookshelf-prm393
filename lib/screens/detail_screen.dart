import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../models/book.dart';
import '../services/book_repository.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/book_form_fields.dart';
import '../widgets/book_tile.dart';

/// Protected screen: one book's details, edit and delete.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.bookId});

  final String bookId;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final BookRepository _repo;
  late String _id;
  late Stream<Book?> _stream;
  Book? _last;

  final _data = BookFormData();
  var _formKey = GlobalKey<FormState>();
  bool _editing = false;
  bool _submitted = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = context.read<BookRepository>();
    _id = widget.bookId;
    _stream = _repo.watchBook(_id);
  }

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  void _startEdit(Book book) {
    _data.fillFrom(book);
    setState(() {
      _editing = true;
      _submitted = false;
      _error = null;
      _formKey = GlobalKey<FormState>();
    });
  }

  void _cancelEdit() {
    FocusScope.of(context).unfocus();
    setState(() {
      _editing = false;
      _error = null;
    });
  }

  Future<void> _save(Book book) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _submitted = true;
      _error = null;
    });
    if (!_formKey.currentState!.validate()) return;

    final input = _data.toInput();
    setState(() => _busy = true);
    try {
      final newId = await _repo.updateBook(book, input);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _editing = false;
        _last = book.copyWithInput(input, id: newId);
        if (newId != _id) {
          _id = newId;
          _stream = _repo.watchBook(newId);
        }
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.message ?? e.code;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = '$e';
      });
    }
  }

  Future<void> _toggleFavorite(Book book) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _repo.toggleFavorite(book);
    } on FirebaseException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
    }
  }

  Future<void> _delete(Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete book'),
        content: Text('Delete "${book.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(Strings.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(Strings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _repo.deleteBook(book.id);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.message ?? e.code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: Strings.detail),
      body: StreamBuilder<Book?>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError && !_busy) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: FormMessage.error('${snapshot.error}'),
            );
          }

          Book? book;
          if (snapshot.connectionState == ConnectionState.waiting || _busy) {
            book = _last;
          } else {
            book = snapshot.data;
          }
          if (book != null) _last = book;

          if (book == null) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingView();
            }
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text('This book no longer exists.', style: AppText.muted),
              ),
            );
          }

          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _editing ? _buildEdit(book) : _buildView(book),
            ),
          );
        },
      ),
    );
  }

  Widget _buildView(Book book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(book.title, style: AppText.title)),
                  FavoriteButton(
                    favorite: book.favorite,
                    onPressed: _busy ? null : () => _toggleFavorite(book),
                  ),
                ],
              ),
              const Divider(height: AppSpacing.xl),
              _Field(label: Strings.title, value: book.title),
              _Field(label: Strings.author, value: book.author),
              _Field(label: Strings.genre, child: AppTag(label: book.genre)),
              _Field(label: Strings.status, child: AppTag.status(book.status)),
              _Field(
                label: Strings.rating,
                value: book.rating == null ? 'Not rated' : '${book.rating}',
              ),
              _Field(
                label: Strings.notes,
                value: book.notes.isEmpty ? 'No notes' : book.notes,
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: Strings.edit,
                icon: Icons.edit_outlined,
                variant: AppButtonVariant.outline,
                onPressed: _busy ? null : () => _startEdit(book),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: Strings.delete,
                icon: Icons.delete_outline,
                variant: AppButtonVariant.danger,
                loading: _busy,
                onPressed: () => _delete(book),
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          FormMessage.error(_error!),
        ],
      ],
    );
  }

  Widget _buildEdit(Book book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Edit book', style: AppText.section),
              const SizedBox(height: AppSpacing.lg),
              Form(
                key: _formKey,
                autovalidateMode: _submitted
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: BookFormFields(data: _data, enabled: !_busy),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: Strings.cancel,
                variant: AppButtonVariant.outline,
                onPressed: _busy ? null : _cancelEdit,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: Strings.save,
                icon: Icons.check,
                loading: _busy,
                onPressed: () => _save(book),
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          FormMessage.error(_error!),
        ],
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, this.value, this.child, this.last = false});

  final String label;
  final String? value;
  final Widget? child;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.label),
          const SizedBox(height: AppSpacing.xs),
          child ?? Text(value ?? '', style: AppText.body),
        ],
      ),
    );
  }
}
