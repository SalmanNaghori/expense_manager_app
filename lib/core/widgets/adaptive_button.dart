import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The styling options for adaptive buttons.
enum AdaptiveButtonType {
  filled,
  text,
  outlined,
}

/// **Core Layer - Platform Adaptive Button**
/// 
/// Switches dynamically between Material 3 button types and CupertinoButton 
/// depending on the operating system.
class AdaptiveButton extends StatelessWidget {
  /// The contents inside the button (usually a Text or a Row containing Icon and Text).
  final Widget child;

  /// Trigger callback fired when user clicks/taps the button.
  final VoidCallback? onPressed;

  /// The rendering archetype style (filled, text, or outlined).
  final AdaptiveButtonType type;

  /// Custom padding spacing inside the button box.
  final EdgeInsetsGeometry? padding;

  /// Custom color override for the button background (filled) or text (text/outlined).
  final Color? color;

  /// Custom border radius.
  final double borderRadius;

  const AdaptiveButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.type = AdaptiveButtonType.filled,
    this.padding,
    this.color,
    this.borderRadius = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isCupertino = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (isCupertino) {
      switch (type) {
        case AdaptiveButtonType.filled:
          return CupertinoButton.filled(
            padding: padding,
            borderRadius: BorderRadius.circular(borderRadius),
            onPressed: onPressed,
            child: child,
          );
        case AdaptiveButtonType.text:
          return CupertinoButton(
            padding: padding ?? EdgeInsets.zero,
            onPressed: onPressed,
            child: child,
          );
        case AdaptiveButtonType.outlined:
          // Cupertino doesn't have a direct native outlined button, so we build a sleek border style
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: color ?? CupertinoTheme.of(context).primaryColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: CupertinoButton(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onPressed: onPressed,
              child: child,
            ),
          );
      }
    } else {
      switch (type) {
        case AdaptiveButtonType.filled:
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: padding,
              backgroundColor: color ?? Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            onPressed: onPressed,
            child: child,
          );
        case AdaptiveButtonType.text:
          return TextButton(
            style: TextButton.styleFrom(
              padding: padding,
              foregroundColor: color ?? Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            onPressed: onPressed,
            child: child,
          );
        case AdaptiveButtonType.outlined:
          return OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: padding,
              foregroundColor: color ?? Theme.of(context).colorScheme.primary,
              side: BorderSide(
                color: color ?? Theme.of(context).colorScheme.outline,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            onPressed: onPressed,
            child: child,
          );
      }
    }
  }
}
