import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../models/book.dart';
import '../state/books_controller.dart';
import 'app_card.dart';

/// Describes the books currently shown (after filters and search).
class SummaryPanel extends StatelessWidget {
  const SummaryPanel({super.key, required this.books});

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    final favorites = books.where((b) => b.favorite).length;
    final breakdown = BooksController.statusBreakdown(books);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(Strings.summary, style: AppText.section),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _Stat(icon: Icons.menu_book, text: 'Books: ${books.length}'),
              _Stat(icon: Icons.star_rounded, text: 'Favorites: $favorites'),
            ],
          ),
          if (breakdown.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            for (final entry in breakdown)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    AppTag.status(entry.key),
                    const Spacer(),
                    Text('${entry.value}', style: AppText.section),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryDark),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
