class Question {
  final int? id;
  final int testId;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String correctAnswer;
  final String? explanation;

  const Question({
    this.id,
    required this.testId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.correctAnswer,
    this.explanation,
  });

  // JSON'dan Question oluştur
  factory Question.fromJson(Map<String, dynamic> json, int testId) {
    return Question(
      testId: testId,
      questionText: json['question_text']?.toString() ?? '',
      optionA: json['option_a']?.toString() ?? '',
      optionB: json['option_b']?.toString() ?? '',
      optionC: json['option_c']?.toString() ?? '',
      correctAnswer: json['correct_answer']?.toString() ?? '',
      explanation: json['explanation']?.toString(), // JSON'da olmayabilir
    );
  }

  // Database için Map'e dönüştür
  Map<String, dynamic> toMap() {
    final map = {
      'test_id': testId,
      'question_text': questionText,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'correct_answer': correctAnswer,
      'explanation': explanation,
    };
    
    // id null değilse ekle (auto-increment için null bırak)
    if (id != null) {
      map['id'] = id;
    }
    
    return map;
  }

  // Database'den Question oluştur
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int?,
      testId: map['test_id'] as int,
      questionText: map['question_text'] as String,
      optionA: map['option_a'] as String,
      optionB: map['option_b'] as String,
      optionC: map['option_c'] as String,
      correctAnswer: map['correct_answer'] as String,
      explanation: map['explanation'] as String?,
    );
  }

  @override
  String toString() {
    return 'Question{id: $id, testId: $testId, questionText: $questionText, correctAnswer: $correctAnswer}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          testId == other.testId &&
          questionText == other.questionText;

  @override
  int get hashCode => id.hashCode ^ testId.hashCode ^ questionText.hashCode;
}
