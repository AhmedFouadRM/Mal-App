import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masroofy/core/strings/string_manager.dart';
import 'package:masroofy/core/theme/app_dimensions.dart';
import 'package:masroofy/core/theme/masroofy_colors.dart';
import 'package:masroofy/core/utils/currency_utils.dart';
import 'package:masroofy/features/settings/presentation/widgets/currency_list.dart';
import 'package:masroofy/shared/settings/settings_cubit.dart';
import 'package:masroofy/shared/widgets/aura_background.dart';
import 'package:masroofy/shared/widgets/brand.dart';
import 'package:masroofy/shared/widgets/glass_bottom_bar.dart';

/// First launch: the one onboarding step (Settings PRD → First Launch). Shows
/// the currency list with EGP preselected; Continue stores the choice, and the
/// router redirect then opens the app.
class FirstLaunchScreen extends StatefulWidget {
  const FirstLaunchScreen({super.key});

  @override
  State<FirstLaunchScreen> createState() => _FirstLaunchScreenState();
}

class _FirstLaunchScreenState extends State<FirstLaunchScreen> {
  late Currency _selected = context.read<SettingsCubit>().state.currency;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = MasroofyColors.of(context);
    return AuraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          // Inside the Scaffold, so the bottom padding includes the bar.
          child: Builder(
            builder: (context) => ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.xxl,
                AppSpacing.screen,
                MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
              ),
              children: [
                const _Brand(),
                const SizedBox(height: AppSpacing.md),
                Text(StringManager.firstLaunchTitle, style: text.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(StringManager.firstLaunchHint, style: text.bodyMedium!.copyWith(color: colors.textSecondary)),
                const SizedBox(height: AppSpacing.lg),
                CurrencyList(selected: _selected, onSelected: (currency) => setState(() => _selected = currency)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: GlassBottomBar(
          child: FilledButton(
            onPressed: () => unawaited(context.read<SettingsCubit>().completeFirstLaunch(_selected)),
            child: Text(StringManager.continueLabel),
          ),
        ),
      ),
    );
  }
}

/// The single-colour glyph and the wordmark above the title (Figma 41:1007):
/// the first screen after the splash introduces the app.
class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        BrandGlyphMono(height: 30),
        SizedBox(width: 8),
        BrandWordmark(height: 30),
      ],
    );
  }
}
