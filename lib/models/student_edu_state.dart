import 'package:english_word_app/models/word.dart';
import 'package:english_word_app/models/word_count.dart';
import 'package:flutter/rendering.dart';

import '../models/study_words.dart';

class StudentEduState {
  List<StudyWords> correctWords;
  List<StudyWords> incorrectWords;
  List<StudyWords> accmulatedWords;
  int learningTime;

  late int alreadyKnownWords;
  late int newLearnedWords;
  late int reminedWords;
  late List<WordCount> mergedList;

  Map<String, dynamic> attendance;

  StudentEduState({
    required this.incorrectWords,
    required this.correctWords,
    required this.accmulatedWords,
    required this.attendance,
    required this.learningTime,
    // required this.mergedList,
    required int grade,
  }) {
    alreadyKnownWords = 0;
    newLearnedWords = 0;
    reminedWords = 0;
    /*
{"correctWords":[
-{"id":71,"grade":1,"count":2},
-{"id":14,"grade":1,"count":1},
-{"id":35,"grade":1,"count":1},
-{"id":52,"grade":1,"count":1},
-{"id":49,"grade":1,"count":2},
-{"id":67,"grade":1,"count":1},
-{"id":6,"grade":1,"count":2},
-{"id":8,"grade":1,"count":2}]
-{"id":60,"grade":1,"count":1},
-{"id":21,"grade":1,"count":1},
-{"id":2,"grade":1,"count":1},
  // 새로 배운단어 7 복습단어 4
*/
    mergedList = [];
    Map<int, int> checkId = {};

    // 먼저 틀린단어와 맞춘 단어 리스트를 병합한다.
    // 1. 맞춘 단어 병합
    for (int i = 0; i < correctWords.length; i++) {
      // if (correctWords[i].grade != grade) continue;
      // 만약 유저 학년과 동일하지 않은 단어일 경우 카운팅에서 생략한다.

      mergedList.add(
        WordCount(
          id: correctWords[i].id,
          correct: correctWords[i].count,
          grade: correctWords[i].grade,
          incorrect: 0,
        ),
      );
      checkId[correctWords[i].id] = i;
    }

    // 2. 틀린 단어 병합
    // 만약 맞춘단어와 중복될 경우 카운팅 횟수를 증가
    for (int i = 0; i < incorrectWords.length; i++) {
      // if (incorrectWords[i].grade != grade) continue;
      // 만약 유저 학년과 동일하지 않은 단어일 경우 카운팅에서 생략한다.

      // 이미 병합 리스트에 존재하는 단어일 경우
      // 틀린 횟수를 넣는다.
      if (checkId.containsKey(incorrectWords[i].id)) {
        int? idx = checkId[incorrectWords[i].id];
        mergedList[idx!].incorrect = incorrectWords[i].count;
      }
      // 병합 리스트에 존재하지 않는 단어일 경우
      // 단순히 추가한다.
      else {
        mergedList.add(
          WordCount(
            id: incorrectWords[i].id,
            correct: 0,
            incorrect: incorrectWords[i].count,
            grade: incorrectWords[i].grade,
          ),
        );
      }
    }

    // 모르는 단어
    // -------------------------------------
    // correct == 0 incorrect >= N (0, N)
    // -------------------------------------
    // 새로 배운 단어
    // -------------------------------------
    // correct == 1 incorrect == 0 (1, 0)
    // -------------------------------------
    // 복습단어
    // correct == 1 incorrect >= 1 (1, N),
    // correct == 2 incorrect >= 0 (2, N),
    // -------------------------------------
    // 이미 아는 단어
    // correct >= 3 incorrect >= 0 (3, N)

    // 새로 배운 단어를 카운팅한다.
    for (int i = 0; i < mergedList.length; i++) {
      if (mergedList[i].correct == 1 &&
          mergedList[i].incorrect == 0 &&
          mergedList[i].grade == grade)
        newLearnedWords++;
    }

    // 복습 단어를 카운팅한다.
    for (int i = 0; i < mergedList.length; i++) {
      if (mergedList[i].grade == grade) {
        if (mergedList[i].correct == 1 && mergedList[i].incorrect >= 1) {
          reminedWords++;
        } else if (mergedList[i].correct == 2 && mergedList[i].incorrect >= 0) {
          reminedWords++;
        }
      }
    }

    // 이미 아는 단어를 카운팅한다.
    for (int i = 0; i < mergedList.length; i++) {
      if (mergedList[i].correct >= 3 && mergedList[i].grade == grade)
        alreadyKnownWords++;
    }

    // for (int i = 0; i < mergedList.length; i++) {
    //   if (mergedList[i].correct == 0) {
    //     print(mergedList[i]);
    //   }
    // }
    // for debug...
  }
}
