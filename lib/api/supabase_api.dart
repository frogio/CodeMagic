import 'dart:convert';
import 'dart:io';

import 'package:english_word_app/models/student_edu_state.dart';
import 'package:english_word_app/models/study_words.dart';
import 'package:english_word_app/provider/session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/qna.dart';
import '../models/quiz.dart';
import '../models/word.dart';

class SupabaseAPI {
  static SupabaseAPI _instance = SupabaseAPI._private();
  late String? _jwt;
  final String _ACTION = "action";
  final String _TARGET = "target";
  late SupabaseClient supabaseClient;

  SupabaseAPI._private();

  static SupabaseAPI getInstance() {
    return _instance;
  }

  String? getToken() {
    return _jwt;
  }

  void init() {
    supabaseClient = Supabase.instance.client;
  }

  Future<List<StudyWords>> checkAccumulatedWords(
    Map<String, dynamic> accum,
    String userId,
  ) async {
    List<StudyWords> result;

    // 어떠한 단어도 누적되어있지 않은 빈 상태일 경우,
    if (accum.isEmpty) {
      try {
        final res = await supabaseClient.functions.invoke(
          'GenerateQuiz',
          body: {
            _TARGET: "update",
            _ACTION: "create_user_accum",
            "userId": userId,
          },
        );
        // print(res.data);
        return [];
      } catch (error) {
        print(error);
        return [];
      }
    }
    // 단어가 누적된 상태일 경우
    else {
      int accumTimestamp = int.parse(accum["timestamp"].toString());
      List<dynamic> accumWords = accum["words"];

      DateTime date = DateTime.now();
      int sevenDayInMillis = 7 * 24 * 60 * 60 * 1000;

      // timestamp가 유효하지 않다면, 누적단어는 파기 후 재 갱신
      if (accumTimestamp + sevenDayInMillis < date.millisecondsSinceEpoch) {
        final res = await supabaseClient.functions.invoke(
          'GenerateQuiz',
          body: {
            _TARGET: "update",
            _ACTION: "create_user_accum",
            "userId": userId,
          },
        );
        // print(res.data);
        result = [];
      }
      // timestamp가 유효할 경우, 누적단어를 가져옴
      else {
        result = [];
        for (int i = 0; i < accumWords.length; i++) {
          Map<String, dynamic> obj = accumWords[i];
          result.add(
            StudyWords(
              id: int.parse(obj["id"].toString()),
              count: 0,
              grade: int.parse(obj["grade"].toString()),
            ),
          );
        }
        // result.add(int.parse(accumWords[i].toString()));
      }

      return result;
    }
  }

  Future<UserInfo?> GenerateUserInfo(dynamic res) async {
    try {
      final user = res.data;

      final userInfo = user["userInfo"];
      final eduState = user["edustate"];

      List<dynamic> crtWords = eduState["study_words"]["correctWords"];
      List<dynamic> inCrtWords = eduState["study_words"]["incorrectWords"];

      List<StudyWords> correctWords = [];
      List<StudyWords> incorrectWords = [];

      for (int i = 0; i < crtWords.length; i++) {
        correctWords.add(
          StudyWords(
            id: crtWords[i]["id"],
            count: crtWords[i]["count"],
            grade: crtWords[i]["grade"],
          ),
        );
      }

      for (int i = 0; i < inCrtWords.length; i++) {
        incorrectWords.add(
          StudyWords(
            id: inCrtWords[i]["id"],
            count: inCrtWords[i]["count"],
            grade: inCrtWords[i]["grade"],
          ),
        );
      }

      // 누적 단어를 받아와야 함.
      List<StudyWords> accumulatedWords = await checkAccumulatedWords(
        eduState["accumulated_words"],
        userInfo["id"],
      );

      // SSO를 위한 리프레시 토큰 저장
      final secureStorage = FlutterSecureStorage();
      await secureStorage.write(
        key: 'refreshToken',
        value: user["refreshToken"],
      );

      return UserInfo(
        id: userInfo["id"],
        grade: userInfo["grade"],
        name: userInfo["name"],
        userId: userInfo["userId"],
        profileImg: userInfo["profileImg"],
        // isLogined: userInfo["isLogined"],
        classNo: userInfo["classNo"],
        eduState: StudentEduState(
          correctWords: correctWords,
          incorrectWords: incorrectWords,
          accmulatedWords: accumulatedWords,
          attendance: eduState["attendance"],
          learningTime: eduState["learning_time"],
          grade: userInfo["grade"],
        ),
        accessJwt: user["accessToken"],
        refreshJwt: user["refreshToken"],
        isAttendanceChecked: user["isAttendanceChecked"],
      );
    } catch (error) {
      print(error);
    }
  }

