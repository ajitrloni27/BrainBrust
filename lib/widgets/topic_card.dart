import 'package:flutter/material.dart';
import '../models/topic.dart';

class TopicCard extends StatelessWidget {
  final Topic topic;
  final VoidCallback onTap;

  const TopicCard({
    super.key,
    required this.topic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = topic.getAccentColor(context);
    final bool hasQuestions = topic.hasQuestions;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(isDark ? 80 : 150),
            width: 1.2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: accentColor.withAlpha(25),
          highlightColor: accentColor.withAlpha(15),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Topic Icon Container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(isDark ? 40 : 25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accentColor.withAlpha(60),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    topic.icon,
                    size: 28,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 16),
                // Topic Name & Question Count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        topic.name,
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: hasQuestions
                                  ? theme.colorScheme.primaryContainer.withAlpha(120)
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasQuestions)
                                  Icon(
                                    Icons.help_outline_rounded,
                                    size: 13,
                                    color: theme.colorScheme.primary,
                                  )
                                else
                                  Icon(
                                    Icons.hourglass_empty_rounded,
                                    size: 13,
                                    color: theme.colorScheme.outline,
                                  ),
                                const SizedBox(width: 4),
                                Text(
                                  hasQuestions
                                      ? '${topic.questionCount} ${topic.questionCount == 1 ? 'Question' : 'Questions'}'
                                      : 'No questions yet',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: hasQuestions
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Forward chevron
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: hasQuestions
                      ? theme.colorScheme.outline
                      : theme.colorScheme.outline.withAlpha(100),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
