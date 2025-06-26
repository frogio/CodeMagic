import 'package:english_word_app/consts/colors.dart';
import 'package:english_word_app/consts/image_assets.dart';
import 'package:flutter/material.dart';

class TodayWordButton extends StatelessWidget {
  final VoidCallback callback;

  TodayWordButton({required this.callback});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(7),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: Ink(
          decoration: BoxDecoration(
            color: MainColors.PrimaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: callback,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(ImageAssets.TODAY_WORD_INVERT),
                  Row(
                    children: [
                      Text(
                        "오늘의 학습 바로가기",
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: MainColors.MainWhite,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
