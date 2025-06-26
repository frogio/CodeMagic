import 'package:flutter/material.dart';
import '../../consts/colors.dart';

class FatButton extends StatelessWidget {
  final VoidCallback? callback;
  final String buttonName;
  final double width;
  TextStyle? style;
  BoxDecoration? decoration;
  final Color? color;

  FatButton({
    super.key,
    this.callback,
    required this.buttonName,
    this.width = 100,
    this.style,
    this.decoration,
    this.color,
  });

  @override
  Widget build(BuildContext) {
    return Material(
      borderRadius: decoration?.borderRadius ?? BorderRadius.circular(7),
      child: SizedBox(
        width: width,
        child: Ink(
          decoration:
              decoration ??
              BoxDecoration(
                color: color ?? MainColors.MainGray,
                borderRadius: BorderRadius.circular(10),
              ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: callback,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttonName,
                    style:
                        style ?? TextStyle(color: Colors.white, fontSize: 15),
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
