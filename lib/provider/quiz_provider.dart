import 'package:english_word_app/api/supabase_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz.dart';

class QuizSet {
  int quizCount;
  List<Quiz> quizzes;
  bool isConfirmedQuizSet;
  int quizIdx;
  bool isEndedQuiz;

  QuizSet({
    required this.quizCount,
    required this.quizzes,
    required this.isConfirmedQuizSet,
    required this.quizIdx,
    required this.isEndedQuiz,
  });

  QuizSet copyWith({
    int? quizCount,
    List<Quiz>? quizzes,
    bool? isConfirmedQuizSet,
    int? quizIdx,
    bool? isEndedQuiz,
  }) {
    return QuizSet(
      quizCount: quizCount ?? this.quizCount,
      quizzes: quizzes ?? this.quizzes,
      isConfirmedQuizSet: isConfirmedQuizSet ?? this.isConfirmedQuizSet,
      quizIdx: quizIdx ?? this.quizIdx,
      isEndedQuiz: isEndedQuiz ?? this.isEndedQuiz,
    );
  }
}

class QuizProviderNotifier extends StateNotifier<QuizSet> {
  QuizProviderNotifier()
    : super(
        QuizSet(
          quizCount: -1,
          quizzes: [],
          isConfirmedQuizSet: false,
          quizIdx: 0,
          isEndedQuiz: false,
        ),
      );

  void setQuizzes(int quizCount, List<Quiz>? list, bool confirm) {
    state = QuizSet(
      quizCount: quizCount,
      quizzes: list!,
      isConfirmedQuizSet: confirm,
      quizIdx: 0,
      isEndedQuiz: false,
    );
  }

  void quizConfirm(bool confirm) {
    state = state.copyWith(isConfirmedQuizSet: confirm);
  }

  Quiz? getCurrentQuiz() {
    if (state.quizIdx < state.quizCount) {
      return state.quizzes[state.quizIdx];
    } else
      return null;
  }

  String getAnswer() {
    if (state.quizIdx < state.quizCount)
      return getCurrentQuiz()!.word.toLowerCase();
    else
      return "";
  }

  bool getNextQuiz() {
    if (state.quizIdx < state.quizCount - 1) {
      state = state.copyWith(quizIdx: state.quizIdx + 1);
      return true;
    } else
      return false;
  }

  bool isQuizConfirmed() {
    return state.isConfirmedQuizSet;
  }

  void endQuiz(bool isEnded) {
    state = state.copyWith(isEndedQuiz: isEnded);
  }

  bool isEndedQuiz() {
    return state.isEndedQuiz;
  }

  void truncateState() {
    state = QuizSet(
      quizCount: -1,
      quizzes: [],
      isConfirmedQuizSet: false,
      quizIdx: 0,
      isEndedQuiz: false,
    );
  }
}

final quizProvider = StateNotifierProvider<QuizProviderNotifier, QuizSet>((
  ref,
) {
  return QuizProviderNotifier();
});
