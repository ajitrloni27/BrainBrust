import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ExplanationCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color accentColor;

  const ExplanationCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? accentColor.withAlpha(20)
            : accentColor.withAlpha(12),
        borderRadius: BorderRadius.circular(AppRadius.card - 2),
        border: Border.all(
          color: accentColor.withAlpha(isDark ? 50 : 40),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card - 2),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored left accent bar
              Container(
                width: 5.0,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.card - 2),
                    bottomLeft: Radius.circular(AppRadius.card - 2),
                  ),
                ),
              ),

              // Content area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: accentColor.withAlpha(isDark ? 45 : 30),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: 18,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm + 2),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm + 2),
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.5,
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
