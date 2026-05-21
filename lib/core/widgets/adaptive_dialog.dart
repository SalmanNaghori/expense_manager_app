import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Configuration for individual interactive actions inside [AdaptiveDialog].
class AdaptiveDialogAction {
  /// The contents inside the action button (usually a Text widget).
  final Widget child;

  /// Trigger callback fired when the action is clicked/tapped.
  final VoidCallback onPressed;

  /// Highlights the action as destructive (rendered as red on iOS/Android).
  final bool isDestructive;

  /// Highlights the action as the standard primary option (rendered bold on iOS).
  final bool isDefaultAction;

  AdaptiveDialogAction({
    required this.child,
    required this.onPressed,
    this.isDestructive = false,
    this.isDefaultAction = false,
  });
}

/// **Core Layer - Platform Adaptive Alert Dialogs**
/// 
/// Serves as a static helper wrapper to spawn native Material 3 AlertDialogs 
/// or CupertinoAlertDialogs seamlessly depending on active OS environments.
class AdaptiveDialog {
  /// Displays the adaptive alert dialog and yields selected responses.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    required List<AdaptiveDialogAction> actions,
  }) {
    final platform = Theme.of(context).platform;
    final isCupertino = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (isCupertino) {
      return showCupertinoDialog<T>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: title,
            ),
            content: content,
            actions: actions.map((action) {
              return CupertinoDialogAction(
                onPressed: action.onPressed,
                isDestructiveAction: action.isDestructive,
                isDefaultAction: action.isDefaultAction,
                child: action.child,
              );
            }).toList(),
          );
        },
      );
    } else {
      return showDialog<T>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            title: title,
            content: content,
            actions: actions.map((action) {
              return TextButton(
                onPressed: action.onPressed,
                style: TextButton.styleFrom(
                  foregroundColor: action.isDestructive
                      ? Theme.of(context).colorScheme.error
                      : action.isDefaultAction
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                child: action.child,
              );
            }).toList(),
          );
        },
      );
    }
  }
}
