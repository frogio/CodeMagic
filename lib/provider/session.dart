import 'dart:async';

import 'package:english_word_app/consts/enums.dart';
import 'package:english_word_app/models/student_edu_state.dart';
import 'package:english_word_app/models/word.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api/supabase_api.dart';
import '../models/study_words.dart';
import '../models/quiz.dart';

class UserInfo {
  final String id;
  final int grade;
  final String name;
  final String userId;
  final String profileImg;
  // final bool isLogined;
  final String classNo;
  final StudentEduState eduState;
  String? accessJwt;
  String? refreshJwt;
  final bool isAttendanceChecked;

  UserInfo({
    required this.id,
    required this.grade,
    required this.name,
    required this.userId,
    required this.profileImg,
    // required this.isLogined,
    required this.classNo,
    required this.eduState,
    required this.accessJwt,
    required this.refreshJwt,
    required this.isAttendanceChecked,
  });

  UserInfo copyWith({
    String? id,
    int? grade,
    String? name,
    String? userId,
    String? profileImg,
    bool? isLogined,
    String? classNo,
    StudentEduState? eduState,
    String? accessJwt,
    String? refreshJwt,
    bool? isAttendanceChecked,
  }) {
    return UserInfo(
      id: id ?? this.id,
      grade: grade ?? this.grade,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      profileImg: profileImg ?? this.profileImg,
      // isLogined: isLogined ?? this.isLogined,
      classNo: classNo ?? this.classNo,
      eduState: eduState ?? this.eduState,
      accessJwt: accessJwt,
      refreshJwt: refreshJwt,
      isAttendanceChecked: isAttendanceChecked ?? this.isAttendanceChecked,
    );
  }
}

