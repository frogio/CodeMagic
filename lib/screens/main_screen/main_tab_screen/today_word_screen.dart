import 'package:english_word_app/api/supabase_api.dart';
import 'package:english_word_app/components/common/common_button.dart';
import 'package:english_word_app/components/common/common_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:english_word_app/components/common/list_item.dart';
import 'package:english_word_app/components/main_tab_controller.dart';
import 'package:english_word_app/consts/colors.dart';
import 'package:english_word_app/models/quiz.dart';
import 'package:english_word_app/models/study_words.dart';
import 'package:english_word_app/models/word.dart';
import 'package:english_word_app/provider/session.dart';
import 'package:english_word_app/provider/today_word_condition.dart';
import 'package:english_word_app/screens/main_screen/quiz_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../consts/layout.dart';
import '../../../consts/enums.dart';

class TodayWordScreen extends ConsumerStatefulWidget {
  const TodayWordScreen({super.key});

  @override
  ConsumerState<TodayWordScreen> createState() => _TodayWordScreenState();
}

class _TodayWordScreenState extends ConsumerState<TodayWordScreen> {
  final List<String> _grades = ["1학년", "2학년", "3학년"];

  final List<String> _eduProcess = ["기본 과정", "워크북 과정", "단어 선택하기"];
  final List<String> _wordSelect = ["틀린 단어 하기", "많이 틀린 단어 하기"];

  Future<List<String>>? _basicChapters = null;
  Future<List<String>>? _workbookChapters = null;
  Future<List<String>>? _workBooks = null;
  Future<Map<String, dynamic>>? _selectableWord = null;

