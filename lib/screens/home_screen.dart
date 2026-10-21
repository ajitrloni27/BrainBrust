import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/topic.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Topic>> _topicsFuture;

  @override
  void initState() {
    super.initState();
    _topicsFuture = _loadTopics();
  }

  Future<List<Topic>> _loadTopics() async {
    try {
      final jsonString = await rootBundle.loadString('assets/questions.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> topicsJson = data['topics'] as List<dynamic>? ?? [];
      return topicsJson
          .map((t) => Topic.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading questions.json: $e');
      rethrow;
    }
  }

  void _refreshTopics() {
    setState(() {
      _topicsFuture = _loadTopics();
    });
  }

  void _handleTopicTap(BuildContext context, Topic topic) {
    if (!topic.hasQuestions) {
      _showEmptyTopicDialog(context, topic);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(topic: topic),
        ),
      ).then((_) {
        // Refresh when returning to home in case questions were updated
        _refreshTopics();
      });
    }
  }

  void _showEmptyTopicDialog(BuildContext context, Topic topic) {
    final accentColor = topic.getAccentColor(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentColor.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(
            topic.icon,
            size: 36,
            color: accentColor,
          ),
        ),
        title: Text(
          'No Questions Yet',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'There are no questions added for "${topic.name}" yet.\n\nPaste your questions into "assets/questions.json" to start practicing this topic!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14.5, height: 1.45),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.bolt_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'BrainBurst',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reload Questions',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshTopics,
          ),
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Topic>>(
        future: _topicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load questions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please verify assets/questions.json is formatted correctly.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _refreshTopics,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final topics = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async => _refreshTopics(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              children: [
                // Welcome Hero Section
                Container(
                  padding: const EdgeInsets.all(22.0),
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              theme.colorScheme.primary.withAlpha(40),
                              theme.colorScheme.secondary.withAlpha(20),
                            ]
                          : [
                              theme.colorScheme.primary.withAlpha(25),
                              theme.colorScheme.primaryContainer.withAlpha(50),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withAlpha(35),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'PLACEMENT PREP',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome to BrainBurst',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Quick bursts of practice for your placements',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 14.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                // Topics Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Practice Topics',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      '${topics.length} Topics',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Topic Cards List
                ...topics.map(
                  (topic) => TopicCard(
                    topic: topic,
                    onTap: () => _handleTopicTap(context, topic),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
