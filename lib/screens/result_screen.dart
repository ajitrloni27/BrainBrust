import 'package:flutter/material.dart';
import '../models/topic.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatelessWidget {
  final Topic topic;
  final int score;
  final int totalQuestions;

  const ResultScreen({
    super.key,
    required this.topic,
    required this.score,
    required this.totalQuestions,
  });

  double get percentage =>
      totalQuestions > 0 ? (score / totalQuestions) * 100 : 0.0;

  String get scoreMessage {
    final pct = percentage;
    if (pct >= 90) {
      return "Outstanding! You're completely placement-ready! 🚀";
    } else if (pct >= 75) {
      return "Great work! Solid grasp of core concepts. Keep it up! 🌟";
    } else if (pct >= 50) {
      return "Good effort! A little more practice and you'll master this. 💪";
    } else {
      return "Keep practicing! Review the explanations and try again. 📚";
    }
  }

  Color _getPerformanceColor() {
    final pct = percentage;
    if (pct >= 75) {
      return const Color(0xFF16A34A);
    } else if (pct >= 50) {
      return const Color(0xFFD97706);
    } else {
      return const Color(0xFFDC2626);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final performanceColor = _getPerformanceColor();
    final int incorrect = (totalQuestions - score).clamp(0, totalQuestions);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz Results',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Topic Header Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: topic.getAccentColor(context).withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: topic.getAccentColor(context).withAlpha(80),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      topic.icon,
                      size: 18,
                      color: topic.getAccentColor(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      topic.name,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: topic.getAccentColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Score Circle Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withAlpha(isDark ? 80 : 150),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 30 : 10),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Score circular badge
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: performanceColor.withAlpha(25),
                        border: Border.all(
                          color: performanceColor,
                          width: 4,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$score / $totalQuestions',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: performanceColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: performanceColor.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Motivational message
                    Text(
                      scoreMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Breakdown chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Correct chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A).withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF16A34A).withAlpha(80),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: Color(0xFF16A34A),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$score Correct',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Incorrect chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626).withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFDC2626).withAlpha(80),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.cancel_rounded,
                                size: 16,
                                color: Color(0xFFDC2626),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$incorrect Wrong',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFDC2626),
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
              const SizedBox(height: 32),

              // Action Buttons
              // Try Again Button (Reshuffles questions)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          topic: topic,
                          shuffleQuestions: true,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back to Topics Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.list_alt_rounded),
                  label: const Text(
                    'Back to Topics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
