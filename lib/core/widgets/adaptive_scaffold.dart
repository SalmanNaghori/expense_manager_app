import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// **Core Layer - Platform Adaptive Scaffolding**
/// 
/// Automatically toggles between Material 3 Scaffold and CupertinoPageScaffold 
/// based on the runtime operating system platform.
class AdaptiveScaffold extends StatelessWidget {
  /// The main widget displayed in the center of the navigation bar / app bar.
  final Widget title;

  /// The primary content window of the scaffolding layout.
  final Widget body;

  /// Optional widget displayed on the far left of the navigation / app bar.
  final Widget? leading;

  /// Optional list of interactive actions rendered on the far right of the navigation / app bar.
  final List<Widget>? actions;

  /// Optional floating action button (only rendered natively on Android/Material platforms).
  final Widget? floatingActionButton;

  /// Optional custom bottom navigation widget.
  final Widget? bottomNavigationBar;

  /// Optional color used for Scaffold window backgrounds.
  final Color? backgroundColor;

  /// Whether the body should resize automatically to avoid keyboard overlap.
  final bool resizeToAvoidBottomInset;

  const AdaptiveScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isCupertino = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (isCupertino) {
      Widget? trailing;
      if (actions != null && actions!.isNotEmpty) {
        trailing = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: actions!,
        );
      }

      return CupertinoPageScaffold(
        backgroundColor: backgroundColor ?? CupertinoTheme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        navigationBar: CupertinoNavigationBar(
          middle: title,
          leading: leading,
          trailing: trailing,
          backgroundColor: backgroundColor ?? CupertinoTheme.of(context).barBackgroundColor.withOpacity(0.9),
          border: const Border(
            bottom: BorderSide(
              color: CupertinoColors.separator,
              width: 0.5,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: body,
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: AppBar(
          title: title,
          leading: leading,
          actions: actions,
          elevation: 0,
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      );
    }
  }
}
