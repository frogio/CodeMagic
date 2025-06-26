import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:english_word_app/api/supabase_api.dart';
import 'package:english_word_app/components/common/common_button.dart';
import 'package:english_word_app/components/common/common_text.dart';
import 'package:english_word_app/components/common/common_text_button.dart';
import 'package:english_word_app/components/dialog/common_dialog.dart';
import 'package:english_word_app/consts/colors.dart';
import 'package:english_word_app/consts/image_assets.dart';
import 'package:english_word_app/provider/session.dart';
import 'package:english_word_app/screens/common/disabled_screen.dart';
import 'package:english_word_app/screens/login_screen/change_pw_otp_screen.dart';
import 'package:english_word_app/screens/main_screen/qna_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../components/main_tab_controller.dart';
import '../../../consts/layout.dart';
import 'package:path/path.dart' as path;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isModifyMode = false;
  final List<String> _grades = ["1학년", "2학년", "3학년"];
  String? _selectedGrade = null;
  bool _isLoading = false;
  bool _isSocialLogin = false;

  void initState() {
    super.initState();
    _isModifyMode = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userInfo = ref.watch(userSessionTokenProvider);

      final patternKakao = RegExp(r'^kakao[가-힣]+$');
      final patternGoogle = RegExp(r'^google[가-힣]+$');
      final patternApple = RegExp(r'^apple[가-힣]+$');

      if (patternKakao.hasMatch(userInfo.userId) ||
          patternGoogle.hasMatch(userInfo.userId) ||
          patternApple.hasMatch(userInfo.userId)) {
        _isSocialLogin = true;
      }
    });
  }

  Widget roundedProfileImage(String url, {double radius = 55}) {
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

  Future<void> _changeProfileImage() async {
    final userInfo = ref.watch(userSessionTokenProvider);
    final userNotifier = ref.read(userSessionTokenProvider.notifier);
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;

    final File file = File(pickedImage.path);

    final extension = path.extension(file.path); // 파일 확장자 추출
    /*
    final fileName =
        "${userInfo.id}_${const Uuid().v4()}$extension"; // 스토리지에 저장될 이미지 이름
    final storagePath = "profile_img/$fileName"; // 이미지가 저장될 스토리지 경로
*/
    setState(() => _isLoading = true);

    SupabaseAPI client = SupabaseAPI.getInstance();
    String? storagePath = await client.changeProfileImage(
      file,
      userInfo.id,
      extension,
    );
    if (storagePath != null) userNotifier.changeUserProfileImage(storagePath);

    setState(() => _isLoading = false);
  }

  Widget profileTab(IconData icon, String name, VoidCallback callback) {
    return GestureDetector(
      onTap: callback,
      behavior: HitTestBehavior.translucent, // IMPORTANT!

      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: MainColors.MainGray),
            SizedBox(width: 10),
            CommonText(
              text: name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget showInfo(String tag, String info) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CommonText(
            text: tag,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          CommonText(
            text: info,
            style: TextStyle(fontSize: 16, color: MainColors.MainGray),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: MainColors.BorderGray, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    final userInfo = ref.watch(userSessionTokenProvider);
    final notifier = ref.watch(userSessionTokenProvider.notifier);

    SupabaseAPI client = SupabaseAPI.getInstance();
    String? url = client.getProfileImageURL(userInfo.profileImg);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        final controller = MainTabController.getInstance();
        controller.getTab(-1);
        // -1은 Home
      },
      child: SingleChildScrollView(
        child: DisabledScreen(
          disabled: _isLoading,
          child: Container(
            decoration: BoxDecoration(color: MainColors.LightGray),
            padding: ScreenLayout.COMMON_TAB_PADING,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _changeProfileImage,
                  child: roundedProfileImage(url!),
                ),
                CommonText(
                  text: userInfo.name,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: MainColors.MainWhite,
                    border: Border.all(color: MainColors.BorderGray),
                  ),
                  child: Column(
                    children: [
                      showInfo("아이디", userInfo.userId),
                      _isModifyMode
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  hint: Text("학년 선택하기"),
                                  buttonStyleData: ButtonStyleData(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: MainColors.BorderGray,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      color: MainColors.LighterGray,
                                    ),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    decoration: BoxDecoration(
                                      boxShadow: [],
                                      borderRadius: BorderRadius.circular(20),
                                      color: MainColors.LightGray,
                                      border: Border.all(
                                        color: MainColors.BorderGray,
                                        width: 1,
                                      ),
                                    ),
                                    offset: const Offset(0, -15),
                                  ),
                                  value: _selectedGrade,
                                  items:
                                      _grades.map<DropdownMenuItem<String>>((
                                        String grade,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: grade,
                                          child: CommonText(text: grade),
                                        );
                                      }).toList(),

                                  menuItemStyleData: MenuItemStyleData(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ), // removes default padding
                                    customHeights: List<double>.generate(
                                      _grades.length,
                                      (index) =>
                                          70, // 👈 custom height per item
                                    ),
                                  ),
                                  onChanged: (String? grade) {
                                    setState(() {
                                      _selectedGrade = grade;
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                          : showInfo("학년", "${userInfo.grade}학년"),
                      SizedBox(height: 20),
                      _isModifyMode && _isSocialLogin == false
                          ? CommonTextButton(
                            name: "비밀번호 변경",
                            callback: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangePWOtpScreen(),
                                  fullscreenDialog: true,
                                ),
                              );
                            },
                            style: TextStyle(
                              color: MainColors.MainGray,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                          : SizedBox(),
                      _isModifyMode ? SizedBox(height: 20) : SizedBox(),
                      CommonButton(
                        buttonName: _isModifyMode ? "저장하기" : "수정하기",
                        callback:
                            _isModifyMode
                                ? () async {
                                  if (_selectedGrade == null)
                                    return;
                                  else {
                                    SupabaseAPI client =
                                        SupabaseAPI.getInstance();

                                    setState(() {
                                      _isLoading = true;
                                    });

                                    await client.changeUserGrade(
                                      userInfo.id,
                                      _selectedGrade!,
                                      userInfo.accessJwt!,
                                    );

                                    switch (_selectedGrade) {
                                      case "1학년":
                                        notifier.changeUserGrade(1);
                                        break;
                                      case "2학년":
                                        notifier.changeUserGrade(2);
                                        break;
                                      case "3학년":
                                        notifier.changeUserGrade(3);
                                        break;
                                    }
                                    // notifier.truncateAccumulatedWords();
                                    setState(() {
                                      _isLoading = false;
                                      _isModifyMode = false;
                                    });
                                  }
                                }
                                : () {
                                  setState(() {
                                    _isModifyMode = true;
                                  });
                                },
                        style: TextStyle(
                          color: MainColors.PrimaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: MainColors.BorderGray,
                            width: 2,
                          ),
                          color: MainColors.LightGray,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: MainColors.MainWhite,
                    border: Border.all(color: MainColors.BorderGray),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      profileTab(Icons.exit_to_app, "로그아웃", () async {
                        ref.read(userSessionTokenProvider.notifier).clear();
                        final secureStorage = FlutterSecureStorage();
                        await secureStorage.write(
                          key: "refreshToken",
                          value: null,
                        );
                      }),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: MainColors.BorderGray,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      profileTab(Icons.message, "1:1 문의", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QnAScreen(),
                            fullscreenDialog: true,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                CommonTextButton(
                  name: "탈퇴하기",
                  callback: () async {
                    bool? isWithdraw = await CommonDialog.withdrwaDialog(
                      context,
                    );
                    if (isWithdraw == null || isWithdraw == false)
                      return;
                    else if (isWithdraw) {
                      SupabaseAPI client = SupabaseAPI.getInstance();
                      await client.withdrawAccount(
                        userInfo.id,
                        userInfo.accessJwt,
                      );
                      notifier.clear();
                    }
                  },
                  style: TextStyle(color: MainColors.MainGray, fontSize: 17),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
