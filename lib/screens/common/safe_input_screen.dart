import 'package:flutter/material.dart';

class SafeInputScreen extends StatelessWidget {
  Widget child;
  SafeInputScreen({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
}
