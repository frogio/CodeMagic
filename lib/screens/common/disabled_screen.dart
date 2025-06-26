import 'package:flutter/material.dart';

class DisabledScreen extends StatelessWidget {
  final Widget child;
  final bool disabled;

  const DisabledScreen({required this.child, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(absorbing: disabled, child: child),
        if (disabled)
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              color: Colors.black.withOpacity(0.3),
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
