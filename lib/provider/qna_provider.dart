import 'package:english_word_app/api/supabase_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/qna.dart';

class QnAList {
  List<QnA> qnas;
  bool isLoadCompleted;

  QnAList({required this.qnas, required this.isLoadCompleted});
}

class QnAProviderNotifier extends StateNotifier<QnAList> {
  QnAProviderNotifier() : super(QnAList(qnas: [], isLoadCompleted: true));

  Future<QnAList> initProvider() async {
    SupabaseAPI client = SupabaseAPI.getInstance();
    Map<String, dynamic> result = await client.getQnAPage(_getQnAPage(), 10);
    state = QnAList(qnas: result["qnas"], isLoadCompleted: true);
    return state;
  }

  int _getQnAPage() {
    return state.qnas.length ~/ 10;
  }

  Future<void> getNextQnAPage() async {
    SupabaseAPI client = SupabaseAPI.getInstance();

    state.isLoadCompleted = false;

    Map<String, dynamic> result = await client.getQnAPage(_getQnAPage(), 10);

    state.isLoadCompleted = true;

    List<QnA> list = result["qnas"];
    int maxCount = result["maxCount"];
    if (state.qnas.length < maxCount)
      state = QnAList(qnas: [...state.qnas, ...list], isLoadCompleted: true);
  }

  void appendQnAInLocal(Map<String, String>? map) {
    final now = DateTime.now();
    final dateOnly = DateTime(now.year, now.month, now.day);

    final formatter = DateFormat('yyyyMMdd');
    final String formatted = formatter.format(dateOnly);
    QnA qna = QnA(date: formatted, question: map!["question"]!, answer: "");

    state = QnAList(qnas: [qna, ...state.qnas], isLoadCompleted: true);
  }

  void truncateState() {
    state = QnAList(qnas: [], isLoadCompleted: true);
  }

  bool isLoadCompleted() {
    return state.isLoadCompleted;
  }
}

final qnaProvider = StateNotifierProvider<QnAProviderNotifier, QnAList>((ref) {
  return QnAProviderNotifier();
});
