import 'package:flutter/material.dart';

class ExplanationCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color? accentColor;

  const ExplanationCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withAlpha(60),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
    );
  }
}
