import 'package:english_word_app/api/tts_api.dart';
import 'package:english_word_app/components/common/common_button.dart';
import 'package:english_word_app/components/common/common_text.dart';
import 'package:english_word_app/components/common/fat_button.dart';
import 'package:english_word_app/components/dialog/common_dialog.dart';
import 'package:english_word_app/components/quiz_screen/quiz_sentence.dart';
import 'package:english_word_app/consts/colors.dart';
import 'package:english_word_app/consts/image_assets.dart';
import 'package:english_word_app/provider/quiz_provider.dart';
import 'package:english_word_app/provider/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/quiz.dart';
import './answer_field.dart';
import './jaro_winkler.dart';

class QuizBox extends ConsumerStatefulWidget {
  const QuizBox({super.key});

  @override
  ConsumerState<QuizBox> createState() => _QuizBoxState();
}

class _QuizBoxState extends ConsumerState<QuizBox> {
  Quiz? _quiz;
  bool _isSendAnswer = false;
  bool _isCorrected = false;
  bool _almostMatched = false;
  // 사용자가 입력한 답과 문제의 답의 일치가 1 ~ 2글자 차이일 경우, true

  int _challengeCount = 0;
  // 도전 횟수.

  String _answer = "";
  int _hintPressCount = 0;
  TextEditingController _answerField = TextEditingController();
  late List<Widget> translationWidget;
  late List<Widget> hintWidget;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(quizProvider.notifier);
      _answer = notifier.getAnswer();
    });
  }

  String getSubAnswer() {
    String hint = "";
    String userAnswer = _answerField.text;
    int lastIdx = userAnswer.length - 1;
    String subAnswer = "";
    if (_quiz!.word.length < userAnswer.length)
      subAnswer = _quiz!.word;
    else
      subAnswer = _quiz!.word.substring(0, lastIdx + 1);

    // final similarity = CosineSimilarity();
    final score = jaroWinkler(subAnswer, userAnswer);

    // 지금까지 작성한 답의 정확도를 계산해본다.

    if (score < 0.75) {
      // 정확도가 70% 미만일 경우, 한글자만 보여줌
      hint = _quiz!.word[0];
    } else {
      // 정확도가 70% 이상일 경우 2글자 힌트를 추가로 보여줌

      if (_quiz!.word.length - userAnswer.length >= 2) {
        hint =
            "$subAnswer${_quiz!.word[lastIdx + 1]}${_quiz!.word[lastIdx + 2]}";
      } else if (_quiz!.word.length - userAnswer.length == 1) {
        hint = "$subAnswer${_quiz!.word[lastIdx + 1]}";
      } else if (_quiz!.word.length - userAnswer.length == 0) {
        hint = _answer;
      }
    }

    if (hint == _answer) {
      _almostMatched = true;
    } else
      _almostMatched = false;

    return hint;
  }

  void getHintDialog() {
    Widget blankWidget = Container(
      width: 120,
      height: 50,
      decoration: BoxDecoration(
        color: MainColors.LightGray,
        border: Border.all(color: MainColors.BorderGray),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    hintWidget = [
      Expanded(
        flex: 1,
        child: CommonText(text: "힌트", style: TextStyle(fontSize: 20)),
      ),
      Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: MainColors.BorderGray, width: 1),
          ),
        ),
      ),
      Expanded(
        flex: 4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonText(text: getSubAnswer(), style: TextStyle(fontSize: 20)),
            SizedBox(width: 10),
            _almostMatched == false ? blankWidget : SizedBox(),
          ],
        ),
      ),
    ];
  }

  void getTranslationDialog() {
    translationWidget = [
      Expanded(
        flex: 1,
        child: Container(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.cancel, size: 30),
          ),
        ),
      ),
      Expanded(
        flex: 10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonText(
              text: "해설",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 15),
            TextField(
              keyboardType: TextInputType.multiline,
              enabled: false,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: _quiz!.translation,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  void getNextQuiz(QuizProviderNotifier notifier) {
    if (notifier.getNextQuiz()) {
      _answer = notifier.getAnswer();
      _isSendAnswer = false;
      _isCorrected = false;
      _answerField.text = "";
      _hintPressCount = 0;
      _challengeCount = 0;
      _almostMatched = false;
    } else {
      notifier.endQuiz(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(quizProvider.notifier);
    final quizProv = ref.watch(quizProvider);
    final userInfo = ref.read(userSessionTokenProvider.notifier);
    _quiz = notifier.getCurrentQuiz();
    getTranslationDialog();

    return Container(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            flex: 1,
            child:
                _isSendAnswer
                    ? _isCorrected
                        ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: MainColors.PrimaryColorShade,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  ImageAssets.CONFIRM_MARK,
                                  scale: 3.5,
                                ),
                                SizedBox(width: 10),
                                CommonText(
                                  text: "정답입니다!",
                                  style: TextStyle(color: MainColors.MainWhite),
                                ),
                              ],
                            ),
                          ),
                        )
                        : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: MainColors.PrimaryColorShade,
                            ),
                            child: Row(
                              children: [
                                Image.asset(ImageAssets.WRONG_MARK),
                                SizedBox(width: 10),
                                CommonText(
                                  text: "아쉽게도 오답입니다. 다시 작성해보세요!",
                                  style: TextStyle(color: MainColors.MainWhite),
                                ),
                              ],
                            ),
                          ),
                        )
                    : SizedBox(),
          ),
          SizedBox(height: 20),
          Expanded(
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: MainColors.PrimaryColorShade,
                  width: 2,
                ),
                color: MainColors.PrimaryColorLight,
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      alignment: Alignment.topLeft,
                      child: CommonText(
                        text: "빈칸을 채우세요.",
                        style: TextStyle(
                          color: MainColors.PrimaryColorShade,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Center(child: QuizSentence(quiz: _quiz)),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: MainColors.MainWhite,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Center(
                        child: AnswerField(
                          enabled: _isCorrected == false,
                          controller: _answerField,
                          hintText:
                              quizProv
                                  .quizzes[quizProv.quizIdx]
                                  .word /*"답안 작성"*/,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              child:
                  _isCorrected
                      ? Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: CommonButton(
                              style: TextStyle(
                                color: MainColors.MainWhite,
                                fontWeight: FontWeight.w500,
                              ),
                              buttonName: "다음 문제",
                              callback: () {
                                getNextQuiz(notifier);
                              },
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: MainColors.PrimaryColorShade,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: FatButton(
                              buttonName: "해설 보기",
                              callback: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) =>
                                          CommonDialog.makeCommonDialog(
                                            translationWidget,
                                            400,
                                            300,
                                          ),
                                );
                              },
                              style: TextStyle(
                                color: MainColors.PrimaryColorShade,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: MainColors.MainGray,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: MainColors.BorderGray,
                              ),
                            ),
                          ),
                        ],
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _isSendAnswer && _isCorrected == false
                                  ? FatButton(
                                    buttonName: "다음 문제",
                                    callback: () async {
                                      await showDialog(
                                        context: context,
                                        builder:
                                            (context) =>
                                                CommonDialog.makeCommonDialog(
                                                  translationWidget,
                                                  400,
                                                  300,
                                                ),
                                      );
                                      getNextQuiz(notifier);
                                    },
                                    style: TextStyle(
                                      color: MainColors.MainWhite,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: MainColors.PrimaryColorShade,
                                    ),
                                  )
                                  : SizedBox(),
                              _isSendAnswer && _isCorrected == false
                                  ? SizedBox(width: 10)
                                  : SizedBox(),
                              FatButton(
                                buttonName: "힌트 보기",
                                callback: () async {
                                  // 답안이 부분문자일 경우
                                  // 답안 전부를 보여준다.
                                  getHintDialog();

                                  _hintPressCount++;
                                  if (_hintPressCount == 1) {
                                    TTSAPI ttsapi = TTSAPI.getInstance();
                                    await ttsapi.Speak(_quiz!.word);
                                  } else if (_hintPressCount >= 2) {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) =>
                                              CommonDialog.makeCommonDialog(
                                                hintWidget,
                                                400,
                                                200,
                                              ),
                                    );
                                  }
                                },
                                style: TextStyle(
                                  color: MainColors.PrimaryColorShade,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: MainColors.MainGray,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color: MainColors.BorderGray,
                                ),
                              ),
                            ],
                          ),
                          FatButton(
                            buttonName: "답안 제출",
                            callback: () async {
                              TTSAPI ttsapi = TTSAPI.getInstance();
                              _isSendAnswer = true;

                              // 정답
                              if (_answer == _answerField.text.toLowerCase()) {
                                _isCorrected = true;
                                await ttsapi.Speak(_quiz!.sentence);
                              }
                              // 오답
                              else {
                                _isCorrected = false;
                              }
                              _challengeCount++;
                              // 도전 횟수가 한번만일 때만 업데이트 한다.
                              if (_challengeCount == 1) {
                                await userInfo.updateCorrectness(
                                  _quiz,
                                  _isCorrected,
                                );
                              }

                              await userInfo.accumulateWords(_quiz);

                              setState(() {});
                            },
                            style: TextStyle(
                              color: MainColors.PrimaryColorShade,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: MainColors.MainGray,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: MainColors.BorderGray,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
