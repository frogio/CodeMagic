import 'package:english_word_app/consts/colors.dart';
import 'package:english_word_app/consts/enums.dart';
import 'package:english_word_app/provider/session.dart';
import 'package:english_word_app/screens/common/disabled_screen.dart';
import 'package:english_word_app/screens/common/safe_input_screen.dart';
import 'package:english_word_app/screens/login_screen/find_id_screen.dart';
import 'package:english_word_app/screens/login_screen/append_extra_info_screen.dart';
import 'package:english_word_app/screens/login_screen/find_pw_screen.dart';
import 'package:english_word_app/screens/login_screen/signup_auth_screen.dart';
import 'package:english_word_app/screens/login_screen/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/caption_text_field.dart';
import '../../components/common/common_button.dart';
import '../../components/common/common_text_button.dart';
import '../../components/common/common_text.dart';
import '../../components/comfortable_login_button.dart';
import '../../consts/image_assets.dart';
import '../../api/supabase_api.dart';
import '../../components/dialog/common_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  TextEditingController _id = TextEditingController();
  TextEditingController _pw = TextEditingController();
  String _idText = "", _pwText = "";
  bool _isLoginable = false;
  bool _isLogining = false;
  bool _isDisabled = false;

  @override
  void initState() {
    super.initState();
    _id.addListener(() {
      _idText = _id.text;
      if (_idText == "" || _pwText == "") {
        setState(() {
          _isLoginable = false;
        });
      } else {
        setState(() {
          _isLoginable = true;
        });
      }
    });
    _pw.addListener(() {
      _pwText = _pw.text;
      if (_idText == "" || _pwText == "") {
        setState(() {
          _isLoginable = false;
        });
      } else {
        setState(() {
          _isLoginable = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeInputScreen(
      child: DisabledScreen(
        disabled: _isDisabled,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ImageAssets.BACKGROUND2), // Local image
                fit: BoxFit.cover, // Cover the entire container
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Center(
                      child: SizedBox(
                        height: 350,
                        child: Column(
                          children: [
                            SizedBox(height: 50),
                            CaptionTextField(
                              caption: "아이디",
                              hintText: "아이디",
                              controller: _id,
                            ),
                            SizedBox(height: 10),
                            CaptionTextField(
                              caption: "비밀번호",
                              hintText: "비밀번호",
                              controller: _pw,
                            ),
                            SizedBox(height: 30),
                            CommonButton(
                              buttonName: "로그인",
                              callback:
                                  _isLoginable && _isLogining == false
                                      ? () async {
                                        setState(() {
                                          _isLogining = true;
                                        });

                                        SupabaseAPI api =
                                            SupabaseAPI.getInstance();
                                        UserInfo? userInfo =
                                            await api.LoginWithIDandPW(
                                              _idText,
                                              _pwText,
                                            );

                                        if (userInfo == null) {
                                          List<Widget> contents = [
                                            Icon(
                                              Icons.error,
                                              size: 100,
                                              color: MainColors.MainRed,
                                            ),
                                            CommonText(
                                              text: "아이디 또는 비밀번호가\n 일치하지 않아요!",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: MainColors.MainBlack,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 30),
                                            CommonButton(
                                              buttonName: "확인",
                                              callback: () {
                                                Navigator.pop(context);
                                              },
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: MainColors.PrimaryColor,
                                              ),
                                            ),
                                          ];
                                          showDialog(
                                            context: context,
                                            builder:
                                                (context) =>
                                                    CommonDialog.makeCommonDialog(
                                                      contents,
                                                      300,
                                                      280,
                                                    ),
                                          );

                                          setState(() {
                                            _isLogining = false;
                                          });
                                        } else {
                                          ref
                                              .read(
                                                userSessionTokenProvider
                                                    .notifier,
                                              )
                                              .setSession(userInfo);
                                        }
                                      }
                                      : null,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    _isLoginable && _isLogining == false
                                        ? MainColors.PrimaryColor
                                        : MainColors.PrimaryColorDisable,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CommonTextButton(
                                name: "아이디 찾기",
                                callback: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FindIdScreen(),
                                      fullscreenDialog: true,
                                    ),
                                  );
                                },
                              ),
                              CommonTextButton(
                                name: "비밀번호 찾기",
                                callback: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FindPWScreen(),
                                      fullscreenDialog: true,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.topCenter,
                          child: CommonText(
                            text: "간편 로그인",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            LogInButton(
                              icon: ImageAssets.CALL_ICON,
                              login: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpAuthScreen(),
                                    // builder:
                                    //     (context) => SignUpScreen(
                                    //       name: "김준무",
                                    //       phone: "01012345678",
                                    //     ),
                                    // fullscreenDialog: true,
                                  ),
                                );
                              },
                            ),
                            LogInButton(
                              icon: ImageAssets.KAKAOTALK_ICON,
                              login: () async {
                                try {
                                  bool isInstalled =
                                      await kakao.isKakaoTalkInstalled();

                                  kakao.OAuthToken token =
                                      isInstalled
                                          ? await kakao.UserApi.instance
                                              .loginWithKakaoTalk()
                                          : await kakao.UserApi.instance
                                              .loginWithKakaoAccount();

                                  // 사용자 정보 가져오기
                                  kakao.User user =
                                      await kakao.UserApi.instance.me();

                                  SupabaseAPI client =
                                      SupabaseAPI.getInstance();

                                  // 카카오 계정 존재 여부 조회
                                  bool? isExistKakao = await client
                                      .isKakaoAccountExist(
                                        user.kakaoAccount!.profile!.nickname!,
                                        "8201012345678",
                                      );

                                  /*  비즈앱 설정 후 변경사항
                                  bool? isExistKakao = await client
                                      .isKakaoAccountExist(
                                        user.kakaoAccount!.profile!.nickname!,
                                        user.kakaoAccount!.phoneNumber,
                                      );*/

                                  // 카카오 계정이 존재하지 않다면, 학년 선택, 존재하면 생략.
                                  Map<String, String?>? extra = null;
                                  if (isExistKakao == false) {
                                    extra = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AppendExtraInfoScreen(
                                              phoneNumber: "8201012345678",
                                              type: SocialLoginType.KAKAO,
                                            ),
                                        fullscreenDialog: true,
                                      ),
                                    );
                                  }

                                  // 카카오 계정이 없고, 학년도 선택하지 않았을 경우, 아무것도 하지 않는다.
                                  if (isExistKakao == false && extra == null)
                                    return;

                                  int grade = -1;
                                  if (extra != null) {
                                    switch (extra["grade"]) {
                                      case "1 학년":
                                        grade = 1;
                                        break;
                                      case "2 학년":
                                        grade = 2;
                                        break;
                                      case "3 학년":
                                        grade = 3;
                                        break;
                                    }
                                  }
                                  // 카카오톡으로부터 사용자 정보를 받아와 백엔드 서버에서 커스텀 인증 시스템으로 등록
                                  // 아이디는 kakao{이름}, ex) kakao홍길동
                                  // 비밀번호는 kakao
                                  /*
                                Map<String?, dynamic> profile = {
                                  "name": user.kakaoAccount!.profile!.nickname,
                                  "username":"kakao",
                                  "password": "kakao",
                                  "is_admin": false,
                                  "profile_img": "",
                                  "birthday": user.kakaoAccount!.birthday,
                                  "phone": user.kakaoAccount!.phoneNumber,
                                  "class_no": -1,
                                  "grade": 1,
                                };*/

                                  // 비즈앱 이전 더미 객체
                                  Map<String, dynamic> profile = {
                                    "name":
                                        user.kakaoAccount!.profile!.nickname,
                                    "username":
                                        "kakao${user.kakaoAccount!.profile!.nickname}",
                                    "password": "kakao",
                                    "is_admin": false,
                                    "profile_img": "",
                                    "birthday": "000000",
                                    "phone": "8201012345678",
                                    "class_no": -1,
                                    "grade": grade,
                                  };
                                  setState(() {
                                    _isDisabled = true;
                                  });

                                  UserInfo? userInfo =
                                      await client.KakaoAccount(profile);

                                  ref
                                      .read(userSessionTokenProvider.notifier)
                                      .setSession(userInfo!);

                                  setState(() {
                                    _isDisabled = false;
                                  });
                                } catch (e) {
                                  print('Login failed: $e');
                                  /*setState(() {
                                  _loginStatus = 'Login failed';
                                });*/
                                }
                              },
                            ),
                            LogInButton(
                              icon: ImageAssets.GOOGLE_ICON,
                              login: () async {
                                try {
                                  SupabaseAPI client =
                                      SupabaseAPI.getInstance();

                                  final GoogleSignIn
                                  _googleSignIn = GoogleSignIn(
                                    scopes: [
                                      'email',
                                      'https://www.googleapis.com/auth/userinfo.profile',
                                    ],
                                  );

                                  final GoogleSignInAccount? googleUser =
                                      await _googleSignIn.signIn();

                                  if (googleUser == null) return;

                                  // 구글 계정이 있는지 확인
                                  bool? isExistGoogle = await client
                                      .isGoogleAccountExist(googleUser.email);

                                  Map<String, String?>? extra = null;
                                  // 구글 계정이 존재하지 않다면, 추가 정보를 받음.
                                  if (isExistGoogle == false) {
                                    extra = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AppendExtraInfoScreen(
                                              type: SocialLoginType.GOOGLE,
                                            ),
                                        fullscreenDialog: true,
                                      ),
                                    );
                                  }
                                  // 구글 계정이 없고, 추가 사항을 선택하지 않았을 경우, 아무것도 하지 않는다.
                                  if (isExistGoogle == false && extra == null)
                                    return;

                                  int grade = -1;
                                  String phone = "";
                                  String birthday = "";
                                  if (extra != null) {
                                    switch (extra["grade"]) {
                                      case "1 학년":
                                        grade = 1;
                                        break;
                                      case "2 학년":
                                        grade = 2;
                                        break;
                                      case "3 학년":
                                        grade = 3;
                                        break;
                                    }
                                    phone = "82${extra["phone"]}";
                                    // 입력받은 전화번호에 지역번호를 붙힌다.
                                    birthday = extra["birthday"]!;
                                  }

                                  Map<String, dynamic> profile = {
                                    "name": googleUser.displayName,
                                    "email": googleUser.email,
                                    "username":
                                        "google${googleUser.displayName}",
                                    "password": "google",
                                    "is_admin": false,
                                    "profile_img": "",
                                    "birthday": birthday,
                                    "phone": phone,
                                    "class_no": -1,
                                    "grade": grade,
                                  };
                                  setState(() {
                                    _isDisabled = true;
                                  });

                                  UserInfo? userInfo =
                                      await client.GoogleAccount(profile);

                                  ref
                                      .read(userSessionTokenProvider.notifier)
                                      .setSession(userInfo!);

                                  setState(() {
                                    _isDisabled = false;
                                  });
                                } catch (e) {
                                  print("Google sign-in error: $e");
                                }
                              },
                            ),
                            LogInButton(
                              icon: ImageAssets.APPLE_ICON,
                              login: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
