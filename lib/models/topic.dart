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

  int get questionCount => questions.length;
  bool get hasQuestions => questions.isNotEmpty;

  IconData get icon {
    switch (id.toLowerCase()) {
      case 'html':
        return Icons.html_rounded;
      case 'css':
        return Icons.css_rounded;
      case 'javascript':
        return Icons.javascript_rounded;
      case 'nodejs':
        return Icons.hub_rounded;
      case 'express':
        return Icons.alt_route_rounded;
      case 'git':
        return Icons.commit_rounded;
      case 'backend':
        return Icons.dns_rounded;
      case 'rag':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.quiz_rounded;
    }
  }

  Color getAccentColor(BuildContext context) {
    switch (id.toLowerCase()) {
      case 'html':
        return Colors.deepOrange;
      case 'css':
        return Colors.blue;
      case 'javascript':
        return Colors.amber.shade800;
      case 'nodejs':
        return Colors.green.shade700;
      case 'express':
        return Colors.teal;
      case 'git':
        return Colors.red.shade700;
      case 'backend':
        return Colors.purple;
      case 'rag':
        return Colors.indigo;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
