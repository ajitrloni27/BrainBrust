import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/topic.dart';
import '../widgets/code_box.dart';
import '../widgets/explanation_card.dart';
import '../widgets/option_tile.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Topic topic;
  final bool shuffleQuestions;

  const QuizScreen({
    super.key,
    required this.topic,
    this.shuffleQuestions = false,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Question> _questions;
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  int _score = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _questions = List<Question>.from(widget.topic.questions);
    if (widget.shuffleQuestions) {
      _questions.shuffle();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleOptionSelected(int optionIndex) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedOptionIndex = optionIndex;
      if (optionIndex == _questions[_currentIndex].answer) {
        _score++;
      }
    });

    // Auto-scroll down slightly to reveal explanations if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleNextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });

      // Reset scroll position to top for the next question
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    } else {
      // Completed last question, navigate to results
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            topic: widget.topic,
            score: _score,
            totalQuestions: _questions.length,
          ),
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Leave Quiz?'),
        content: const Text(
          'Your progress for this quiz session will be lost. Are you sure you want to go back to topics?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Leave'),
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
    final Question currentQuestion = _questions[_currentIndex];
    final int totalQuestions = _questions.length;
    final double progress = (_currentIndex + 1) / totalQuestions;
    final bool isLastQuestion = _currentIndex == totalQuestions - 1;

    final bool isCorrect =
        _isAnswered && _selectedOptionIndex == currentQuestion.answer;

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
          title: Text(
            widget.topic.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(150),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Score: $_score',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress Bar & Step Tracker
              Container(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outlineVariant.withAlpha(isDark ? 60 : 120),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
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
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Question Content
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 18.0,
                  ),
                  children: [
                    // Question text
                    Text(
                      currentQuestion.question,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17.5,
                        height: 1.4,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    // Monospace Code snippet (if any)
                    if (currentQuestion.hasCode)
                      CodeBox(code: currentQuestion.code!),
                    if (!currentQuestion.hasCode)
                      const SizedBox(height: 16),

                    // Options list
                    ...List.generate(currentQuestion.options.length, (index) {
                      return OptionTile(
                        index: index,
                        text: currentQuestion.options[index],
                        isAnswered: _isAnswered,
                        isSelected: _selectedOptionIndex == index,
                        isCorrect: currentQuestion.answer == index,
                        onTap: () => _handleOptionSelected(index),
                      );
                    }),

                    // After-Answer Feedback Section
                    if (_isAnswered) ...[
                      const SizedBox(height: 8),

                      // Result Banner
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? const Color(0xFF16A34A).withAlpha(isDark ? 45 : 20)
                              : const Color(0xFFDC2626).withAlpha(isDark ? 45 : 20),
                          borderRadius: BorderRadius.circular(14),
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isCorrect
                                    ? 'Correct! Well done.'
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

                      // Technical Explanation Card (hidden if empty)
                      if (currentQuestion.hasExplanation)
                        ExplanationCard(
                          title: 'Explanation',
                          content: currentQuestion.explanation!,
                          icon: Icons.lightbulb_rounded,
                          accentColor: theme.colorScheme.primary,
                        ),

                      // In Simple Words Card (hidden if empty)
                      if (currentQuestion.hasSimpleExplanation)
                        ExplanationCard(
                          title: 'In simple words',
                          content: currentQuestion.simpleExplanation!,
                          icon: Icons.forum_rounded,
                          accentColor: const Color(0xFF0D9488),
                        ),

                      const SizedBox(height: 12),

                      // Next / See Results Button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _handleNextQuestion,
                          icon: Icon(
                            isLastQuestion
                                ? Icons.emoji_events_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                          label: Text(
                            isLastQuestion ? 'See Results' : 'Next',
                            style: const TextStyle(
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
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