class UserSessionNotifier extends StateNotifier<UserInfo>
    with WidgetsBindingObserver {
  UserSessionNotifier()
    : super(
        UserInfo(
          id: "",
          grade: -1,
          name: "",
          userId: "",
          profileImg: "",
          // isLogined: false,
          classNo: "",
          eduState: StudentEduState(
            incorrectWords: [],
            correctWords: [],
            accmulatedWords: [],
            learningTime: 0,
            attendance: Map<String, dynamic>(),
            grade: -1,
          ),
          accessJwt: null,
          refreshJwt: null,
          isAttendanceChecked: false,
        ),
      ) {
    WidgetsBinding.instance.addObserver(this);
  }
  Timer? _timer;
  AppLifecycleState _state = AppLifecycleState.resumed;
  bool _isStartTimer = false;

  Future<void> _updateLearningTime() async {
    SupabaseAPI client = SupabaseAPI.getInstance();
    await client.updateUserRunningTime(state.id, state.eduState.learningTime);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _state = state;
    // print("AppLifecycleNotifier : $state");
    if (state == AppLifecycleState.paused) {
      _updateLearningTime();

      if (_isStartTimer) {
        _isStartTimer = false;
        _timer?.cancel();
      }
    } else if (state == AppLifecycleState.resumed && _isStartTimer == false) {
      _isStartTimer = true;
      _startTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      StudentEduState eduState = StudentEduState(
        incorrectWords: state.eduState.incorrectWords,
        correctWords: state.eduState.correctWords,
        accmulatedWords: state.eduState.accmulatedWords,
        attendance: state.eduState.attendance,
        learningTime: state.eduState.learningTime + 1,
        grade: state.grade,
      );
      state = state.copyWith(
        eduState: eduState,
        accessJwt: state.accessJwt,
        refreshJwt: state.refreshJwt,
      );
    });
  }

  String? getToken() => state.accessJwt;
  void setSession(UserInfo userInfo) {
    state = userInfo;
  }

  void clear() {
    state = state.copyWith(accessJwt: null);
    _timer?.cancel();
    _isStartTimer = false;
    _updateLearningTime();
  }

  bool isLoggedIn() {
    if (state.accessJwt == null) return false;

    if (_isStartTimer == false) {
      _startTimer();
      _isStartTimer = true;
    }

    return true;
  }

  bool isCheckAttendance() {
    return state.isAttendanceChecked;
  }

  void checkAttendance() {
    state = UserInfo(
      id: state.id,
      grade: state.grade,
      name: state.name,
      userId: state.userId,
      profileImg: state.profileImg,
      // isLogined: false,
      classNo: state.classNo,
      eduState: StudentEduState(
        incorrectWords: state.eduState.incorrectWords,
        correctWords: state.eduState.correctWords,
        accmulatedWords: state.eduState.accmulatedWords,
        learningTime: state.eduState.learningTime,
        attendance: state.eduState.attendance,
        grade: state.grade,
      ),
      accessJwt: state.accessJwt,
      refreshJwt: state.refreshJwt,
      isAttendanceChecked: false,
    );
  }

  String getUserId() {
    return state.id;
  }

  Future<void> accumulateWords(Quiz? quiz) async {
    List<StudyWords> newAccumulatedWords = [...state.eduState.accmulatedWords];

    // 이미 존재하는 단어이면, 기록에서 생략한다.
    for (int i = 0; i < newAccumulatedWords.length; i++) {
      if (newAccumulatedWords[i].id == quiz!.id) return;
    }

    // 존재하지 않는 단어이면, 기록한다.
    newAccumulatedWords.add(
      StudyWords(id: quiz!.id, count: 0, grade: quiz.grade),
    );

    StudentEduState eduState = StudentEduState(
      incorrectWords: state.eduState.incorrectWords,
      correctWords: state.eduState.correctWords,
      accmulatedWords: newAccumulatedWords,
      attendance: state.eduState.attendance,
      learningTime: state.eduState.learningTime,
      grade: state.grade,
    );

    state = state.copyWith(
      eduState: eduState,
      accessJwt: state.accessJwt,
      refreshJwt: state.refreshJwt,
    );
    SupabaseAPI client = SupabaseAPI.getInstance();
    await client.accumulateWords(quiz, state.id);
  }

  Future<void> updateCorrectness(Quiz? quiz, bool isCorrect) async {
    bool existWords = false;
    int quizId = quiz!.id;
    int grade = quiz.grade;

    // 정답일 경우,
    if (isCorrect) {
      List<StudyWords> newCorrect = [...state.eduState.correctWords];

      for (int i = 0; i < newCorrect.length; i++) {
        if (newCorrect[i].id == quizId) {
          newCorrect[i].count++;
          existWords = true;
          break;
        }
      }

      if (existWords == false)
        newCorrect.add(StudyWords(id: quizId, count: 1, grade: grade));

      StudentEduState eduState = StudentEduState(
        incorrectWords: state.eduState.incorrectWords,
        correctWords: newCorrect,
        accmulatedWords: state.eduState.accmulatedWords,
        attendance: state.eduState.attendance,
        learningTime: state.eduState.learningTime,
        grade: state.grade,
      );
      state = state.copyWith(
        eduState: eduState,
        accessJwt: state.accessJwt,
        refreshJwt: state.refreshJwt,
      );
    }
    // 오답일 경우
    else {
      List<StudyWords> newIncorrect = [...state.eduState.incorrectWords];

      for (int i = 0; i < newIncorrect.length; i++) {
        if (newIncorrect[i].id == quizId) {
          newIncorrect[i].count++;
          break;
        }
      }

      if (existWords == false)
        newIncorrect.add(StudyWords(id: quizId, count: 1, grade: grade));

      StudentEduState eduState = StudentEduState(
        incorrectWords: newIncorrect,
        correctWords: state.eduState.correctWords,
        accmulatedWords: state.eduState.accmulatedWords,
        attendance: state.eduState.attendance,
        learningTime: state.eduState.learningTime,
        grade: state.grade,
      );
      state = state.copyWith(
        eduState: eduState,
        accessJwt: state.accessJwt,
        refreshJwt: state.refreshJwt,
      );
    }

    SupabaseAPI client = SupabaseAPI.getInstance();
    await client.UpdateCorrectness(quiz, state.id, isCorrect);
  }

  void changeUserGrade(int grade) {
    state = state.copyWith(
      grade: grade,
      accessJwt: state.accessJwt,
      refreshJwt: state.refreshJwt,
    );
  }

  void changeUserProfileImage(String? storagePath) {
    state = state.copyWith(
      profileImg: storagePath,
      accessJwt: state.accessJwt,
      refreshJwt: state.refreshJwt,
    );
  }

  void truncateAccumulatedWords() {
    StudentEduState eduState = StudentEduState(
      incorrectWords: state.eduState.incorrectWords,
      correctWords: state.eduState.correctWords,
      accmulatedWords: [],
      attendance: state.eduState.attendance,
      learningTime: state.eduState.learningTime,
      grade: state.grade,
    );
    state = state.copyWith(eduState: eduState);
  }
}

final userSessionTokenProvider =
    StateNotifierProvider<UserSessionNotifier, UserInfo>((ref) {
      return UserSessionNotifier();
    });
