import 'package:english_word_app/consts/colors.dart';
import '../../models/student_edu_state.dart';
import '../../components/common/common_text.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class RemindCorrectness extends StatelessWidget {
  int userGrade;
  StudentEduState eduState;

  RemindCorrectness({
    super.key,
    required this.eduState,
    required this.userGrade,
  });

  double getRemindCorrrectness() {
    // 2 2  : 50 %
    // 1 1  : 0 %
    // 2 1  : 100%
    // 1 2  : 0 %

    int correct = 0;
    for (int i = 0; i < eduState.mergedList.length; i++) {
      if (eduState.mergedList[i].correct >= 1 &&
          eduState.mergedList[i].grade == userGrade) {
        correct += eduState.mergedList[i].correct;
      }
    }
    int incorrect = 0;
    for (int i = 0; i < eduState.mergedList.length; i++) {
      if (eduState.mergedList[i].incorrect >= 1 &&
          eduState.mergedList[i].grade == userGrade) {
        incorrect += eduState.mergedList[i].incorrect;
      }
    }
    if (incorrect + correct == 0) return 0;
    return correct / (incorrect + correct) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            width: 80,
            height: 20,
            padding: const EdgeInsets.all(10),
            decoration: ShapeDecoration(
              color: MainColors.PrimaryColorLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '복습 정답률',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF41B841),
                    fontSize: 10,
                    fontFamily: 'Pretendard',
                    height: 0.16,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          flex: 12,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth;
              double height = constraints.maxHeight;
              return Container(
                child: Stack(
                  children: [
                    Positioned(
                      left: width * 0.37,
                      top: height * 0.4,
                      child: CommonText(
                        text: "${getRemindCorrrectness().toInt().toString()}%",
                        style: TextStyle(
                          color: MainColors.PrimaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    OverflowBox(
                      maxHeight: double.infinity,
                      maxWidth: double.infinity,
                      child: CustomPaint(
                        size: Size(100, 100),
                        painter: CircleChartPainter(
                          values: getRemindCorrrectness(),
                          strokeWidth: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CircleChartPainter extends CustomPainter {
  final double values; // Data values (percentages)
  final double strokeWidth; // Thickness of the arcs

  CircleChartPainter({required this.values, this.strokeWidth = 100});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;

    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    double startAngle = 0;
    // 왼쪽 지점 부터 시작하여 시계방향으로 돌아감.

    paint.color = Colors.grey.shade200;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * pi,
      // startAngle 부터 sweepAngle까지의 원호를 그린다.
      false, // Use stroke style
      paint,
    );

    paint.color = MainColors.PrimaryColor;
    paint.strokeWidth += 1;

    double radian = -2 * pi * (values / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      radian,
      // startAngle 부터 sweepAngle까지의 원호를 그린다.
      false, // Use stroke style
      paint,
    );
  }

  @override
  bool shouldRepaint(CircleChartPainter oldDelegate) => true;
}