  final ScrollController _controller = ScrollController();
  bool _isLoad = false;
  @override
  void initState() {
    super.initState();

    _controller.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(todayWordConditionProvider.notifier).truncateState();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    final notifier = ref.read(todayWordConditionProvider.notifier);
    if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 10 &&
        _isLoad == false) {
      _isLoad = true;
      notifier.appendWords();
      _isLoad = false;
      // notifier.loadMoreIfNeeded(ref.read(itemListProvider).length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final conditions = ref.watch(todayWordConditionProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        final controller = MainTabController.getInstance();
        if (conditions.condition1) {
          conditions.condition1 = false;
          ref.read(todayWordConditionProvider.notifier).truncateState();
        } else
          controller.getTab(-1);
        // -1은 Home
      },
      child: Container(
        padding: ScreenLayout.COMMON_TAB_PADING,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:
              conditions.condition1 == false
                  ? ProblemCondition1(conditions, ref)
                  : conditions.selectedEduType == EduType.RepeatEdu
                  ? []
                  : ProblemCondition2(conditions, ref),
        ),
      ),
    );
  }

  List<Widget> ProblemCondition1(TodayWordCondition conditions, WidgetRef ref) {
    final notifier = ref.read(todayWordConditionProvider.notifier);
    final userInfo = ref.watch(userSessionTokenProvider);
    return [
      Expanded(
        flex: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommonText(text: "학년을 선택하세요", style: TextStyle(fontSize: 25)),
            DropdownButtonHideUnderline(
              child: DropdownButton2(
                hint: Text("학년 선택하기"),
                buttonStyleData: ButtonStyleData(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: MainColors.BorderGray, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: MainColors.LighterGray,
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    boxShadow: [],
                    borderRadius: BorderRadius.circular(20),
                    color: MainColors.LightGray,
                    border: Border.all(color: MainColors.BorderGray, width: 1),
                  ),
                  offset: const Offset(0, -15),
                ),
                value: conditions.selectedGrade,
                items:
                    _grades.map<DropdownMenuItem<String>>((String grade) {
                      return DropdownMenuItem<String>(
                        value: grade,
                        child: CommonText(text: grade),
                      );
                    }).toList(),

                menuItemStyleData: MenuItemStyleData(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ), // removes default padding
                  customHeights: List<double>.generate(
                    _grades.length,
                    (index) => 70, // 👈 custom height per item
                  ),
                ),
                onChanged: (String? grade) {
                  notifier.selectGrade(grade);
                },
              ),
            ),
          ],
        ),
      ),
      Expanded(
        flex: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(text: "문제 방식을 선택하세요", style: TextStyle(fontSize: 25)),
            EducationType(conditions, ref),
          ],
        ),
      ),
      Expanded(
        flex: 1,
        child: Align(
          alignment: Alignment.center,
          child: CommonButton(
            height: 54,
            buttonName: "다음",
            callback:
                conditions.isFillCondition1
                    ? // condition1이 정해지면
                    () async {
                      notifier.satisfiedCondition1();
                      // 만약 반복학습일 경우 바로 퀴즈로 넘어간다.
                      if (conditions.selectedEduType == EduType.RepeatEdu) {
                        // 사용자에게 노출된 모든 문제들을 가져온다.

                        // 노출된 문제들 중 선택된 학년의 문제들을 가져온다.
                        int grade = notifier.getGrade();

                        List<StudyWords> correctWords =
                            userInfo.eduState.correctWords;

                        // 선택된 학년에 해당하는 문제들을 riverpod provider에 삽입한다.
                        for (int i = 0; i < correctWords.length; i++) {
                          if (grade == correctWords[i].grade) {
                            conditions.selectedValues.add(correctWords[i].id);
                          }
                        }
                        List<StudyWords> incorrectWords =
                            userInfo.eduState.incorrectWords;

                        for (int i = 0; i < incorrectWords.length; i++) {
                          if (grade == incorrectWords[i].grade &&
                              conditions.selectedValues.contains(
                                    incorrectWords[i].id,
                                  ) ==
                                  false) {
                            conditions.selectedValues.add(incorrectWords[i].id);
                          }
                        }
                        // incorrectWords[i].id가 포함되어 있지 않을 경우,
                        // (correctWords와 중복된 id는 제거한다.)

                        if (conditions.selectedValues.length <= 0) {
                          notifier.truncateState();
                          Fluttertoast.showToast(
                            msg: "선택하신 학년의 단어를 푼 기록이 없습니다.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(),
                            fullscreenDialog: true,
                          ),
                        );
                      }
                    }
                    : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color:
                  conditions.isFillCondition1
                      ? MainColors.PrimaryColor
                      : MainColors.PrimaryColorDisable,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> ProblemCondition2(TodayWordCondition conditions, WidgetRef ref) {
    final notifier = ref.read(todayWordConditionProvider.notifier);

    return [
      Expanded(
        flex: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommonText(text: "과정을 선택하세요", style: TextStyle(fontSize: 25)),
            DropdownButtonHideUnderline(
              child: DropdownButton2(
                hint: Text("과정 선택하기"),
                buttonStyleData: ButtonStyleData(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: MainColors.BorderGray, width: 1),
                    borderRadius: BorderRadius.circular(20),
                    color: MainColors.LighterGray,
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    boxShadow: [],
                    borderRadius: BorderRadius.circular(20),
                    color: MainColors.LightGray,
                    border: Border.all(color: MainColors.BorderGray, width: 1),
                  ),
                  offset: const Offset(0, -15),
                ),
                value: conditions.selectedEduProcess,
                items:
                    _eduProcess.map<DropdownMenuItem<String>>((
                      String eduProcess,
                    ) {
                      return DropdownMenuItem<String>(
                        value: eduProcess,
                        child: CommonText(text: eduProcess),
                      );
                    }).toList(),

                menuItemStyleData: MenuItemStyleData(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ), // removes default padding
                  customHeights: List<double>.generate(
                    _eduProcess.length,
                    (index) => 70, // 👈 custom height per item
                  ),
                ),
                onChanged: (String? process) {
                  notifier.selectEduProcess(process);
                  notifier.truncateList();
                  // select 할 때마다 List를 Truncate한다.
                  SupabaseAPI client = SupabaseAPI.getInstance();
                  switch (process) {
                    case "기본 과정":
                      _basicChapters = client.GetBasicChapterByGrade(
                        notifier.getGrade(),
                      );
                      break;
                    case "워크북 과정":
                      _workbookChapters = client.GetWorkBookChapterByGrade(
                        notifier.getGrade(),
                      );
                      break;
                    case "단어 선택하기":
                      _selectableWord = client.GetWordsByGrade(
                        notifier.getGrade(),
                        0,
                        10,
                      );
                      break;
                  }
                },
              ),
            ),
          ],
        ),
      ),
      Expanded(
        flex: 8,
        child: Container(child: showProblemCondition3(conditions, ref)),
      ),
      Expanded(
        flex: 1,
        child: Align(
          alignment: Alignment.center,
          child: CommonButton(
            height: 54,
            buttonName: "다음",
            callback:
                conditions.isFillCondition2
                    ? () {
                      notifier.satisfiedCondition2();

                      switch (conditions.selectedEduProcess) {
                        case "기본 과정":
                        case "워크북 과정":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizScreen(),
                              fullscreenDialog: true,
                            ),
                          );
                          break;
                        case "단어 선택하기":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      QuizScreen(quizType: QuizType.WordSelect),
                              fullscreenDialog: true,
                            ),
                          );
                          break;
                      }
                    }
                    : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color:
                  conditions.isFillCondition2
                      ? MainColors.PrimaryColor
                      : MainColors.PrimaryColorDisable,
            ),
          ),
        ),
      ),
    ];
  }

  Widget? showProblemCondition3(TodayWordCondition conditions, WidgetRef ref) {
    final userInfo = ref.watch(userSessionTokenProvider);
    final notifier = ref.read(todayWordConditionProvider.notifier);
    // final conditions = ref.watch(todayWordConditionProvider);
    switch (conditions.selectedEduProcess) {
      case "기본 과정":
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10),
                  CommonText(text: "과를 선택하세요", style: TextStyle(fontSize: 25)),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: FutureBuilder(
                future: _basicChapters,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  else if (snapshot.hasData) {
                    // dynamic data 바인딩
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      notifier.setListValues(snapshot.data!.toList());
                    });

                    return ListView.separated(
                      separatorBuilder:
                          (context, index) => SizedBox(height: 20),
                      itemCount: conditions.listValues.length,
                      itemBuilder: (context, index) {
                        return ListItem(index: index, ref: ref);
                      },
                    );
                  }
                  return Center(child: Text("No Data"));
                },
              ),
            ),
          ],
        );
      case "워크북 과정":
        return Column(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10),
                  CommonText(text: "과를 선택하세요", style: TextStyle(fontSize: 25)),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: FutureBuilder(
                future: _workbookChapters,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  else if (snapshot.hasData) {
                    // dynamic data 바인딩
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      notifier.setListValues(snapshot.data!.toList());
                    });

                    return ListView.separated(
                      separatorBuilder:
                          (context, index) => SizedBox(height: 20),
                      itemCount: conditions.listValues.length,
                      itemBuilder: (context, index) {
                        return ListItem(index: index, ref: ref);
                      },
                    );
                  }
                  return Center(child: Text("No Data"));
                },
              ),
            ),
          ],
        );
      case "단어 선택하기":
        return FutureBuilder(
          future: _selectableWord,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              List<Word> wordList = snapshot.data!["wordList"];
              WidgetsBinding.instance.addPostFrameCallback((_) {
                notifier.setListValues(wordList);
              });

              return ListView.separated(
                controller: _controller,
                separatorBuilder: (context, index) => SizedBox(height: 20),
                itemCount: conditions.listValues.length,
                itemBuilder: (context, index) {
                  return ListItem(index: index, ref: ref);
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        );
    }

    return null;
  }

  Widget EducationType(TodayWordCondition conditions, WidgetRef ref) {
    final notifier = ref.read(todayWordConditionProvider.notifier);

    BoxDecoration SelectDeco = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: MainColors.PrimaryColor, width: 1),
      color: MainColors.PrimaryColorLight,
    );

    BoxDecoration noneSelectDeco = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: MainColors.BorderGray, width: 1),
      color: MainColors.LightGray,
    );

    TextStyle style = TextStyle(fontSize: 15);

    return SizedBox(
      child: Column(
        children: [
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              notifier.selectEduType(EduType.BasicEdu);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration:
                  conditions.selectedEduType == EduType.BasicEdu
                      ? SelectDeco
                      : noneSelectDeco,
              child: CommonText(text: "기본 학습", style: style),
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              notifier.selectEduType(EduType.RepeatEdu);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration:
                  conditions.selectedEduType == EduType.RepeatEdu
                      ? SelectDeco
                      : noneSelectDeco,

              child: CommonText(text: "반복 학습하기", style: style),
            ),
          ),
        ],
      ),
    );
  }
}
