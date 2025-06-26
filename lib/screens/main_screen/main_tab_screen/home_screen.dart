import 'package:cached_network_image/cached_network_image.dart';
import 'package:english_word_app/components/home_screen/learning_state.dart';
import 'package:english_word_app/components/home_screen/remind_correctness.dart';
import 'package:english_word_app/components/main_tab_controller.dart';
import 'package:english_word_app/consts/colors.dart';
import 'package:english_word_app/consts/enums.dart';
import 'package:english_word_app/models/study_words.dart';
import 'package:english_word_app/models/word_count.dart';
import 'package:english_word_app/provider/session.dart';
import 'package:english_word_app/provider/today_word_condition.dart';
import 'package:english_word_app/screens/main_screen/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../consts/image_assets.dart';
import '../../../components/common/common_text.dart';
import '../../../consts/layout.dart';
import '../../../components/home_screen/attendance.dart';
import '../../../components/home_screen/today_edu_button.dart';
import '../../../api/supabase_api.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<int> getNewWords(UserInfo userInfo) async {
    // 사용자에게 노출되지 않은 단어 갯수를 리턴한다.

    SupabaseAPI client = SupabaseAPI.getInstance();
    List<WordCount> tmp = userInfo.eduState.mergedList;
    int contactWord = 0;
    for (int i = 0; i < tmp.length; i++) {
      if (tmp[i].grade == userInfo.grade) {
        contactWord++;
      }
    }
    int wordCountByGrade =
        await client.GetWordCountByGrade(userInfo.grade) - contactWord;

    if (wordCountByGrade < 0) wordCountByGrade = 0;

    return wordCountByGrade;
  }

  Widget roundedProfileImage(String url, {double radius = 40}) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget:
            (context, url, error) =>
                Image.asset(ImageAssets.USER_DEFAULT_IMG, scale: 1.0),
      ),
    );
  }

  Widget showUserState(UserInfo userInfo, WidgetRef ref) {
    SupabaseAPI client = SupabaseAPI.getInstance();
    final userInfo = ref.watch(userSessionTokenProvider);
    String? url = client.getProfileImageURL(userInfo.profileImg);

    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: MainColors.LighterGray,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          roundedProfileImage(url!),
          // : CircleAvatar(
          //   radius: 50,
          //   child: CachedNetworkImage(
          //     imageUrl: url,
          //     placeholder: (context, url) => CircularProgressIndicator(),
          //     errorWidget:
          //         (context, url, error) =>
          //             Image.asset(ImageAssets.USER_DEFAULT_IMG, scale: 1.4),
          //   ),
          // ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: CommonText(
                  text: "${userInfo.name}님 환영합니다!",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 15,
                      ),
                      decoration: BoxDecoration(
                        color: MainColors.MainWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          width: 2.0,
                          color: MainColors.PrimaryColorShade,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            text: "복습 단어",
                            style: TextStyle(color: MainColors.MainGray),
                          ),
                          Row(
                            children: [
                              Image.asset(ImageAssets.WORDS, scale: 1.5),
                              CommonText(
                                text: "${userInfo.eduState.reminedWords}개",
                                style: TextStyle(
                                  color: MainColors.PrimaryColorShade,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 15,
                      ),
                      decoration: BoxDecoration(
                        color: MainColors.PrimaryColorLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            text: "새로운단어",
                            style: TextStyle(color: MainColors.MainGray),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(ImageAssets.NEW_WORDS, scale: 1.5),
                              FutureBuilder(
                                future: getNewWords(userInfo),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return CommonText(
                                      text: "${snapshot.data}개",
                                      style: TextStyle(
                                        color: MainColors.PrimaryColorShade,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  }
                                  return CommonText(
                                    text: "0개",
                                    style: TextStyle(
                                      color: MainColors.PrimaryColorShade,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  MainTabController tabController = MainTabController.getInstance();

  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(userSessionTokenProvider);
    final conditions = ref.read(todayWordConditionProvider.notifier);

    return Container(
      padding: ScreenLayout.COMMON_TAB_PADING,
      decoration: BoxDecoration(color: MainColors.MainWhite),
      child: Column(
        children: [
          Expanded(
            flex: 10,
            child: Column(
              children: [
                Expanded(flex: 7, child: showUserState(userInfo, ref)),
                Expanded(flex: 1, child: SizedBox()),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Image.asset(ImageAssets.EDUSTATE_MARK),
                SizedBox(width: 10),
                CommonText(
                  text: "학습 현황",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 10,
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: LearningState(eduState: userInfo.eduState),
                ),
                SizedBox(width: 5),
                Expanded(
                  flex: 3,
                  child: RemindCorrectness(
                    eduState: userInfo.eduState,
                    userGrade: userInfo.grade,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 8,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: TodayWordButton(
                callback: () {
                  // 누적된 단어가 없으면, 오늘의 단어로 이동
                  // 0는 오늘의 단어 스크린으로 이동
                  if (userInfo.eduState.accmulatedWords.length <= 0)
                    tabController.getTab(0);
                  // 그렇지 않을 경우 N일 누적단어 문제 퀴즈로 이동
                  else {
                    conditions.selectEduType(EduType.Accumulated);

                    int userGrade = userInfo.grade;
                    List<StudyWords> words = userInfo.eduState.accmulatedWords;
                    List<int> selectedWordId = [];
                    for (int i = 0; i < words.length; i++) {
                      if (userGrade == words[i].grade) {
                        selectedWordId.add(words[i].id);
                      }
                    }

                    if (selectedWordId.length == 0) {
                      tabController.getTab(0);
                      return;
                    }

                    conditions.setSelectedValues(selectedWordId);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(),
                        fullscreenDialog: true,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 11,
            child: Attendance(attendance: userInfo.eduState.attendance),
          ),
        ],
      ),
    );
  }
}
