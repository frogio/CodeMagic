// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:english_word_app/api/supabase_api.dart';
import 'package:english_word_app/components/common/common_text.dart';
import 'package:english_word_app/components/quiz_screen/quiz_box.dart';
import 'package:english_word_app/consts/colors.dart';
import 'package:english_word_app/consts/enums.dart';
import 'package:english_word_app/provider/mistake_note_provider.dart';
import 'package:english_word_app/provider/quiz_provider.dart';
import 'package:english_word_app/provider/session.dart';
import 'package:english_word_app/provider/today_word_condition.dart';
import 'package:flutter/material.dart';
import '../../components/main_tab_controller.dart';
import '../../components/dialog/common_dialog.dart';
import '../../consts/image_assets.dart';
import '../../models/quiz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/word.dart';
import '../common/safe_input_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  QuizType? quizType;
  QuizScreen({super.key, this.quizType});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  Future<List<Quiz>?>? _quizzes;
  List<Quiz> result = [];
  String endMessage = "";

  @override
  void initState() {
    super.initState();

    // quizType에 따라 퀴즈 종료 메시지를 변경한다.
    if (widget.quizType != null) {
      if (widget.quizType == QuizType.Basic)
        endMessage = "오늘의 단어가 끝났습니다.";
      else if (widget.quizType == QuizType.WordSelect)
        endMessage = "오늘의 단어가 끝났습니다.";
      else if (widget.quizType == QuizType.MistakeNote)
        endMessage = "오답 노트가 끝났습니다.";
    } else
      endMessage = "오늘의 단어가 끝났습니다.";
    // 기본은 "오늘의 단어가 끝났습니다." 메시지를 띄운다.

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        ref.read(quizProvider.notifier).quizConfirm(false);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quizzes = getQuizCount(ref).then((result) {
        if (result != null) {
          setState(() {
            ref
                .read(quizProvider.notifier)
                .setQuizzes(result.length, result, true);
          });
        } else
          Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final conditions = ref.watch(todayWordConditionProvider);
    final conditionsNoti = ref.read(todayWordConditionProvider.notifier);
    final quizNotifier = ref.read(quizProvider.notifier);
    String? appBarTitle = "";
    if (conditions.selectedEduProcess == null) {
      if (conditions.selectedEduType == EduType.RepeatEdu)
        appBarTitle = "반복 학습하기";
    } else
      String? appBarTitle = conditions.selectedEduProcess;

    // 퀴즈가 끝이 났는지를 감시한다.
    ref.listen<QuizSet>(quizProvider, (previous, next) async {
      if (previous?.isEndedQuiz == false && next.isEndedQuiz) {
        setState(() {});
        conditionsNoti.truncateState();
        quizNotifier.truncateState();
        await CommonDialog.endQuizDialog(context, endMessage).then((result) {
          if (result == EndQuizNavigation.GoHome) {
            MainTabController tabController = MainTabController.getInstance();
            tabController.getTab(-1);
            // -1은 Home화면
            Navigator.pop(context);
          } else if (result == EndQuizNavigation.BackToCondition) {
            Navigator.pop(context);
          }
        });
      }
    });

    return PopScope(
      onPopInvoked: (didPop) {
        conditionsNoti.truncateState();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.only(left: 30),
              child: Icon(
                Icons.arrow_back_ios_sharp,
                color: MainColors.MainWhite,
              ),
            ),
          ),
          title: CommonText(
            text: appBarTitle ?? "",
            style: TextStyle(color: MainColors.MainWhite, fontSize: 20),
          ),
          backgroundColor: MainColors.QuizScreenAppBarColor,
        ),
        body:
            quizNotifier.isQuizConfirmed()
                ? SafeInputScreen(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          ImageAssets.BACKGROUND1,
                        ), // Local image
                        fit: BoxFit.cover, // Cover the entire container
                      ),
                    ),
                    child:
                        quizNotifier.isEndedQuiz()
                            ? SizedBox()
                            : Container(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Stack(
                                // decoration: BoxDecoration(color: MainColors.MainWhite),
                                children: [
                                  Center(
                                    child: SizedBox(
                                      width: 400,
                                      height: 450,
                                      child: QuizBox(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                )
                : FutureBuilder(
                  future: _quizzes,
                  builder: (context, snapshot) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            ImageAssets.BACKGROUND1,
                          ), // Local image
                          fit: BoxFit.cover, // Cover the entire container
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  Future<List<Quiz>?> getQuizCount(WidgetRef ref) async {
    if (widget.quizType == null ||
        widget.quizType == QuizType.Basic ||
        widget.quizType == QuizType.WORKBOOK) {
      return await CommonDialog.getQuizDialog(context, ref);
    } else if (widget.quizType == QuizType.WordSelect) {
      // 틀린 단어들이 선택되었을 때,
      // dynamic Type에서 Word id를 추출한다.
      final condition = ref.watch(todayWordConditionProvider);

      List<int> selectedWordId = [];
      for (var word in condition.selectedValues) {
        if (word is Word) {
          selectedWordId.add(word.id);
        }
      }

      SupabaseAPI client = SupabaseAPI.getInstance();
      return await client.getQuizzesByWrongWord(selectedWordId);
      // 단어 선택하기 옵션에서 선택된 단어를 가져온다.
    } else if (widget.quizType == QuizType.MistakeNote) {
      // 오답 노트에서 들어올 경우,
      final condition = ref.watch(mistakeNoteProvider);

      List<int> selectedWordId = [];
      for (var index in condition.selectedWordIndex) {
        selectedWordId.add(condition.wordList[index].id);
      }

      SupabaseAPI client = SupabaseAPI.getInstance();
      return await client.getQuizzesByWrongWord(selectedWordId);
    }
  }
}
