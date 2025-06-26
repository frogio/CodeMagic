import 'package:english_word_app/api/supabase_api.dart';
import 'package:english_word_app/models/word.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MistakeNote {
  String? selectedOption;
  Set<int> selectedWordIndex;
  bool satisfiedCondition;
  bool isLoadComplete;

  List<int> wordIds;
  List<Word> wordList;

  MistakeNote({
    this.selectedOption,
    required this.wordIds,
    required this.selectedWordIndex,
    required this.wordList,
    required this.satisfiedCondition,
    required this.isLoadComplete,
  });

  MistakeNote copyWith({
    String? selectedOption,
    List<int>? wordIds,
    Set<int>? selectedWordIndex,
    List<Word>? wordList,
    bool? satisfiedCondition,
    bool? isLoadComplete,
  }) {
    return MistakeNote(
      selectedOption: selectedOption ?? this.selectedOption,
      wordIds: wordIds ?? this.wordIds,
      selectedWordIndex: selectedWordIndex ?? this.selectedWordIndex,
      wordList: wordList ?? this.wordList,
      satisfiedCondition: satisfiedCondition ?? this.satisfiedCondition,
      isLoadComplete: isLoadComplete ?? this.isLoadComplete,
    );
  }
}

class MistakeNoteProvider extends StateNotifier<MistakeNote> {
  MistakeNoteProvider()
    : super(
        MistakeNote(
          selectedOption: null,
          wordIds: [],
          selectedWordIndex: {},
          wordList: [],
          satisfiedCondition: false,
          isLoadComplete: true,
        ),
      );

  void selectOption(String? opt) {
    state = state.copyWith(selectedOption: opt);
  }

  // 단어, 챕터 선택 시 해당되는 인덱스를 삽입 및 삭제
  void appnedIndex(int index) {
    Set<int> newSet = Set<int>.from(state.selectedWordIndex);
    newSet.add(index);

    if (newSet.length > 10) {
      newSet.remove(newSet.last);
      Fluttertoast.showToast(
        msg: "10개 이상의 단어를 선택할 수 없습니다!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }

    state = state.copyWith(selectedWordIndex: newSet, satisfiedCondition: true);
  }

  void removeIndex(int index) {
    Set<int> newSet = Set<int>.from(state.selectedWordIndex);
    newSet.remove(index);
    if (newSet.isEmpty) state.satisfiedCondition = false;

    state = state.copyWith(selectedWordIndex: newSet);
  }

  bool isContain(int index) {
    return state.selectedWordIndex.contains(index);
  }

  Future<void> init(List<int> WrongWords) async {
    SupabaseAPI client = SupabaseAPI.getInstance();

    state.isLoadComplete = false;

    List<Word> words = await client.GetWrongWordByIds(WrongWords, 0, 10);

    state.isLoadComplete = true;

    state = state.copyWith(wordIds: WrongWords, wordList: words);
  }
  // 초기에 10개를 가져온다.

  void truncateList() {
    state = state.copyWith(wordIds: [], wordList: [], selectedWordIndex: {});
  }

  void truncate() {
    state = state.copyWith(
      wordIds: [],
      wordList: [],
      selectedWordIndex: {},
      selectedOption: null,
      satisfiedCondition: false,
      isLoadComplete: true,
    );
  }

  Future<void> appendWords() async {
    SupabaseAPI client = SupabaseAPI.getInstance();

    if (state.wordList.length < state.wordIds.length) {
      state.isLoadComplete = false;
      List<Word> newWordList = [
        ...state.wordList,
        ...await client.GetWrongWordByIds(state.wordIds, _getNextPage(), 10),
      ];
      state.isLoadComplete = true;
      state = state.copyWith(wordList: newWordList);
    }
  }
  // 후에 다음 페이지를 추가한다.

  int _getNextPage() {
    return state.wordList.length ~/ 10;
  }
}

final mistakeNoteProvider =
    StateNotifierProvider<MistakeNoteProvider, MistakeNote>((ref) {
      return MistakeNoteProvider();
    });
