import 'package:english_word_app/consts/colors.dart';
import 'package:english_word_app/consts/image_assets.dart';

import '../common/common_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Attendance extends StatelessWidget {
  final Map<String, dynamic> attendance;
  late List<int> attendanceList;
  final List<String> day = ["일", "월", "화", "수", "목", "금", "토"];

  Attendance({super.key, required this.attendance}) {
    final now = DateTime.now();
    final dateOnly = DateTime(now.year, now.month, now.day);
    final weekday = now.weekday % 7;
    // dart의 DateTime은 Monday부터 1로 시작하여 Sunday로 7에 끝난다.
    final lastSunday = dateOnly.subtract(Duration(days: weekday));

    final formatter = DateFormat('yyyyMMdd');
    final String formatted = formatter.format(lastSunday);
    final List<dynamic> list = attendance[formatted];
    attendanceList = List<int>.empty(growable: true);
    for (int i = 0; i < list.length; i++) {
      if (list[i].toString() == "1")
        attendanceList.add(1);
      else
        attendanceList.add(0);
    }

    /*
    // 앞에 있는 일요일을 빼서 뒤에 삽입한다.
    // 서버에 저장된 출석 표기 순서 => 일, 월, 화, ..., 토
    // 클라이언트 순서 표기 => 월, 화, 수 ..., 토, 일
    // 이기 때문에 변환 필요
    int sunday = attendanceList[0];
    attendanceList.remove(0);
    attendanceList.add(sunday);*/
  }

  Widget attendMarking(int i) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonText(
            text: day[i],
            style: TextStyle(
              color: Color(0xFFA3A4AF),
              fontSize: 12,
              fontFamily: 'Pretendard',
            ),
          ),
          Icon(Icons.check_circle, size: 40, color: MainColors.PrimaryColor),
        ],
      ),
    );
  }

  Widget absenceMarking(int i) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonText(
            text: day[i],
            style: TextStyle(
              color: Color(0xFFA3A4AF),
              fontSize: 12,
              fontFamily: 'Pretendard',
            ),
          ),
          Icon(Icons.check_circle, size: 40, color: MainColors.MainGray),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Image.asset(ImageAssets.ATTENDANCE_MARK),
              SizedBox(width: 10),
              CommonText(
                text: "출석 현황",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 10,
              left: 20,
              right: 20,
              bottom: 8,
            ),
            decoration: ShapeDecoration(
              color: MainColors.LighterGray,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              children: [
                for (int i = 0; i < 7; i++)
                  attendanceList[i] == 1 ? attendMarking(i) : absenceMarking(i),
              ],
            ),
          ),
        ),
        Expanded(flex: 1, child: SizedBox()),
      ],
    );
  }
}
