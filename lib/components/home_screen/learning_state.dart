import 'package:english_word_app/components/home_screen/learning_time.dart';
import 'package:english_word_app/consts/colors.dart';

import '../../components/common/common_text.dart';
import '../../models/student_edu_state.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class LearningState extends StatelessWidget {
  StudentEduState eduState;

  LearningState({super.key, required this.eduState}) {}

  num getMaxY() {
    int maxValue = max(
      eduState.alreadyKnownWords,
      max(eduState.newLearnedWords, eduState.reminedWords),
    );

    num digit = 0;
    int tmp = maxValue;
    while (tmp > 0) {
      tmp ~/= 10;
      digit++;
    }
    // 데이터의 최대값과 근접한 10의 승수를 구한다.
    // 예 : 최댓값 221
    // 결과값 100

    num unit = pow(10, digit - 1);
    int multiple = 2;
    int result = 0;
    while (maxValue > result) {
      result = unit.toInt() * multiple++;
    }
    // 만약 구한 승수값보다 데이터의 최댓값디 더 크다면
    // 221 > 100 이면
    // 221 > 200 이므로 multiple++,
    // 221 > 300, 따라서 최종 단위는 300

    return result;
  }

  @override
  Widget build(BuildContext context) {
    num maxY = getMaxY();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: constraints.maxHeight,
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LearningTime(),
                        Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 3,
                                  width: 7,
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                SizedBox(width: 3),
                                CommonText(
                                  text:
                                      "새로 배운 단어 : ${eduState.newLearnedWords}",
                                  style: TextStyle(
                                    color: Color(0xFF666874),
                                    fontSize: 10,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  height: 3,
                                  width: 7,
                                  decoration: BoxDecoration(
                                    color: Colors.purpleAccent.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                SizedBox(width: 3),
                                CommonText(
                                  text:
                                      "이미 아는 단어 : ${eduState.alreadyKnownWords}",
                                  style: TextStyle(
                                    color: Color(0xFF666874),
                                    fontSize: 10,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  height: 3,
                                  width: 7,
                                  decoration: BoxDecoration(
                                    color: Colors.lightGreen.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                SizedBox(width: 3),
                                CommonText(
                                  text: "복습 단어 : ${eduState.reminedWords}",
                                  style: TextStyle(
                                    color: Color(0xFF666874),
                                    fontSize: 10,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    height: constraints.maxHeight,
                    child: BarChart(
                      BarChartData(
                        // BarChart Style 설정
                        gridData: FlGridData(
                          horizontalInterval: maxY / 10 == 0 ? 10 : maxY / 10,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color:
                                  MainColors
                                      .BorderGray, // Set your desired color
                              strokeWidth: 1, // Thickness of the line
                              // Optional: dashed line [dash, gap]
                            );
                          },
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(
                              color: MainColors.MainBlack,
                              width: 1,
                            ),
                          ),
                        ),
                        alignment: BarChartAlignment.end,
                        maxY: maxY.toDouble(),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: eduState.reminedWords.toDouble(),
                                color: Colors.lightGreen.shade200,
                                width: 16,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(50),
                                  topRight: Radius.circular(50),
                                  bottomLeft:
                                      Radius.zero, // Customize bottom-left cap
                                  bottomRight: Radius.zero,
                                ),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: eduState.alreadyKnownWords.toDouble(),
                                color: Colors.purpleAccent.shade100,
                                width: 16,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(50),
                                  topRight: Radius.circular(50),
                                  bottomLeft:
                                      Radius.zero, // Customize bottom-left cap
                                  bottomRight: Radius.zero,
                                ),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: eduState.newLearnedWords.toDouble(),
                                color: Colors.amber.shade300,
                                width: 16,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(50),
                                  topRight: Radius.circular(50),
                                  bottomLeft:
                                      Radius.zero, // Customize bottom-left cap
                                  bottomRight: Radius.zero,
                                ),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 3,
                            barRods: [
                              BarChartRodData(
                                toY: 0,
                                color: Colors.orange,
                                width: 2,
                              ),
                            ],
                          ),
                        ],
                        titlesData: FlTitlesData(
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ), // Hide Y-axis numbers
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ), // Hide X-axis numbers
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
