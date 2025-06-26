import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:english_word_app/api/supabase_api.dart';
import 'package:english_word_app/components/caption_text_field.dart';
import 'package:english_word_app/components/common/fat_button.dart';
import 'package:english_word_app/consts/image_assets.dart';
import 'package:english_word_app/models/study_words.dart';
import 'package:english_word_app/models/word.dart';
import 'package:english_word_app/provider/session.dart';
import 'package:english_word_app/provider/today_word_condition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/common_button.dart';
import '../common/common_text.dart';
import '../common/text_field.dart';
import '../../consts/colors.dart';
import '../../consts/enums.dart';
import '../../models/quiz.dart';

class CommonDialog {
  static Dialog makeCommonDialog(
    List<Widget> dialogContents,
    double width,
    double height,
  ) {
    return Dialog(
      elevation: 16,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dialogContents,
        ),
      ),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context,
    String message,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 16,
          child: Container(
            width: 400,
            height: 220,
            decoration: BoxDecoration(
              color: MainColors.MainWhite,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40),
                CommonText(
                  text: message,
                  style: TextStyle(fontSize: 20, color: Colors.black87),
                ),
                SizedBox(height: 60),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: CommonButton(
                        buttonName: "확인",
                        callback: () {
                          Navigator.pop(context, true);
                        },
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: MainColors.PrimaryColorShade,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: CommonButton(
                        buttonName: "취소",
                        callback: () {
                          Navigator.pop(context, false);
                        },
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: MainColors.PrimaryColorShade,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<List<Quiz>?> getQuizDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    TextEditingController quizCount = TextEditingController();
    final userInfo = ref.watch(userSessionTokenProvider);
    final conditions = ref.watch(todayWordConditionProvider);
    final notifier = ref.read(todayWordConditionProvider.notifier);
    bool isInValidCount = false;
    bool isLoad = false;
    int limitCount = 10;

    return showDialog<List<Quiz>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            quizCount.addListener(() {
              setState(() {});
            });

            return Dialog(
              elevation: 16,
              child: Container(
                width: 400,
                height: 270,
                decoration: BoxDecoration(
                  color: MainColors.MainWhite,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(height: 25),
                            isLoad
                                ? CircularProgressIndicator()
                                : CommonText(
                                  text:
                                      isInValidCount
                                          ? "1 ~ $limitCount 사이의 숫자를 입력해주세요!"
                                          : "몇개의 문제를 풀어볼까요?",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color:
                                        isInValidCount
                                            ? MainColors.MainRed
                                            : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Textfield(
                          hintText: "풀어볼 단어 갯수를 입력",
                          keyboardType: TextInputType.number,
                          controller: quizCount,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: CommonButton(
                        buttonName: "확인",
                        callback:
                            quizCount.text != ""
                                ? () async {
                                  SupabaseAPI client =
                                      SupabaseAPI.getInstance();

                                  //
                                  //
                                  // 사용자로부터 입력받은 문제의 조건값
                                  // dynamic 타입을 문맥에 맞게 해석할 필요 있음!
                                  //
                                  //
                                  EduType type = conditions.selectedEduType;
                                  int grade = notifier.getGrade();
                                  int count = int.parse(quizCount.text);
                                  List<dynamic> selectedValues =
                                      conditions.selectedValues;

                                  // 문맥에 맞게 변환된 조건값
                                  List<String> selectedChapters = [];
                                  List<Word> selectedWords = [];

                                  // 최종 결과 : Quiz...
                                  List<Quiz> result = [];

                                  if (type == EduType.BasicEdu) {
                                    switch (conditions.selectedEduProcess) {
                                      case "워크북 과정":
                                      case "기본 과정":

                                        // dynamic 타입을 String Value로 컨버팅
                                        for (var value in selectedValues) {
                                          selectedChapters.add(
                                            value.toString(),
                                          );
                                        }

                                        setState(() {
                                          isLoad = true;
                                        });

                                        // 단어의 개수가 유효한지 먼저 체크한다.
                                        int wordCountByChapters =
                                            await client.GetWordCountByChapter(
                                              selectedChapters,
                                            );

                                        setState(() {
                                          isLoad = false;
                                        });

                                        if (limitCount > wordCountByChapters)
                                          limitCount = wordCountByChapters;

                                        // 개수가 유효하지 않으면 취소한다.
                                        if (count <= 0 || count > limitCount) {
                                          setState(() {
                                            isInValidCount = true;
                                          });
                                          return;
                                        }

                                        setState(() {
                                          isLoad = true;
                                        });

                                        result = await client.GetQuizByChapter(
                                          grade,
                                          selectedChapters,
                                          count,
                                        );

                                        setState(() {
                                          isLoad = false;
                                        });

                                        break;
                                      // case "단어 선택하기":
                                      //   for (var word in selectedValues) {
                                      //     if (word is Word) {
                                      //       selectedWords.add(
                                      //         Word(
                                      //           id: word.id,
                                      //           word: word.word,
                                      //         ),
                                      //       );
                                      //     }
                                      //   }
                                      //   break;
                                    }
                                  } else if (type == EduType.RepeatEdu) {
                                    int repeatWordCount = selectedValues.length;

                                    if (limitCount > repeatWordCount)
                                      limitCount = repeatWordCount;

                                    // 개수가 유효하지 않으면 취소한다.
                                    if (count <= 0 || count > limitCount) {
                                      setState(() {
                                        isInValidCount = true;
                                      });
                                      return;
                                    }

                                    setState(() {
                                      isLoad = true;
                                    });

                                    // dynamic type을 문맥에 맞게 변환
                                    List<int> selectedQuizIds = [];
                                    for (var value in selectedValues) {
                                      selectedQuizIds.add(value);
                                    }

                                    result = await client.getQuizzesById(
                                      selectedQuizIds,
                                      count,
                                    );

                                    setState(() {
                                      isLoad = false;
                                    });
                                  } else if (type == EduType.Accumulated) {
                                    int accumCount = selectedValues.length;

                                    if (limitCount > accumCount)
                                      limitCount = accumCount;

                                    // 개수가 유효하지 않으면 취소한다.
                                    if (count <= 0 || count > limitCount) {
                                      setState(() {
                                        isInValidCount = true;
                                      });
                                      return;
                                    }

                                    // dynamic type을 문맥에 맞게 변환
                                    List<int> selectedQuizIds = [];
                                    for (var value in selectedValues) {
                                      selectedQuizIds.add(value);
                                    }

                                    setState(() {
                                      isLoad = true;
                                    });

                                    result = await client.getQuizzesById(
                                      selectedQuizIds,
                                      count,
                                    );

                                    setState(() {
                                      isLoad = false;
                                    });

                                    // 누적단어 생성
                                  }
                                  Navigator.pop(context, result);
                                }
                                : null,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:
                              quizCount.text != ""
                                  ? MainColors.PrimaryColor
                                  : MainColors.PrimaryColorDisable,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<EndQuizNavigation?> endQuizDialog(
    BuildContext context,
    String message,
  ) async {
    return showDialog<EndQuizNavigation>(
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 16,
          child: Container(
            width: 450,
            height: 280,
            decoration: BoxDecoration(
              color: MainColors.MainWhite,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(ImageAssets.CONFIRM_MARK),
                CommonText(
                  text: message,
                  style: TextStyle(
                    color: MainColors.MainGray,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: FatButton(
                        callback: () {
                          Navigator.pop(
                            context,
                            EndQuizNavigation.BackToCondition,
                          );
                        },
                        buttonName: "처음으로",
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: MainColors.PrimaryColor,
                        ),
                        style: TextStyle(
                          color: MainColors.MainWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: FatButton(
                        callback: () {
                          Navigator.pop(context, EndQuizNavigation.GoHome);
                        },
                        buttonName: "홈으로",
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: MainColors.MainGray,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: MainColors.BorderGray,
                        ),
                        style: TextStyle(
                          color: MainColors.PrimaryColorShade,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<Map<String, String>?> getQnADialog(BuildContext context) async {
    TextEditingController qnaController = TextEditingController();
    TextEditingController qnaNameController = TextEditingController();
    return showDialog<Map<String, String>?>(
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 16,
          child: Container(
            width: 450,
            height: 430,
            decoration: BoxDecoration(
              color: MainColors.MainWhite,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: CommonText(
                      text: "문의 내역을 입력하세요.",
                      style: TextStyle(
                        fontSize: 20,
                        color: MainColors.MainBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    controller: qnaNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "문의 제목",
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      controller: qnaController,
                      maxLines: 7,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "문의 내역을 입력하세요",
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: FatButton(
                            callback: () {
                              Map<String, String> map = {
                                "qnaName": qnaNameController.text,
                                "question": qnaController.text,
                              };

                              Navigator.pop(context, map);
                            },
                            buttonName: "등록",
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: MainColors.PrimaryColor,
                            ),
                            style: TextStyle(
                              color: MainColors.MainWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          flex: 1,
                          child: FatButton(
                            callback: () {
                              Navigator.pop(context, null);
                            },
                            buttonName: "취소",
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: MainColors.PrimaryColor,
                            ),
                            style: TextStyle(
                              color: MainColors.MainWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<bool?> withdrwaDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 16,
          child: Container(
            width: 450,
            height: 300,
            decoration: BoxDecoration(
              color: MainColors.MainWhite,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: CommonText(
                      text: "정말로 탈퇴하시겠습니까?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      CommonButton(
                        buttonName: "예",
                        style: TextStyle(
                          color: MainColors.MainGray,
                          fontSize: 17,
                        ),
                        callback: () {
                          Navigator.pop(context, true);
                        },
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: MainColors.BorderGray,
                        ),
                      ),
                      SizedBox(height: 10),
                      CommonButton(
                        buttonName: "아니오",
                        callback: () {
                          Navigator.pop(context, false);
                        },
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: MainColors.PrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<String?> changedPasswordDialog(BuildContext context) async {
    TextEditingController pw = TextEditingController();
    TextEditingController pwConfirm = TextEditingController();
    bool isMatched = false;
    return showDialog<String?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              elevation: 16,
              child: Container(
                width: 450,
                height: 380,
                decoration: BoxDecoration(
                  color: MainColors.MainWhite,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: CommonText(
                          text: "비밀번호 재설정",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          CaptionTextField(
                            controller: pw,
                            obsecureMode: true,
                            caption: "비밀번호",
                            hintText: "비밀번호를 입력해주세요.",
                          ),
                          SizedBox(height: 10),
                          Textfield(
                            controller: pwConfirm,
                            obsecureMode: true,
                            hintText: "비밀번호를 재입력 해주세요",
                          ),
                          SizedBox(height: 5),
                          isMatched == false
                              ? SizedBox()
                              : CommonText(
                                text: "비밀번호가 일치하지 않습니다.",
                                style: TextStyle(color: MainColors.MainRed),
                              ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: FatButton(
                              buttonName: "취소",
                              callback: () {
                                Navigator.pop(context, null);
                              },
                              style: TextStyle(color: MainColors.MainGray),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: MainColors.BorderGray,
                              ),
                            ),
                          ),

                          SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: FatButton(
                              buttonName: "확인",
                              callback: () {
                                if (pw.text != pwConfirm.text) {
                                  setState(() {
                                    isMatched = true;
                                  });
                                } else {
                                  Navigator.pop(context, pw.text);
                                }
                              },
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: MainColors.PrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
