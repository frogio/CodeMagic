import 'package:flutter/material.dart';
import '../../consts/colors.dart';

class AnswerField extends StatefulWidget {
  final String hintText;
  bool obsecureMode;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  bool enabled;
  AnswerField({
    this.hintText = "",
    this.obsecureMode = false,
    this.controller,
    this.keyboardType,
    this.enabled = true,
    super.key,
  });

  @override
  State<AnswerField> createState() => _TextfieldState();
}

class _TextfieldState extends State<AnswerField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obsecureMode,
      decoration: _makeInputDecoration(widget.hintText, context),
      keyboardType: widget.keyboardType,
      enabled: widget.enabled,
    );
  }

  InputDecoration _makeInputDecoration(String hintText, BuildContext context) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: MainColors.MainGray),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), // 👈 Rounded edges
        borderSide: BorderSide(color: MainColors.PrimaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: MainColors.PrimaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: MainColors.PrimaryColorShade, width: 2),
      ),
      fillColor: Colors.grey.shade200,
      filled: true,
    );
  }
}
