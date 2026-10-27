import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../state/books_controller.dart';
import 'app_button.dart';
import 'app_card.dart';
import 'app_inputs.dart';

/// Genre filter, status filter, favorites-only switch, search box, Clear.
/// Every change applies immediately.
class FilterBar extends StatefulWidget {
  const FilterBar({super.key});

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: context.read<BooksController>().query);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clear(BooksController c) {
    _search.clear();
    c.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<BooksController>();

    final genre = AppSelect(
      label: Strings.genre,
      placeholder: Strings.all,
      options: BookOptions.genres,
      value: c.genre,
      onChanged: c.setGenre,
    );
    final status = AppSelect(
      label: Strings.status,
      placeholder: Strings.all,
      options: BookOptions.statuses,
      value: c.status,
      onChanged: c.setStatus,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(Strings.filters, style: AppText.section),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _search,
            label: Strings.search,
            hint: Strings.searchHint,
            icon: Icons.search,
            onChanged: c.setQuery,
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 300) {
                return Row(
                  children: [
                    Expanded(child: genre),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: status),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  genre,
                  const SizedBox(height: AppSpacing.md),
                  status,
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Switch(
                value: c.favoritesOnly,
                onChanged: c.setFavoritesOnly,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () => c.setFavoritesOnly(!c.favoritesOnly),
                  child: const Text(Strings.favoritesOnly, style: AppText.body),
                ),
              ),
              AppButton(
                label: Strings.clear,
                icon: Icons.clear_all,
                variant: AppButtonVariant.outline,
                compact: true,
                onPressed: () => _clear(c),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
