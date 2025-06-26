import 'package:flutter/material.dart';
import './common_text.dart';

class CommonTextButton extends StatefulWidget {
  final VoidCallback callback;
  final String name;
  TextStyle? style;

  CommonTextButton({
    super.key,
    required this.name,
    this.style,
    required this.callback,
  });

  @override
  State<CommonTextButton> createState() => _CommonTextButtonState();
}

class _CommonTextButtonState extends State<CommonTextButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.callback,
      child: CommonText(
          text: widget.name,
          textAlign: TextAlign.center,
          style: widget.style ??
              TextStyle(
                color: const Color(0xFF666874) /* grey6 */,
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                height: 1.38,
                letterSpacing: -0.48,
              )),
    );
  }
}
