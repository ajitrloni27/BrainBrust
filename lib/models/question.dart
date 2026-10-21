class Question {
  final String question;
  final String? code;
  final List<String> options;
  final int answer;
  final String? explanation;
  final String? simpleExplanation;

  const Question({
    required this.question,
    this.code,
    required this.options,
    required this.answer,
    this.explanation,
    this.simpleExplanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] as String? ?? '',
      code: json['code'] as String?,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      answer: (json['answer'] as num?)?.toInt() ?? 0,
      explanation: json['explanation'] as String?,
      simpleExplanation: json['simpleExplanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      if (code != null) 'code': code,
      'options': options,
      'answer': answer,
      if (explanation != null) 'explanation': explanation,
      if (simpleExplanation != null) 'simpleExplanation': simpleExplanation,
    };
  }

  bool get hasCode => code != null && code!.trim().isNotEmpty;
  bool get hasExplanation =>
      explanation != null && explanation!.trim().isNotEmpty;
  bool get hasSimpleExplanation =>
      simpleExplanation != null && simpleExplanation!.trim().isNotEmpty;
}
