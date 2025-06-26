import 'package:english_word_app/components/dialog/common_dialog.dart';
import 'package:english_word_app/consts/colors.dart';
import 'package:english_word_app/provider/session.dart';
import 'package:flutter/material.dart';
import '../../../consts/layout.dart';
import '../../consts/image_assets.dart';
import '../../components/main_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/common/common_button.dart';
import '../../components/common/common_text.dart';
import '../../components/main_tab_controller.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool isNeedChangeAppBarColor = false;

  Widget attendanceDialog(WidgetRef ref) {
    List<Widget> contents = [
      Image.asset(ImageAssets.CONFIRM_MARK),
      CommonText(
        text: "출석 완료!",
        style: TextStyle(
          color: MainColors.PrimaryColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      SizedBox(height: 30),
      CommonButton(
        buttonName: "확인",
        callback: () {
          ref.read(userSessionTokenProvider.notifier).checkAttendance();
          // Navigator.pop(context);
        },
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: MainColors.PrimaryColor,
        ),
      ),
    ];

    return CommonDialog.makeCommonDialog(contents, 300, 250);
  }

  MainTabController tabController = MainTabController.getInstance();

  void changeAppBarState() {
    if (tabController.getCurrentTab() == 2) {
      setState(() {
        isNeedChangeAppBarColor = true;
      });
    } else {
      setState(() {
        isNeedChangeAppBarColor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfoNotifier = ref.read(userSessionTokenProvider.notifier);

    return Scaffold(
      appBar:
          userInfoNotifier.isCheckAttendance()
              ? null
              : PreferredSize(
                preferredSize: Size.fromHeight(52),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenLayout.APPBAR_PADDING,
                  ),
                  alignment: Alignment.bottomLeft,
                  height: double.infinity,
                  color:
                      isNeedChangeAppBarColor
                          ? MainColors.LightGray
                          : MainColors.MainWhite,
                  child: GestureDetector(
                    onTap: () {
                      tabController.getTab(-1);
                      changeAppBarState();
                      // -1은 홈 화면으로 이동
                    },
                    child: Image.asset(
                      ImageAssets.MAIN_LEADING_ICON,
                      scale: 7.0,
                    ),
                  ),
                ),
              ),

      body:
          userInfoNotifier.isCheckAttendance()
              ? attendanceDialog(ref)
              : MainTab(
                key: tabController.getKey(),
                callback: changeAppBarState,
              ),
    );
  }
}
