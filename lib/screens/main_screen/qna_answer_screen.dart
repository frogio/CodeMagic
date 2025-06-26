import 'package:english_word_app/components/common/common_text.dart';
import 'package:english_word_app/consts/colors.dart';
import 'package:english_word_app/consts/layout.dart';
import 'package:english_word_app/models/qna.dart';
import 'package:flutter/material.dart';

class QnaAnswerScreen extends StatefulWidget {
  final QnA qna;

  QnaAnswerScreen({super.key, required this.qna});

  @override
  State<QnaAnswerScreen> createState() => _QnaAnswerScreenState();
}

class _QnaAnswerScreenState extends State<QnaAnswerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainColors.MainWhite,
      appBar: AppBar(
        elevation: 0, // 👈 Prevent shadow on scroll
        surfaceTintColor:
            Colors.transparent, // 👈 For Material 3 — prevents dynamic tinting
        backgroundColor: MainColors.MainWhite,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.only(left: 30),
            child: Icon(
              Icons.arrow_back_ios_sharp,
              color: MainColors.MainBlack,
            ),
          ),
        ),
        title: CommonText(
          text: "1:1 문의하기",
          style: TextStyle(
            color: MainColors.MainBlack,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Container(
        padding: ScreenLayout.COMMON_TAB_PADING,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: MainColors.LightGray,
                  border: Border.all(width: 1.0, color: MainColors.BorderGray),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CommonText(
                        text: "${widget.qna.date}에 문의함",
                        style: TextStyle(color: MainColors.MainGray),
                      ),
                      CommonText(text: widget.qna.question),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(flex: 1, child: SizedBox()),
            Expanded(
              flex: 4,
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: MainColors.LightGray,
                  border: Border.all(width: 1.0, color: MainColors.BorderGray),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      widget.qna.answer == ""
                          ? CommonText(
                            text: "아직 답변이 존재하지 않습니다.",
                            style: TextStyle(color: MainColors.MainGray),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CommonText(
                                text: "답변 내용",
                                style: TextStyle(color: MainColors.MainGray),
                              ),
                              CommonText(
                                text: "${widget.qna.answer}",
                                style: TextStyle(color: MainColors.MainBlack),
                              ),
                            ],
                          ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(flex: 2, child: SizedBox()),
          ],
        ),
      ),
    );
  }
}
