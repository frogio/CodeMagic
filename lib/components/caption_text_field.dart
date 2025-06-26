import 'package:flutter/material.dart';
import './common/text_field.dart';
import './common/common_text.dart';

class CaptionTextField extends StatefulWidget {
  final String caption;
  final String hintText;
  bool obsecureMode;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  bool enabled;

  CaptionTextField({
    super.key,
    required this.caption,
    required this.hintText,
    this.controller,
    this.obsecureMode = false,
    this.enabled = true,
    this.keyboardType,
  });

  @override
  State<CaptionTextField> createState() => _CaptionTextFieldState();
}

class _CaptionTextFieldState extends State<CaptionTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CommonText(
            text: widget.caption,
            style: TextStyle(
              color: const Color(0xFF1C1D1F) /* black */,
              fontSize: 14,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 10),
        Textfield(
          controller: widget.controller,
          obsecureMode: widget.obsecureMode,
          hintText: widget.hintText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
        ),
      ],
    );
  }
}
