import 'package:flutter/material.dart';
import '../models/topic.dart';
import '../theme/app_theme.dart';

class TopicCard extends StatefulWidget {
  final Topic topic;
  final VoidCallback onTap;
  final bool hasSavedProgress;

  const TopicCard({
    super.key,
    required this.topic,
    required this.onTap,
    this.hasSavedProgress = false,
  });

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  bool _isPressed = false;

  void _setPressed(bool pressed) {
    if (_isPressed != pressed) {
      setState(() {
        _isPressed = pressed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topic = widget.topic;

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutQuad,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: widget.hasSavedProgress
                ? topic.primaryAccentColor.withAlpha(isDark ? 90 : 130)
                : theme.colorScheme.outlineVariant.withAlpha(isDark ? 50 : 120),
            width: widget.hasSavedProgress ? 1.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(40)
                  : theme.colorScheme.shadow.withAlpha(12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            borderRadius: BorderRadius.circular(AppRadius.card),
            splashColor: topic.primaryAccentColor.withAlpha(25),
            highlightColor: topic.primaryAccentColor.withAlpha(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md + 2,
              ),
              child: Row(
                children: [
                  // Gradient-tinted icon badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: topic.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.badge),
                      boxShadow: [
                        BoxShadow(
                          color: topic.primaryAccentColor.withAlpha(isDark ? 80 : 50),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      topic.icon,
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Topic name + optional "In progress" badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          topic.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.hasSavedProgress) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: topic.primaryAccentColor.withAlpha(isDark ? 45 : 20),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: topic.primaryAccentColor.withAlpha(isDark ? 80 : 60),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.history_rounded,
                                  size: 11,
                                  color: topic.primaryAccentColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'In progress',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: topic.primaryAccentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Small arrow icon
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: theme.colorScheme.outline.withAlpha(isDark ? 120 : 160),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
