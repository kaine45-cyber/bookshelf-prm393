import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Public first screen (logged out).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Strings.appName,
        actions: [
          AppButton(
            label: Strings.login,
            variant: AppButtonVariant.onDark,
            compact: true,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
          AppButton(
            label: Strings.register,
            variant: AppButtonVariant.onDark,
            compact: true,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.sm),
              const Icon(Icons.auto_stories_rounded,
                  size: 64, color: AppColors.primary),
              const SizedBox(height: AppSpacing.md),
              const Text(
                Strings.appName,
                style: AppText.display,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                Strings.appDescription,
                style: AppText.muted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              const _FeatureCard(
                icon: Icons.collections_bookmark_outlined,
                title: 'Track your books',
                text: 'Keep a private list of the books you own or want to read.',
              ),
              const SizedBox(height: AppSpacing.md),
              const _FeatureCard(
                icon: Icons.view_agenda_outlined,
                title: 'Sort by status',
                text: 'Group your books into To Read, Reading and Finished, '
                    'and filter them by genre.',
              ),
              const SizedBox(height: AppSpacing.md),
              const _FeatureCard(
                icon: Icons.star_outline_rounded,
                title: 'Rate your favorites',
                text: 'Give each book a rating from 0 to 5 and star the ones '
                    'you love.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
            ),
            child: Icon(icon, color: AppColors.primaryDark),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.section),
                const SizedBox(height: AppSpacing.xs),
                Text(text, style: AppText.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
