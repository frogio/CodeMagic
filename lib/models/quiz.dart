class Quiz {
  final int id; // word의 id 번호
  final String chapter;
  final String word;
  final String sentence;
  final String translation;
  final String meaning;
  final int grade;

  Quiz({
    required this.id,
    required this.chapter,
    required this.word,
    required this.sentence,
    required this.translation,
    required this.meaning,
    required this.grade,
  });
}
