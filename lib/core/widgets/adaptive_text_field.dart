import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// **Core Layer - Platform Adaptive Input Fields**
/// 
/// Switches dynamically between standard Material 3 TextField (with InputDecorations) 
/// and CupertinoTextField based on the active operating system.
class AdaptiveTextField extends StatelessWidget {
  /// The input controller tracking active field values.
  final TextEditingController? controller;

  /// Temporary placeholder text (hint text).
  final String? placeholder;

  /// Top-aligned label header explaining the purpose of the input.
  final String? labelText;

  /// Optional prefix icon or widget.
  final Widget? prefix;

  /// Optional suffix icon or widget.
  final Widget? suffix;

  /// Type of virtual keyboard triggered (e.g. numeric, email, text).
  final TextInputType keyboardType;

  /// Custom text input actions (e.g. done, next).
  final TextInputAction? textInputAction;

  /// Obscure input characters (used for secure passwords).
  final bool obscureText;

  /// Formatter rules capping length or forcing numeric structures.
  final List<TextInputFormatter>? inputFormatters;

  /// Focus state tracker.
  final FocusNode? focusNode;

  /// Base text style inside the text area.
  final TextStyle? style;

  /// Maximum visible text lines.
  final int? maxLines;

  /// Trigger callback fired on character mutations.
  final ValueChanged<String>? onChanged;

  /// Trigger callback fired when user submits.
  final ValueChanged<String>? onSubmitted;

  const AdaptiveTextField({
    Key? key,
    this.controller,
    this.placeholder,
    this.labelText,
    this.prefix,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.inputFormatters,
    this.focusNode,
    this.style,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isCupertino = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (isCupertino) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (labelText != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
              child: Text(
                labelText!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel,
                    context,
                  ),
                ),
              ),
            ),
          ],
          CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            prefix: prefix != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: prefix,
                  )
                : null,
            suffix: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: suffix,
                  )
                : null,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            inputFormatters: inputFormatters,
            focusNode: focusNode,
            style: style ?? TextStyle(color: CupertinoTheme.of(context).textTheme.textStyle.color),
            maxLines: maxLines,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: CupertinoDynamicColor.resolve(
                  CupertinoColors.separator,
                  context,
                ),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(10.0),
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemBackground,
                context,
              ),
            ),
          ),
        ],
      );
    } else {
      return TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        focusNode: focusNode,
        style: style,
        maxLines: maxLines,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: placeholder,
          labelText: labelText,
          prefixIcon: prefix,
          suffixIcon: suffix,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
        ),
      );
    }
  }
}