  Future<UserInfo?> LoginWithJWT(String refreshToken) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'Account',
        body: {
          _TARGET: "user",
          _ACTION: "login_jwt",
          "refreshJwt": refreshToken,
        },
      );
      return await GenerateUserInfo(res);
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool?> isGoogleAccountExist(String email) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'Account',
        body: {
          _TARGET: "user",
          _ACTION: "check_google_account",
          "email": email,
        },
      );

      bool? result = res.data["result"];
      return result;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool?> isKakaoAccountExist(String name, String phone) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'Account',
        body: {
          _TARGET: "user",
          _ACTION: "check_kakao_account",
          "phone": phone,
          "name": name,
        },
      );

      bool? result = res.data["result"];
      return result;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<UserInfo?> KakaoAccount(Map<String, dynamic> user) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'Account',
        body: {
          _TARGET: "user",
          _ACTION: "kakao_login",
          "name": user["name"],
          "username": user["username"],
          "password": user["password"],
          "is_admin": user["is_admin"],
          "profile_img": user["profile_img"],
          "birthday": user["birthday"],
          "phone": user["phone"],
          "class_no": -1,
          "grade": user["grade"],
        },
      );

      return await GenerateUserInfo(res);
    } catch (error) {
      print(error);
    }
  }

  Future<UserInfo?> GoogleAccount(Map<String, dynamic> user) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'Account',
        body: {
          _TARGET: "user",
          _ACTION: "google_login",
          "name": user["name"],
          "email": user["email"],
          "username": user["username"],
          "password": user["password"],
          "is_admin": user["is_admin"],
          "profile_img": user["profile_img"],
          "birthday": user["birthday"],
          "phone": user["phone"],
          "class_no": -1,
          "grade": user["grade"],
        },
      );

      return await GenerateUserInfo(res);
    } catch (error) {
      print(error);
    }
  }

  Future<UserInfo?> LoginWithIDandPW(String id, String pw) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'Account',
        body: {_TARGET: "user", _ACTION: "login_id_pw", "id": id, "pw": pw},
      );

      return await GenerateUserInfo(res);
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<List<String>> GetBasicChapterByGrade(int grade) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'GenerateQuiz',
        body: {_TARGET: "select", _ACTION: "basic_chapter", "grade": grade},
      );
      List<String> Chapter = [];
      final chapters = res.data["chapters"];

      for (var chapter in chapters) Chapter.add(chapter.toString());

      return Chapter;
    } catch (error) {
      print(error);
      return [];
    }
  }

  Future<List<String>> GetWorkBookChapterByGrade(int grade) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'GenerateQuiz',
        body: {_TARGET: "select", _ACTION: "workbook_chapter", "grade": grade},
      );
      List<String> Chapter = [];
      final chapters = res.data["chapters"];

      for (var chapter in chapters) Chapter.add(chapter.toString());

      return Chapter;
    } catch (error) {
      print(error);
      return [];
    }
  }

  Future<List<Quiz>> GetQuizByChapter(
    int grade,
    List<String> chapter,
    int quizCount,
  ) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'GenerateQuiz',
        body: {
          _TARGET: "select",
          _ACTION: "quizzes_by_chapter",
          "grade": grade,
          "chapters": chapter,
          "quizCount": quizCount,
        },
      );

      List<dynamic> quizzes = res.data["quizzes"];
      List<Quiz> result = [];
      for (int i = 0; i < quizzes.length; i++) {
        result.add(
          Quiz(
            id: int.parse(quizzes[i]["id"].toString()),
            chapter: quizzes[i]["chapter"].toString(),
            word: quizzes[i]["word"].toString(),
            sentence: quizzes[i]["sentence"].toString(),
            translation: quizzes[i]["translation"].toString(),
            meaning: quizzes[i]["meaning"].toString(),
            grade: int.parse(quizzes[i]["grade"].toString()),
          ),
        );
      }

      return result;
    } catch (error) {
      return [
        Quiz(
          id: -1,
          chapter: "-1",
          word: "-1",
          sentence: "-1",
          translation: "-1",
          meaning: "-1",
          grade: -1,
        ),
      ];
    }
  }

  Future<int> GetWordCountByChapter(List<String> chapters) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'GenerateQuiz',
        body: {
          _TARGET: "select",
          _ACTION: "word_count_by_chapters",
          "chapters": chapters,
        },
      );
      // print(res.data["wordCountByChapter"]);
      return res.data["wordCountByChapter"];
    } catch (error) {
      print(error);
      return -1;
    }
  }

  Future<int> GetWordCountByGrade(int grade) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'GenerateQuiz',
        body: {
          _TARGET: "select",
          _ACTION: "word_count_by_grade",
          "grade": grade,
        },
      );

      final count = int.parse(res.data["count"].toString());

      return count;
    } catch (error) {
      print(error);
      return -1;
    }
  }

  Future<void> accumulateWords(Quiz quiz, String id) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'GenerateQuiz',
        body: {
          _TARGET: "update",
          _ACTION: "accumulate_user_words",
          "userId": id,
          "wordId": quiz.id,
          "grade": quiz.grade,
        },
      );
      // print(res.data);
    } catch (error) {
      print(error);
    }
  }

  Future<void> UpdateCorrectness(Quiz? quiz, String id, bool isCorrect) async {
    // 로컬에서 정답 여부를 저장한 후,
    try {
      // 서버에서 정답 여부를 저장한다.
      final res = await supabaseClient.functions.invoke(
        'GenerateQuiz',
        body: {
          _TARGET: "update",
          _ACTION: "update_user_study_words",
          "userId": id,
          "quizId": quiz!.id,
          "grade": quiz.grade,
          "isCorrect": isCorrect,
        },
      );
      // print(res.data);
    } catch (error) {
      print(error);
    }
  }

  Future<List<Word>> GetWrongWordByIds(
    List<int> ids,
    int page,
    int count,
  ) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'GenerateQuiz',
        body: {
          _TARGET: "select",
          _ACTION: "worngwords_by_ids",
          "ids": ids,
          "page": page,
          "count": count,
        },
      );
      // print(res.data);

      List<dynamic> datas = res.data["words"];
      List<Word> words = [];
      for (var data in datas)
        words.add(Word(id: data["id"], word: data["word"]));

      // print(res.data);
      return words;
    } catch (error) {
      print(error);
      return [];
    }
  }

  Future<Map<String, dynamic>> GetWordsByGrade(
    int grade,
    int page,
    int count,
  ) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'GenerateQuiz',
        body: {
          _TARGET: "select",
          _ACTION: "words_by_grade",
          "grade": grade,
          "page": page,
          "count": count,
        },
      );

      List<Word> list = [];
      final words = res.data["result"];
      final maxCount = res.data["maxCount"]["count"];

      for (var word in words) {
        list.add(Word(id: word["id"], word: word["word"]));
      }

      return {"wordList": list.reversed.toList(), "maxCount": maxCount};
    } catch (error) {
      print(error);
      return {};
    }
  }

  Future<Map<String, dynamic>> getQnAPage(int curPage, int count) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'UserQnA',
        body: {
          _TARGET: "qna",
          _ACTION: "get_qna_page",
          "curPage": curPage,
          "count": count,
        },
      );
      List<QnA> list = [];
      final qnas = res.data["qnas"];
      final maxCount = res.data["maxCount"];

      for (var qna in qnas) {
        list.add(
          QnA(
            date: qna["date"],
            question: qna["question"],
            answer: qna["answer"],
          ),
        );
      }

      return {"qnas": list.reversed.toList(), "maxCount": maxCount};
    } catch (error) {
      print(error);
      return {};
    }
  }

  Future<void> registerQnA(Map<String, String> question, String id) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'UserQnA',
        body: {
          _TARGET: "qna",
          _ACTION: "register_qna",
          "id": id,
          "question": {
            "name": question["qnaName"],
            "content": question["question"],
          },
        },
      );
      // print(res.data);
    } catch (error) {
      print(error);
    }
  }

  Future<void> withdrawAccount(String id, String? jwt) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'Account',
        body: {_TARGET: "user", _ACTION: "withdraw", "id": id, "jwt": jwt},
      );
      // print(res.data);
    } catch (error) {
      print(error);
    }
  }

  Future<void> changeUserPasswordInLoginScreen(String id, String pw) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'Account',
        body: {
          _TARGET: "user",
          _ACTION: "change_pw_in_login",
          "id": id,
          "pw": pw,
        },
      );

      print(res.data);
    } catch (error) {
      print(error);
    }
  }

  Future<void> changeUserGrade(String uuid, String grade, String jwt) async {
    try {
      int gradeNo = 0;
      switch (grade) {
        case "1학년":
          gradeNo = 1;
          break;
        case "2학년":
          gradeNo = 2;
          break;
        case "3학년":
          gradeNo = 3;
          break;
      }

      final res = await supabaseClient.functions.invoke(
        'Account',
        body: {
          _TARGET: "user",
          _ACTION: "change_user_grade",
          "uuid": uuid,
          "grade": gradeNo,
          "jwt": jwt,
        },
      );

      // print(res.data);
    } catch (error) {
      print(error);
    }
  }

  Future<void> changeUserPassword(String id, String pw, String? jwt) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'Account',
        body: {
          _TARGET: "user",
          _ACTION: "change_pw",
          "id": id,
          "pw": pw,
          "jwt": jwt,
        },
      );
      //print(res.data);
    } catch (error) {
      print(error);
    }
  }

  Future<List<Quiz>?> getQuizzesByWrongWord(List<int> ids) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'GenerateQuiz',
        body: {_TARGET: "select", _ACTION: "quizzes_by_wrongword", "ids": ids},
      );
      List<dynamic> quizzes = res.data["quizzes"];

      List<Quiz> result = [];

      for (int i = 0; i < quizzes.length; i++) {
        result.add(
          Quiz(
            id: int.parse(quizzes[i]["id"].toString()),
            chapter: quizzes[i]["chapter"].toString(),
            word: quizzes[i]["word"].toString(),
            sentence: quizzes[i]["sentence"].toString(),
            translation: quizzes[i]["translation"].toString(),
            meaning: quizzes[i]["meaning"].toString(),
            grade: int.parse(quizzes[i]["grade"].toString()),
          ),
        );
      }

      return result;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<List<Quiz>> getQuizzesById(List<int> ids, int count) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'GenerateQuiz',
        body: {
          _TARGET: "select",
          _ACTION: "quizzes_by_id",
          "ids": ids,
          "count": count,
        },
      );
      // print(res.data);
      List<dynamic> quizzes = res.data["quizzes"];

      List<Quiz> result = [];

      for (int i = 0; i < quizzes.length; i++) {
        result.add(
          Quiz(
            id: int.parse(quizzes[i]["id"].toString()),
            chapter: quizzes[i]["chapter"].toString(),
            word: quizzes[i]["word"].toString(),
            sentence: quizzes[i]["sentence"].toString(),
            translation: quizzes[i]["translation"].toString(),
            meaning: quizzes[i]["meaning"].toString(),
            grade: int.parse(quizzes[i]["grade"].toString()),
          ),
        );
      }

      return result;
    } catch (error) {
      print(error);
      return [];
    }
  }

  Future<String?> FindIdByPhone(String phone) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'Account',
        body: {_TARGET: "user", _ACTION: "find_id", "phone": phone},
      );

      return res.data["id"].toString();
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<String?> changeProfileImage(
    File image,
    String uuid,
    String extension,
  ) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      // 업로드 하기 전, image binart를 base64로 encoding한다.
      final res = await supabaseClient.functions.invoke(
        'Account',
        body: {
          _TARGET: "user",
          _ACTION: "change_user_profile_img",
          "base64Encoded": base64Image,
          "uuid": uuid,
          "extension": extension,
          "mime_type": "image/$extension",
        },
      );

      // print(res.data);
      final Map<String, dynamic> data = jsonDecode(res.data);

      return data["storagePath"];
    } catch (error) {
      print(error);
      return null;
    }
  }

  String? getProfileImageURL(String storagePath) {
    return supabaseClient.storage.from("profileimg").getPublicUrl(storagePath);
  }

  Future<void> updateUserRunningTime(String uuid, int time) async {
    try {
      final res = await supabaseClient.functions.invoke(
        'Account',
        body: {
          _TARGET: "user",
          _ACTION: "update_learning_time",
          "uuid": uuid,
          "time": time,
        },
      );

      // print(res.data);
    } catch (error) {
      print(error);
    }
  }
}
