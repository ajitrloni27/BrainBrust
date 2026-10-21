import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OptionTile extends StatelessWidget {
  final int index;
  final String text;
  final bool isSelected;
  final bool isSubmitted;
  final bool isCorrect;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.index,
    required this.text,
    required this.isSelected,
    required this.isSubmitted,
    required this.isCorrect,
    this.onTap,
  });

  static const List<String> optionLetters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final String letter =
        index < optionLetters.length ? optionLetters[index] : '?';

    Color backgroundColor;
    Color borderColor;
    double borderWidth;
    Color badgeBgColor;
    Color badgeTextColor;
    Widget? trailingWidget;
    double opacity = 1.0;

    if (!isSubmitted) {
      if (isSelected) {
        // Pre-submit: Highlighted with primary color, thicker border, check icon
        backgroundColor = primaryColor.withAlpha(isDark ? 40 : 20);
        borderColor = primaryColor;
        borderWidth = 2.2;
        badgeBgColor = primaryColor;
        badgeTextColor = Colors.white;
        trailingWidget = Icon(
          Icons.check_circle_rounded,
          color: primaryColor,
          size: 22,
        );
      } else {
        // Normal unselected state
        backgroundColor = theme.cardTheme.color ?? theme.colorScheme.surface;
        borderColor = theme.colorScheme.outlineVariant.withAlpha(isDark ? 60 : 130);
        borderWidth = 1.2;
        badgeBgColor = isDark
            ? const Color(0xFF334155)
            : const Color(0xFFE2E8F0);
        badgeTextColor = theme.colorScheme.onSurfaceVariant;
        trailingWidget = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.outline.withAlpha(isDark ? 80 : 120),
              width: 1.5,
            ),
          ),
        );
      }
    } else {
      // Post-submit locked states
      if (isCorrect) {
        // Correct option
        const greenColor = Color(0xFF16A34A);
        backgroundColor = greenColor.withAlpha(isDark ? 45 : 25);
        borderColor = greenColor;
        borderWidth = 2.2;
        badgeBgColor = greenColor;
        badgeTextColor = Colors.white;
        trailingWidget = const Icon(
          Icons.check_circle_rounded,
          color: greenColor,
          size: 24,
        );
      } else if (isSelected) {
        // Wrong selected option
        const redColor = Color(0xFFDC2626);
        backgroundColor = redColor.withAlpha(isDark ? 45 : 25);
        borderColor = redColor;
        borderWidth = 2.2;
        badgeBgColor = redColor;
        badgeTextColor = Colors.white;
        trailingWidget = const Icon(
          Icons.cancel_rounded,
          color: redColor,
          size: 24,
        );
      } else {
        // Unselected other options
        backgroundColor = theme.cardTheme.color ?? theme.colorScheme.surface;
        borderColor = theme.colorScheme.outlineVariant.withAlpha(isDark ? 40 : 80);
        borderWidth = 1.0;
        badgeBgColor = isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFF1F5F9);
        badgeTextColor = theme.colorScheme.outline;
        opacity = 0.45;
        trailingWidget = null;
      }
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.card - 2),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            boxShadow: [
              if (isSelected && !isSubmitted)
                BoxShadow(
                  color: primaryColor.withAlpha(isDark ? 60 : 35),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.card - 2),
            child: InkWell(
              onTap: isSubmitted ? null : onTap,
              borderRadius: BorderRadius.circular(AppRadius.card - 2),
              splashColor: primaryColor.withAlpha(25),
              highlightColor: primaryColor.withAlpha(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md + 2,
                ),
                child: Row(
                  children: [
                    // Circular letter badge
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md + 2),

                    // Option text
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          height: 1.35,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),

                    if (trailingWidget != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      trailingWidget,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
