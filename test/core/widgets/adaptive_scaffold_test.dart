import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_manager_app/core/widgets/adaptive_scaffold.dart';

void main() {
  testWidgets('AdaptiveScaffold renders Material 3 Scaffold on Android platform', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: const AdaptiveScaffold(
          title: Text('Material Title'),
          body: Text('Material Body'),
        ),
      ),
    );

    // Verify Material Scaffold and AppBar are mounted
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(CupertinoPageScaffold), findsNothing);
    expect(find.byType(CupertinoNavigationBar), findsNothing);
    
    expect(find.text('Material Title'), findsOneWidget);
    expect(find.text('Material Body'), findsOneWidget);
  });

  testWidgets('AdaptiveScaffold renders CupertinoPageScaffold on iOS platform', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: const AdaptiveScaffold(
          title: Text('Cupertino Title'),
          body: Text('Cupertino Body'),
        ),
      ),
    );

    // Verify CupertinoPageScaffold and CupertinoNavigationBar are mounted
    expect(find.byType(CupertinoPageScaffold), findsOneWidget);
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(find.byType(Scaffold), findsNothing);
    expect(find.byType(AppBar), findsNothing);
    
    expect(find.text('Cupertino Title'), findsOneWidget);
    expect(find.text('Cupertino Body'), findsOneWidget);
  });
}
