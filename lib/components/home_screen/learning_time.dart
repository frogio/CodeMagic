import 'package:english_word_app/components/common/common_text.dart';
import 'package:english_word_app/consts/colors.dart';
import 'package:english_word_app/consts/image_assets.dart';
import 'package:english_word_app/provider/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

class LearningTime extends ConsumerStatefulWidget {
  LearningTime({super.key});

  @override
  ConsumerState<LearningTime> createState() => _LearningTimeState();
}

class _LearningTimeState extends ConsumerState<LearningTime> {
  late int _hours;
  late int _minutes;
  late int _seconds;
  String _formattedTime = "";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userInfo = ref.watch(userSessionTokenProvider);
      int learningTime = userInfo.eduState.learningTime;
      _hours = (learningTime) ~/ 3600;
      _minutes = (learningTime % 3600) ~/ 60;
      _seconds = (learningTime % 3600) % 60;

      _formattedTime = "$_hours시간 $_minutes분 $_seconds초";
    });
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(userSessionTokenProvider);
    int learningTime = userInfo.eduState.learningTime;

    _hours = (learningTime) ~/ 3600;
    _minutes = (learningTime % 3600) ~/ 60;
    _seconds = (learningTime % 3600) % 60;
    _formattedTime = "$_hours시간 $_minutes분 $_seconds초";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        Container(
          width: 100,
          height: 30,
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
              Image.asset(ImageAssets.LEARNING_TIME_MARK),
              SizedBox(width: 5),
              CommonText(
                text: _formattedTime,
                style: TextStyle(
                  fontSize: 8,
                  color: MainColors.PrimaryColorShade,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
