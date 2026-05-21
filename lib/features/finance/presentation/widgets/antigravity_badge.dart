import 'package:flutter/material.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';

class AntigravityBadge extends StatefulWidget {
  final bool isAntigravityActive;
  final double amount;
  final String currency;

  const AntigravityBadge({
    Key? key,
    required this.isAntigravityActive,
    required this.amount,
    required this.currency,
  }) : super(key: key);

  @override
  State<AntigravityBadge> createState() => _AntigravityBadgeState();
}

class _AntigravityBadgeState extends State<AntigravityBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (!widget.isAntigravityActive) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.getBorderColor(context),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AppColors.getTextSecondary(context),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.standardModeMsg,
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Glowing Neon Glassmorphism Badge when Antigravity Mode is triggered!
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent.withOpacity(0.25),
                blurRadius: _glowAnimation.value,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.deepPurpleAccent.withOpacity(0.15),
                blurRadius: _glowAnimation.value * 2,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade900.withOpacity(0.85),
              Colors.deepPurple.shade700.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.purpleAccent.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: Colors.amberAccent,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.antigravityActive,
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.antigravityWarning('${widget.amount.toStringAsFixed(2)} ${widget.currency}'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
