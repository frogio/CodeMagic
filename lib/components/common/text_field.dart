import 'package:flutter/material.dart';

class Textfield extends StatefulWidget {
  final String hintText;
  bool obsecureMode;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  bool enabled;
  // bool? readOnly;
  // VoidCallback? onTap;

  Textfield({
    this.hintText = "",
    this.obsecureMode = false,
    this.controller,
    this.keyboardType,
    this.enabled = true,
    // this.readOnly = false,
    // this.onTap,
    super.key,
  });

  @override
  State<Textfield> createState() => _TextfieldState();
}

class _TextfieldState extends State<Textfield> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      // readOnly: widget.readOnly ?? false,
      // onTap: widget.onTap,
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
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), // 👈 Rounded edges
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
      fillColor: Colors.grey.shade200,
      filled: true,
    );
  }
}
