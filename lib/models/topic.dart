import 'package:flutter/material.dart';
import 'question.dart';

class Topic {
  final String id;
  final String name;
  final List<Question> questions;

  const Topic({
    required this.id,
    required this.name,
    required this.questions,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  bool get hasQuestions => questions.isNotEmpty;
  int get questionCount => questions.length;

  IconData get icon {
    switch (id.toLowerCase()) {
      case 'html':
        return Icons.html_rounded;
      case 'css':
        return Icons.css_rounded;
      case 'javascript':
        return Icons.javascript_rounded;
      case 'react':
        return Icons.widgets_rounded;
      case 'nodejs':
        return Icons.hub_rounded;
      case 'express':
        return Icons.alt_route_rounded;
      case 'git':
        return Icons.commit_rounded;
      case 'backend':
        return Icons.dns_rounded;
      case 'java':
        return Icons.coffee_rounded;
      case 'rag':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.quiz_rounded;
    }
  }

  List<Color> get gradientColors {
    switch (id.toLowerCase()) {
      case 'html':
        return const [Color(0xFFFF6B4A), Color(0xFFEA580C)];
      case 'css':
        return const [Color(0xFF38BDF8), Color(0xFF0284C7)];
      case 'javascript':
        return const [Color(0xFFFBBF24), Color(0xFFD97706)];
      case 'react':
        return const [Color(0xFF06B6D4), Color(0xFF0284C7)];
      case 'nodejs':
        return const [Color(0xFF34D399), Color(0xFF059669)];
      case 'express':
        return const [Color(0xFF2DD4BF), Color(0xFF0D9488)];
      case 'git':
        return const [Color(0xFFF43F5E), Color(0xFFE11D48)];
      case 'backend':
        return const [Color(0xFFA855F7), Color(0xFF7E22CE)];
      case 'java':
        return const [Color(0xFFF97316), Color(0xFFC2410C)];
      case 'rag':
        return const [Color(0xFF818CF8), Color(0xFF4F46E5)];
      default:
        return const [Color(0xFF818CF8), Color(0xFF4F46E5)];
    }
  }

  Color get primaryAccentColor => gradientColors.first;
}
