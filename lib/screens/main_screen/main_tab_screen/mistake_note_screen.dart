import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:english_word_app/api/supabase_api.dart';
import 'package:english_word_app/components/common/common_button.dart';
import 'package:english_word_app/components/common/list_item.dart';
import 'package:english_word_app/components/mistake_note/mistake_note_item.dart';
import 'package:english_word_app/consts/colors.dart';
import 'package:english_word_app/consts/enums.dart';
import 'package:english_word_app/provider/mistake_note_provider.dart';
import 'package:english_word_app/provider/session.dart';
import 'package:english_word_app/screens/main_screen/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../consts/layout.dart';
import '../../../components/common/common_text.dart';

class MistakeNoteScreen extends ConsumerStatefulWidget {
  const MistakeNoteScreen({super.key});

  @override
  ConsumerState<MistakeNoteScreen> createState() => _MistakeNoteScreenState();
}

class _MistakeNoteScreenState extends ConsumerState<MistakeNoteScreen> {
  final List<String> _wordSelect = ["틀린 단어 하기", "많이 틀린 단어 하기"];
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mistakeNoteProvNoti = ref.read(mistakeNoteProvider.notifier);
      mistakeNoteProvNoti.truncate();
    });
  }

  void _onScroll() {
    final mistakeNoteProv = ref.watch(mistakeNoteProvider);
    final notifier = ref.read(mistakeNoteProvider.notifier);
    if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 10 &&
        mistakeNoteProv.isLoadComplete) {
      notifier.appendWords();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(userSessionTokenProvider);
    final mistakeNoteProv = ref.watch(mistakeNoteProvider);
    final mistakeNoteProvNoti = ref.read(mistakeNoteProvider.notifier);
    return Container(
      padding: ScreenLayout.COMMON_TAB_PADING,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CommonText(text: "단어를 선택하세요", style: TextStyle(fontSize: 25)),
                DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    hint: Text("단어 선택하기"),
                    buttonStyleData: ButtonStyleData(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: MainColors.BorderGray,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        color: MainColors.LighterGray,
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        boxShadow: [],
                        borderRadius: BorderRadius.circular(20),
                        color: MainColors.LightGray,
                        border: Border.all(
                          color: MainColors.BorderGray,
                          width: 1,
                        ),
                      ),
                      offset: const Offset(0, -15),
                    ),
                    value: mistakeNoteProv.selectedOption,
                    items:
                        _wordSelect.map<DropdownMenuItem<String>>((
                          String wordProcess,
                        ) {
                          return DropdownMenuItem<String>(
                            value: wordProcess,
                            child: CommonText(text: wordProcess),
                          );
                        }).toList(),

                    menuItemStyleData: MenuItemStyleData(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ), // removes default padding
                      customHeights: List<double>.generate(
                        _wordSelect.length,
                        (index) => 70, // 👈 custom height per item
                      ),
                    ),
                    onChanged: (String? process) async {
                      SupabaseAPI client = SupabaseAPI.getInstance();
                      mistakeNoteProvNoti.selectOption(process);
                      List<int> ids = [];

                      switch (process) {
                        case "틀린 단어 하기":
                          for (var ww in userInfo.eduState.incorrectWords) {
                            if (userInfo.grade == ww.grade) ids.add(ww.id);
                          }
                          break;
                        case "많이 틀린 단어 하기":
                          for (var ww in userInfo.eduState.incorrectWords) {
                            if (ww.count >= 2 && userInfo.grade == ww.grade)
                              ids.add(ww.id);
                          }
                          break;
                      }
                      mistakeNoteProvNoti.truncateList();
                      mistakeNoteProvNoti.init(ids);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 8,
            child:
                mistakeNoteProv.isLoadComplete
                    ? ListView.separated(
                      controller: _controller,
                      separatorBuilder:
                          (context, index) => SizedBox(height: 20),
                      itemCount: mistakeNoteProv.wordList.length,
                      itemBuilder: (context, index) {
                        return MistakeNoteItem(index: index, ref: ref);
                        // ref을 통하여 리스트 상태 데이터에 접근
                      },
                    )
                    : Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: CommonButton(
                    height: 54,
                    buttonName: "다음",
                    callback:
                        mistakeNoteProv.satisfiedCondition
                            ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => QuizScreen(
                                        quizType: QuizType.MistakeNote,
                                      ),
                                  fullscreenDialog: true,
                                ),
                              );
                            }
                            : null,
                    decoration: BoxDecoration(
                      color:
                          mistakeNoteProv.satisfiedCondition
                              ? MainColors.PrimaryColor
                              : MainColors.PrimaryColorDisable,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
