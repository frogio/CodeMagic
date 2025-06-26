import 'package:flutter/material.dart';

class CommonText extends StatelessWidget {
  String text;
  TextStyle? style;
  TextAlign? textAlign;

  CommonText({required this.text, super.key, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: style,
    );
  }
}
