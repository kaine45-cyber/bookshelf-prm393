import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/book.dart';
import 'app_card.dart';

/// Favorite star button, used in the list and on the Detail screen.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.favorite,
    required this.onPressed,
  });

  final bool favorite;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: favorite ? 'Remove from favorites' : 'Add to favorites',
      onPressed: onPressed,
      icon: Icon(
        favorite ? Icons.star_rounded : Icons.star_outline_rounded,
        color: favorite ? AppColors.star : AppColors.textMuted,
        size: 28,
      ),
    );
  }
}

class BookTile extends StatelessWidget {
  const BookTile({
    super.key,
    required this.book,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final Book book;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: AppText.section),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(Icons.person_outline,
                          size: 16, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(child: Text(book.author, style: AppText.muted)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    AppTag(label: book.genre),
                    AppTag.status(book.status),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              FavoriteButton(
                favorite: book.favorite,
                onPressed: onToggleFavorite,
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}
