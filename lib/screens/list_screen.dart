
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../models/book.dart';
import '../services/book_repository.dart';
import '../state/books_controller.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/book_form_fields.dart';
import '../widgets/book_tile.dart';
import '../widgets/filter_bar.dart';
import '../widgets/summary_panel.dart';
import 'detail_screen.dart';

/// Protected screen: the logged-in user's books.
class ListScreen extends StatelessWidget {
  const ListScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final books = context.watch<BooksController>();
    final ready = books.isReadyFor(user.uid);

    return Scaffold(
      appBar: buildAppBar(
        title: Strings.appName,
        actions: [
          AppButton(
            label: Strings.logout,
            icon: Icons.logout,
            variant: AppButtonVariant.onDark,
            compact: true,
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Container(
            width: double.infinity,
            color: AppColors.primaryDark,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(Icons.account_circle, color: Colors.white, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      user.email ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ready ? _ListBody(controller: books) : const LoadingView(),
    );
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({required this.controller});

  final BooksController controller;

  Future<void> _toggleFavorite(BuildContext context, Book book) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<BookRepository>().toggleFavorite(book);
    } on FirebaseException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = controller.visibleBooks;

    // A plain scroll view (not a lazy ListView) so the add form and the
    // search box keep their state while scrolling.
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AddBookCard(),
            const SizedBox(height: AppSpacing.md),
            const FilterBar(),
            const SizedBox(height: AppSpacing.md),
            SummaryPanel(books: visible),
            const SizedBox(height: AppSpacing.lg),
            if (controller.error != null) ...[
              FormMessage.error(controller.error!),
              const SizedBox(height: AppSpacing.md),
            ],
            if (visible.isEmpty)
              const _EmptyState()
            else
              for (final book in visible)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                  child: BookTile(
                    key: ValueKey(book.id),
                    book: book,
                    onToggleFavorite: () => _toggleFavorite(context, book),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(bookId: book.id),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Icon(Icons.menu_book_outlined, size: 48, color: AppColors.textMuted),
          SizedBox(height: AppSpacing.sm),
          Text(Strings.noBooksFound, style: AppText.section),
        ],
      ),
    );
  }
}

/// "Add a book" card at the top of the List screen.
class AddBookCard extends StatefulWidget {
  const AddBookCard({super.key});

  @override
  State<AddBookCard> createState() => _AddBookCardState();
}

class _AddBookCardState extends State<AddBookCard> {
  final _data = BookFormData();
  var _formKey = GlobalKey<FormState>();
  bool _expanded = true; // the form is visible when the List screen opens
  bool _submitted = false;
  bool _saving = false;
  bool _added = false;
  String? _error;

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  void _toggle() => setState(() => _expanded = !_expanded);

  void _onFormChanged() {
    if (_added) setState(() => _added = false);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _submitted = true;
      _error = null;
      _added = false;
    });
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _saving = true);
    try {
      await context.read<BookRepository>().addBook(uid, _data.toInput());
      if (!mounted) return;
      _data.clear();
      setState(() {
        _saving = false;
        _submitted = false;
        _added = true;
        _formKey = GlobalKey<FormState>(); // fresh, cleared form
      });
      // Also shown at the bottom of the screen, so it stays visible while
      // scrolling down to the new book in the list.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text(Strings.bookAdded),
          duration: Duration(seconds: 6),
        ));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.message ?? e.code;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            child: Row(
              children: [
                const Icon(Icons.library_add_outlined, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text(Strings.addBook, style: AppText.section),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: AppSpacing.lg),
            Form(
              key: _formKey,
              autovalidateMode: _submitted
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
              onChanged: _onFormChanged,
              child: BookFormFields(data: _data, enabled: !_saving),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: Strings.addBookButton,
              icon: Icons.add,
              expand: true,
              loading: _saving,
              onPressed: _submit,
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              FormMessage.error(_error!),
            ],
          ],
          if (_added) ...[
            const SizedBox(height: AppSpacing.md),
            const FormMessage.success(Strings.bookAdded),
          ],
        ],
      ),
    );
  }
}
