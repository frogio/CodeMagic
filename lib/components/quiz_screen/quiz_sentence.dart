import 'package:english_word_app/components/common/common_text.dart';
import 'package:english_word_app/consts/colors.dart';
import 'package:english_word_app/provider/quiz_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/quiz.dart';

class QuizSentence extends ConsumerStatefulWidget {
  Quiz? quiz;

  QuizSentence({super.key, required this.quiz});

  @override
  ConsumerState<QuizSentence> createState() => _QuizSentenceState();
}

class _QuizSentenceState extends ConsumerState<QuizSentence> {
  String blankText = "";
  List<String> splitTexts = List<String>.empty(growable: true);

  @override
  void initState() {
    super.initState();
  }

  Widget makeBlankSentence() {
    // 단어가 숙어가 아닐 경우
    if (widget.quiz!.sentence.contains('[') == false)
      // 대 소문자 구별을 하지 않고 무조건 변환한다.
      blankText = widget.quiz!.sentence.replaceAll(
        RegExp(widget.quiz!.word, caseSensitive: false),
        "_",
      );
    // 숙어일 경우 스퀘어 브라켓으로 감싼 단어 []를 _로 변경한다.
    else {
      RegExp regExp = RegExp(r'\[(.*?)\]');
      blankText = widget.quiz!.sentence.replaceAll(regExp, "_");
    }
    splitTexts = blankText.split("_");

    List<Widget> widgets = [];

    if (splitTexts.length <= 0) return SizedBox();
    // 첫 실행은 PostFrameCallback이 실행되어있지 않으므로, 임시적으로 SizedBox 리턴

    for (int i = 0; i < splitTexts.length; i++) {
      widgets.add(
        CommonText(text: splitTexts[i], style: TextStyle(fontSize: 18)),
      );
      widgets.add(
        Container(
          width: 70,
          height: 50,
          decoration: BoxDecoration(
            color: MainColors.LightGray,
            border: Border.all(color: MainColors.BorderGray),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    widgets.removeLast(); // 마지막 블랭크를 지운다.

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8.0, // horizontal spacing
      runSpacing: 2.0, // vertical spacing between lines
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: makeBlankSentence(),
    );
  }
}
