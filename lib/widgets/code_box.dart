import 'package:flutter/material.dart';

class CodeBox extends StatelessWidget {
  final String code;

  const CodeBox({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF1E1E2E)
        : const Color(0xFFF1F3F9);
    final borderColor = isDark
        ? const Color(0xFF313244)
        : const Color(0xFFDCE0E8);
    final textColor = isDark
        ? const Color(0xFFCDD6F4)
        : const Color(0xFF4C4F69);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 14.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF181825) : const Color(0xFFE6E9EF),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.terminal_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Code Snippet',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: textColor.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14.0),
            child: SelectableText(
              code,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13.5,
                height: 1.5,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
