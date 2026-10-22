import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/question.dart';
import '../models/topic.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/code_box.dart';
import '../widgets/explanation_card.dart';
import '../widgets/option_tile.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Topic topic;
  final int initialIndex;

  const QuizScreen({
    super.key,
    required this.topic,
    this.initialIndex = 0,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Question> _questions;
  late int _currentIndex;
  int? _selectedOptionIndex;
  bool _isSubmitted = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 1. Fixed question order (no shuffling)
    _questions = List<Question>.from(widget.topic.questions);

    // Clamp initialIndex safely in case questions count changed
    if (_questions.isNotEmpty) {
      _currentIndex = widget.initialIndex.clamp(0, _questions.length - 1);
      // 2. Save progress as soon as question is displayed
      ProgressService.saveProgress(widget.topic.id, _currentIndex);
    } else {
      _currentIndex = 0;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleOptionTap(int index) {
    if (_isSubmitted) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _handleSubmit() {
    if (_selectedOptionIndex == null || _isSubmitted) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isSubmitted = true;
    });

    // Smoothly scroll down so feedback and explanations are visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _handleNextOrFinish() {
    final bool isLastQuestion = _currentIndex == _questions.length - 1;

    if (!isLastQuestion) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isSubmitted = false;
      });

      // Save progress immediately for the new question
      ProgressService.saveProgress(widget.topic.id, _currentIndex);

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    } else {
      // Clear progress when the topic is finished
      ProgressService.clearProgress(widget.topic.id);

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ResultScreen(topic: widget.topic),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: const Text('Leave Quiz?'),
        content: Text(
          'Your progress is saved at Question ${_currentIndex + 1}. You can continue where you left off anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.topic.name)),
        body: const Center(
          child: Text('No questions available.'),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentQuestion = _questions[_currentIndex];
    final int totalQuestions = _questions.length;
    final double progress = (_currentIndex + 1) / totalQuestions;
    final bool isLastQuestion = _currentIndex == totalQuestions - 1;

    final bool isCorrect =
        _isSubmitted && _selectedOptionIndex == currentQuestion.answer;

    final String correctOptionLetter = currentQuestion.answer < 4
        ? ['A', 'B', 'C', 'D'][currentQuestion.answer]
        : '';
    final String correctOptionText =
        (currentQuestion.options.isNotEmpty &&
                currentQuestion.answer < currentQuestion.options.length)
            ? currentQuestion.options[currentQuestion.answer]
            : '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Close',
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            widget.topic.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Navigation Progress Header: Animated bar + "Question X of Y"
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xs,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outlineVariant.withAlpha(isDark ? 50 : 100),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentIndex + 1} of $totalQuestions',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: 0.1,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Animated linear progress bar with rounded ends
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(begin: 0.0, end: progress),
                      builder: (context, value, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 7,
                            backgroundColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Scrollable Question & Options Content with AnimatedSwitcher
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(0.08, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ));
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: ListView(
                    key: ValueKey<int>(_currentIndex),
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    children: [
                      // Question Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withAlpha(isDark ? 50 : 120),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withAlpha(35)
                                  : theme.colorScheme.shadow.withAlpha(8),
                              blurRadius: 14,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          currentQuestion.question,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),

                      // Code Box
                      if (currentQuestion.hasCode)
                        CodeBox(code: currentQuestion.code!),
                      if (!currentQuestion.hasCode)
                        const SizedBox(height: AppSpacing.lg),

                      // Options
                      ...List.generate(currentQuestion.options.length, (index) {
                        return OptionTile(
                          index: index,
                          text: currentQuestion.options[index],
                          isSelected: _selectedOptionIndex == index,
                          isSubmitted: _isSubmitted,
                          isCorrect: currentQuestion.answer == index,
                          onTap: () => _handleOptionTap(index),
                        );
                      }),

                      // Result Feedback Section
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isSubmitted
                            ? Column(
                                key: const ValueKey('results_feedback'),
                                children: [
                                  const SizedBox(height: AppSpacing.xs),
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                      bottom: AppSpacing.lg,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                      vertical: AppSpacing.md + 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? const Color(0xFF16A34A).withAlpha(isDark ? 40 : 20)
                                          : const Color(0xFFDC2626).withAlpha(isDark ? 40 : 20),
                                      borderRadius: BorderRadius.circular(AppRadius.card - 2),
                                      border: Border.all(
                                        color: isCorrect
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFFDC2626),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          isCorrect
                                              ? Icons.check_circle_rounded
                                              : Icons.cancel_rounded,
                                          color: isCorrect
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFFDC2626),
                                          size: 24,
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Text(
                                            isCorrect
                                                ? 'Correct! Great job.'
                                                : 'Wrong! The correct answer is Option $correctOptionLetter: $correctOptionText',
                                            style: TextStyle(
                                              color: isCorrect
                                                  ? const Color(0xFF16A34A)
                                                  : const Color(0xFFDC2626),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14.5,
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (currentQuestion.hasExplanation)
                                    ExplanationCard(
                                      title: 'Explanation',
                                      content: currentQuestion.explanation!,
                                      icon: Icons.lightbulb_rounded,
                                      accentColor: theme.colorScheme.primary,
                                    ),

                                  if (currentQuestion.hasSimpleExplanation)
                                    ExplanationCard(
                                      title: 'In simple words',
                                      content: currentQuestion.simpleExplanation!,
                                      icon: Icons.chat_bubble_outline_rounded,
                                      accentColor: const Color(0xFF0D9488),
                                    ),

                                  const SizedBox(height: AppSpacing.md),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),

              // Pinned Bottom Button Bar (Submit -> Next / Finish)
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outlineVariant.withAlpha(isDark ? 50 : 100),
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: !_isSubmitted
                        ? SizedBox(
                            key: const ValueKey('btn_submit'),
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _selectedOptionIndex == null
                                  ? null
                                  : _handleSubmit,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.button),
                                ),
                              ),
                              child: const Text('Submit'),
                            ),
                          )
                        : SizedBox(
                            key: const ValueKey('btn_next'),
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _handleNextOrFinish,
                              icon: Icon(
                                isLastQuestion
                                    ? Icons.flag_rounded
                                    : Icons.arrow_forward_rounded,
                              ),
                              label: Text(isLastQuestion ? 'Finish' : 'Next'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.button),
                                ),
                              ),
                            ),
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
