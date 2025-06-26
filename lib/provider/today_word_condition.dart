import 'package:english_word_app/api/supabase_api.dart';
import 'package:english_word_app/models/word.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../consts/enums.dart';

class TodayWordCondition {
  String? selectedGrade;
  String? selectedEduProcess;
  // String? selectedWordOption; // 틀린 단어 하기, 많이 틀린단어 하기
  EduType selectedEduType;
  bool isFillCondition1;
  bool condition1;
  bool isFillCondition2;
  bool condition2;
  Set<int> selectedIndex;

  List<int> wordIds;
  List<dynamic> listValues;
  List<dynamic> selectedValues;

  TodayWordCondition({
    required this.selectedGrade,
    required this.selectedEduProcess,
    // required this.selectedWordOption,
    required this.selectedEduType,
    required this.isFillCondition1,
    required this.isFillCondition2,
    required this.condition1,
    required this.condition2,
    required this.selectedIndex,
    required this.wordIds,
    required this.listValues,
    required this.selectedValues,
    // required this.listWords,
    // required this.selectedWords,
  });

  TodayWordCondition copyWith({
    String? selectedGrade,
    String? selectedEduProcess,
    String? selectedWordOption,
    EduType? selectedEduType,
    bool? isFillCondition1,
    bool? condition1,
    bool? isFillCondition2,
    bool? condition2,
    Set<int>? selectedIndex,
    List<int>? wordIds,
    List<dynamic>? listValues,
    List<dynamic>? selectedValues,
  }) {
    return TodayWordCondition(
      selectedGrade: selectedGrade ?? this.selectedGrade,
      selectedEduProcess: selectedEduProcess ?? this.selectedEduProcess,
      // selectedWordOption: selectedWordOption ?? this.selectedWordOption,
      selectedEduType: selectedEduType ?? this.selectedEduType,
      isFillCondition1: isFillCondition1 ?? this.isFillCondition1,
      isFillCondition2: isFillCondition2 ?? this.isFillCondition2,
      condition1: condition1 ?? this.condition1,
      condition2: condition2 ?? this.condition2,
      selectedIndex: selectedIndex ?? this.selectedIndex,

      wordIds: wordIds ?? this.wordIds,
      listValues: listValues ?? this.listValues,
      selectedValues: selectedValues ?? this.selectedValues,
    );
  }
}

class TodayWordConditionNotifier extends StateNotifier<TodayWordCondition> {
  TodayWordConditionNotifier()
    : super(
        TodayWordCondition(
          selectedGrade: null,
          selectedEduProcess: null,
          // selectedWordOption: null,
          selectedEduType: EduType.None,
          isFillCondition1: false,
          isFillCondition2: false,
          condition1: false,
          condition2: false,
          selectedIndex: {},

          wordIds: [],
          listValues: [],
          selectedValues: [],
        ),
      );

  bool isLoadComplete = false;

  // Option Setter

  void selectGrade(String? grade) {
    state = state.copyWith(selectedGrade: grade);
    if (state.selectedEduType != EduType.None) state.isFillCondition1 = true;
  }

  void selectEduType(EduType eduType) {
    state = state.copyWith(selectedEduType: eduType);
    if (state.selectedGrade != null) state.isFillCondition1 = true;
  }

  void selectEduProcess(String? process) {
    state = state.copyWith(selectedEduProcess: process, selectedIndex: {});
    isLoadComplete = false;
    // EduProcess가 바뀔 때 마다 LoadComplete를 false로 두어 다시 데이터를 불러오게 한다.
  }

  // void selectWordOption(String? option) {
  //   state = state.copyWith(selectedWordOption: option);
  // }

  // 단어, 챕터 선택 시 해당되는 인덱스를 삽입 및 삭제
  void appnedIndex(int index) {
    Set<int> newSet = Set<int>.from(state.selectedIndex);
    newSet.add(index);
    if (newSet.length > 0) state.isFillCondition2 = true;

    if (newSet.length > 10 && state.selectedEduProcess == "단어 선택하기") {
      newSet.remove(newSet.last);
      Fluttertoast.showToast(
        msg: "10개 이상의 단어를 선택할 수 없습니다!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }

    state = state.copyWith(selectedIndex: newSet);
  }

  void removeIndex(int index) {
    Set<int> newSet = Set<int>.from(state.selectedIndex);
    newSet.remove(index);
    if (newSet.isEmpty) state.isFillCondition2 = false;

    state = state.copyWith(selectedIndex: newSet);
  }

  bool isContain(int index) {
    return state.selectedIndex.contains(index);
  }

  void satisfiedCondition1() {
    state = state.copyWith(condition1: true);
  }

  void satisfiedCondition2() {
    List<dynamic> values = [];

    for (var selected in state.selectedIndex) {
      values.add(state.listValues[selected]);
    }
    // listValues들 중 선택된것만 가져온다.
    state = state.copyWith(condition2: true, selectedValues: values);
  }

  // 상태변수 setter

  void setListValues(List<dynamic> values) {
    if (isLoadComplete == false) {
      state = state.copyWith(listValues: values);
      isLoadComplete = true;
    }
  }

  void setSelectedValues(List<dynamic> values) {
    state = state.copyWith(selectedValues: values);
  }

  void setWordIds(List<int> wordsIds) {
    state = state.copyWith(wordIds: wordsIds);
  }

  // 무한 스크롤링을 위한 페이지 메서드

  int _getNextWordPage() {
    return state.listValues.length ~/ 10;
  }

  void appendWords() async {
    SupabaseAPI client = SupabaseAPI.getInstance();
    int curPage = _getNextWordPage();
    Map<String, dynamic> result = await client.GetWordsByGrade(
      getGrade(),
      curPage,
      10,
    );

    int maxCount = result["maxCount"];

    if (state.listValues.length < maxCount) {
      List<dynamic> newList = [...state.listValues, ...result["wordList"]];
      state = state.copyWith(listValues: newList);
    }
  }

  void truncateList() {
    state = state.copyWith(
      listValues: [],
      selectedValues: [],
      selectedIndex: {},
    );
  }

  void truncateState() {
    state = TodayWordCondition(
      selectedGrade: null,
      selectedEduProcess: null,
      // selectedWordOption: null,
      selectedEduType: EduType.None,
      isFillCondition1: false,
      isFillCondition2: false,
      condition1: false,
      condition2: false,
      selectedIndex: {},

      wordIds: [],
      listValues: [],
      selectedValues: [],

      // listWords: [],
      // selectedWords: [],
    );
  }

  int getGrade() {
    switch (state.selectedGrade) {
      case "1학년":
        return 1;
      case "2학년":
        return 2;
      case "3학년":
        return 3;
    }
    return -1;
  }
}

final todayWordConditionProvider =
    StateNotifierProvider<TodayWordConditionNotifier, TodayWordCondition>((
      ref,
    ) {
      return TodayWordConditionNotifier();
    });
