import 'package:flutter/material.dart';

class CommonButton extends StatefulWidget {
  final String buttonName;
  final VoidCallback? callback;
  final BoxDecoration? decoration;
  final Icon? icon;
  final double width;
  final double height;
  final TextStyle? style;

  const CommonButton({
    super.key,
    required this.buttonName,
    required this.callback,
    this.width = double.infinity,
    this.height = 60,
    this.icon,
    this.decoration,
    this.style,
  });

  @override
  State<CommonButton> createState() => _CommonButtonState();
}

class _CommonButtonState extends State<CommonButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: widget.decoration?.borderRadius ?? BorderRadius.circular(7),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Ink(
          decoration:
              widget.decoration ??
              BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: widget.callback,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.icon ?? Container(),
                  SizedBox(width: 10),
                  Text(
                    widget.buttonName,
                    style:
                        widget.style ??
                        TextStyle(color: Colors.white, fontSize: 17),
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
