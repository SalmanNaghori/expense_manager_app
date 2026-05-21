import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_manager_app/features/finance/presentation/widgets/antigravity_badge.dart';
import 'package:expense_manager_app/core/l10n/app_localizations.dart';

void main() {
  testWidgets('AntigravityBadge standard mode rendering test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(
          body: AntigravityBadge(
            isAntigravityActive: false,
            amount: 0.0,
            currency: 'USD',
          ),
        ),
      ),
    );

    // Use pump instead of pumpAndSettle since there's an active infinite animation controller
    await tester.pump();

    // Verify standard mode message displays correctly
    expect(find.text('Standard Mode: Expense will reduce balance.'), findsOneWidget);
    expect(find.text('⚡ ANTIGRAVITY STATUS: ACTIVE'), findsNothing);
  });
}
