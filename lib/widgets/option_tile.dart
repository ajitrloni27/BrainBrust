import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final int index;
  final String text;
  final bool isAnswered;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.index,
    required this.text,
    required this.isAnswered,
    required this.isSelected,
    required this.isCorrect,
    this.onTap,
  });

  static const List<String> optionLetters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String letter = index < optionLetters.length ? optionLetters[index] : '?';

    Color backgroundColor;
    Color borderColor;
    Color letterBgColor;
    Color letterTextColor;
    Widget? trailingIcon;
    double opacity = 1.0;

    if (!isAnswered) {
      backgroundColor = theme.colorScheme.surface;
      borderColor = theme.colorScheme.outlineVariant;
      letterBgColor = theme.colorScheme.surfaceContainerHighest;
      letterTextColor = theme.colorScheme.onSurfaceVariant;
      trailingIcon = null;
    } else {
      if (isCorrect) {
        // Correct option
        const greenColor = Color(0xFF16A34A);
        backgroundColor = isDark
            ? greenColor.withAlpha(45)
            : greenColor.withAlpha(25);
        borderColor = greenColor;
        letterBgColor = greenColor;
        letterTextColor = Colors.white;
        trailingIcon = const Icon(
          Icons.check_circle_rounded,
          color: greenColor,
          size: 24,
        );
      } else if (isSelected) {
        // Wrong selected option
        const redColor = Color(0xFFDC2626);
        backgroundColor = isDark
            ? redColor.withAlpha(45)
            : redColor.withAlpha(25);
        borderColor = redColor;
        letterBgColor = redColor;
        letterTextColor = Colors.white;
        trailingIcon = const Icon(
          Icons.cancel_rounded,
          color: redColor,
          size: 24,
        );
      } else {
        // Unselected other options
        backgroundColor = theme.colorScheme.surface;
        borderColor = theme.colorScheme.outlineVariant.withAlpha(100);
        letterBgColor = theme.colorScheme.surfaceContainerHighest.withAlpha(120);
        letterTextColor = theme.colorScheme.onSurfaceVariant.withAlpha(120);
        opacity = 0.5;
        trailingIcon = null;
      }
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        child: Material(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: borderColor,
              width: (isAnswered && (isCorrect || isSelected)) ? 2.0 : 1.2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isAnswered ? null : onTap,
            borderRadius: BorderRadius.circular(14),
            splashColor: theme.colorScheme.primary.withAlpha(30),
            highlightColor: theme.colorScheme.primary.withAlpha(15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: letterBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: letterTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: (isAnswered && (isCorrect || isSelected))
                            ? FontWeight.w600
                            : FontWeight.w500,
                        height: 1.35,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 10),
                    trailingIcon,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
