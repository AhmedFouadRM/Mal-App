import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:masroofy/app/routes.dart';
import 'package:masroofy/core/domain/money.dart';
import 'package:masroofy/features/wallets/domain/entities/wallet.dart';
import 'package:masroofy/features/wallets/domain/entities/wallet_summary.dart';
import 'package:masroofy/shared/wallets/wallet_switcher.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/router_host.dart';

final _epoch = DateTime.utc(2026);

WalletSummary _wallet(int id, {String? name}) => WalletSummary(
  wallet: Wallet(
    id: id,
    seedKey: id == 1 ? 'me' : null,
    name: id == 1 ? null : name,
    icon: id == 1 ? 'person' : 'child',
    color: 0xFF059669,
    sortOrder: id,
    createdAt: _epoch,
    updatedAt: _epoch,
  ),
  balance: const Money(10000),
  transactionCount: 0,
  transferCount: 0,
  templateCount: 0,
);

void main() {
  late MockSettingsCubit settings;
  late List<String> opened;

  setUp(() {
    settings = MockSettingsCubit();
    opened = [];
  });

  Future<void> pump(WidgetTester tester, List<WalletSummary> wallets, {int? viewedId}) => pumpApp(
    tester,
    RouterHost(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            appBar: AppBar(
              title: WalletSwitcher(wallets: wallets, fallbackTitle: 'Transactions'),
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.newWallet,
          builder: (context, _) {
            opened.add(RoutePaths.newWallet);
            return const Text('wallet form');
          },
        ),
      ],
    ),
    settings: testSettings(defaultWalletId: 1, viewedWalletId: viewedId),
    settingsCubit: settings,
  );

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.byIcon(Symbols.expand_more_rounded));
    await tester.pumpAndSettle();
  }

  group('All wallets', () {
    testWidgets('is offered when there is more than one wallet', (tester) async {
      await pump(tester, [_wallet(1), _wallet(2, name: 'Son')], viewedId: 1);
      await openSheet(tester);

      expect(find.text('All wallets'), findsOneWidget);
    });

    testWidgets('is not offered with a single wallet', (tester) async {
      await pump(tester, [_wallet(1)], viewedId: 1);
      await openSheet(tester);

      expect(find.text('All wallets'), findsNothing);
      // The one wallet is listed, and checked.
      expect(find.text('My wallet'), findsNWidgets(2), reason: 'the title and the sheet row');
      expect(find.byIcon(Symbols.check_rounded), findsOneWidget);
    });

    testWidgets('with a single wallet viewed as All wallets, the title names that wallet', (tester) async {
      await pump(tester, [_wallet(1)]);

      expect(find.text('All wallets'), findsNothing);
      expect(find.text('My wallet'), findsOneWidget);

      await openSheet(tester);
      expect(find.byIcon(Symbols.check_rounded), findsOneWidget, reason: 'the only wallet is the one viewed');
    });
  });

  group('Create new wallet', () {
    testWidgets('ends the list, after every wallet', (tester) async {
      await pump(tester, [_wallet(1), _wallet(2, name: 'Son')], viewedId: 1);
      await openSheet(tester);

      expect(find.text('Create new wallet'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Create new wallet')).dy,
        greaterThan(tester.getTopLeft(find.text('Son')).dy),
      );
    });

    testWidgets('closes the sheet and opens the wallet form, leaving the viewed wallet alone', (tester) async {
      await pump(tester, [_wallet(1)], viewedId: 1);
      await openSheet(tester);

      await tester.tap(find.text('Create new wallet'));
      await tester.pumpAndSettle();

      expect(opened, [RoutePaths.newWallet]);
      expect(find.text('wallet form'), findsOneWidget);
      expect(find.text('Create new wallet'), findsNothing, reason: 'the sheet closed');
      verifyNever(() => settings.setViewedWallet(any()));
    });

    testWidgets('is in Arabic too', (tester) async {
      await pumpApp(
        tester,
        Scaffold(appBar: AppBar(title: WalletSwitcher(wallets: [_wallet(1)], fallbackTitle: ''))),
        locale: const Locale('ar'),
        settings: testSettings(defaultWalletId: 1, viewedWalletId: 1),
      );
      await openSheet(tester);

      expect(find.text('إنشاء محفظة جديدة'), findsOneWidget);
    });
  });
}
