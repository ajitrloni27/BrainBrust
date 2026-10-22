import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/topic.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/topic_card.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode currentThemeMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.currentThemeMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Topic>> _topicsFuture;
  late AnimationController _staggerController;
  Map<String, int> _progressMap = {};

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _topicsFuture = _loadTopicsAndProgress();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Future<List<Topic>> _loadTopicsAndProgress() async {
    try {
      final jsonString = await rootBundle.loadString('assets/questions.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> topicsJson = data['topics'] as List<dynamic>? ?? [];
      final topics = topicsJson
          .map((t) => Topic.fromJson(t as Map<String, dynamic>))
          .toList();

      final topicIds = topics.map((t) => t.id).toList();
      final progress = await ProgressService.getAllProgress(topicIds);

      if (mounted) {
        setState(() {
          _progressMap = progress;
        });
        _staggerController.forward(from: 0.0);
      }
      return topics;
    } catch (e) {
      debugPrint('Error loading questions.json: $e');
      rethrow;
    }
  }

  void _refresh() {
    setState(() {
      _topicsFuture = _loadTopicsAndProgress();
    });
  }

  void _openQuiz(Topic topic, int initialIndex) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            QuizScreen(topic: topic, initialIndex: initialIndex),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) {
      // Refresh progress chips upon returning
      _refresh();
    });
  }

  Future<void> _handleTopicTap(BuildContext context, Topic topic) async {
    if (!topic.hasQuestions) {
      _showComingSoonDialog(context, topic);
      return;
    }

    final total = topic.questions.length;
    final rawSavedIndex = _progressMap[topic.id] ?? 0;

    // Check if there is valid active progress (greater than 0 and less than total)
    if (rawSavedIndex > 0 && rawSavedIndex < total) {
      final savedQuestionNum = rawSavedIndex + 1;

      // 3. Resume Prompt Dialog
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: true, // Dismissing by tapping outside stays on topics screen
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          icon: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: topic.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          title: const Text(
            'Continue where you left off?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'You stopped at question $savedQuestionNum of $total.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14.5, height: 1.4),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsOverflowButtonSpacing: 8,
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop('continue'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                child: Text('Continue from Question $savedQuestionNum'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop('restart'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                child: const Text('Start from beginning'),
              ),
            ),
          ],
        ),
      );

      // Handle user's selection
      if (result == 'continue') {
        _openQuiz(topic, rawSavedIndex);
      } else if (result == 'restart') {
        await ProgressService.saveProgress(topic.id, 0);
        _openQuiz(topic, 0);
      }
      // If result is null (dismissed outside), do nothing and stay on home screen
    } else {
      // No saved progress: open directly at question 1 (index 0)
      _openQuiz(topic, 0);
    }
  }

  void _showComingSoonDialog(BuildContext context, Topic topic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: topic.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            topic.icon,
            size: 30,
            color: Colors.white,
          ),
        ),
        title: Text(
          topic.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Questions coming soon!\n\nYou can add your MCQs to assets/questions.json anytime to start practicing.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.5, height: 1.45),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: FutureBuilder<List<Topic>>(
        future: _topicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Failed to load questions',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Please verify assets/questions.json formatting.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final topics = snapshot.data ?? [];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Gradient Header with rounded bottom corners
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4F46E5), // Indigo
                        Color(0xFF7C3AED), // Violet
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withAlpha(isDark ? 50 : 35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.xxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(35),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.bolt_rounded,
                                      size: 16,
                                      color: Color(0xFFFDE047),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'BRAINBURST',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Reload Questions',
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: _refresh,
                                  ),
                                  IconButton(
                                    tooltip: 'Toggle Theme',
                                    icon: Icon(
                                      isDark
                                          ? Icons.light_mode_rounded
                                          : Icons.dark_mode_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: widget.onToggleTheme,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            'BrainBurst',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Quick bursts of practice for your tech skills',
                            style: TextStyle(
                              fontSize: 14.5,
                              color: Colors.white.withAlpha(210),
                              fontWeight: FontWeight.w400,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Practice Topics',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Select a topic',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Responsive Staggered Cards (Grid or List)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final bool isWide = constraints.crossAxisExtent >= 380;

                    if (isWide) {
                      return SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 88,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final topic = topics[index];
                            final savedIndex = _progressMap[topic.id] ?? 0;
                            final hasSavedProgress = savedIndex > 0 &&
                                savedIndex < topic.questions.length;

                            return _buildStaggeredItem(
                              index,
                              topic,
                              topics.length,
                              hasSavedProgress,
                            );
                          },
                          childCount: topics.length,
                        ),
                      );
                    } else {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final topic = topics[index];
                            final savedIndex = _progressMap[topic.id] ?? 0;
                            final hasSavedProgress = savedIndex > 0 &&
                                savedIndex < topic.questions.length;

                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: _buildStaggeredItem(
                                index,
                                topic,
                                topics.length,
                                hasSavedProgress,
                              ),
                            );
                          },
                          childCount: topics.length,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStaggeredItem(
    int index,
    Topic topic,
    int totalCount,
    bool hasSavedProgress,
  ) {
    final double start = (index * 0.08).clamp(0.0, 0.7);
    final double end = (start + 0.35).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1.0 - animation.value)),
            child: child,
          ),
        );
      },
      child: TopicCard(
        topic: topic,
        hasSavedProgress: hasSavedProgress,
        onTap: () => _handleTopicTap(context, topic),
      ),
    );
  }
}
