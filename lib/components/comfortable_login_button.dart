import 'package:english_word_app/consts/colors.dart';
import 'package:flutter/material.dart';

class LogInButton extends StatelessWidget {
  String icon;
  VoidCallback login;

  LogInButton({super.key, required this.icon, required this.login});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        decoration: BoxDecoration(color: MainColors.MainWhite),
        child: InkWell(onTap: login, child: Image.asset(icon, scale: 1.5)),
      ),
    );
  }
}
