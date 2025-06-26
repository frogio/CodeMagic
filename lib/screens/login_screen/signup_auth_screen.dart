import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:english_word_app/components/common/text_field.dart';
import 'package:english_word_app/screens/common/safe_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:english_word_app/components/caption_text_field.dart';
import 'package:english_word_app/components/common/common_button.dart';
import 'package:english_word_app/components/common/common_text.dart';
import 'signup_screen.dart';
import '../../components/common/fat_button.dart';
import '../../consts/colors.dart';

class SignUpAuthScreen extends StatefulWidget {
  const SignUpAuthScreen({super.key});

  @override
  State<SignUpAuthScreen> createState() => _SignInAuthScreenState();
}

class _SignInAuthScreenState extends State<SignUpAuthScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  SupabaseClient supabaseClient = Supabase.instance.client;

  bool isPhoneEdit = false;
  bool isAuthNoEdit = false;

  bool isOTPSend = false;
  bool _isExpired = false;
  bool _isInvalid = false;
  bool isVerified = false;
  late Timer _timer;
  int _remainingSeconds = 180; // 3 minutes
  String _stateMsg = "인증되었습니다";

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration.zero, () {});
    _phoneController.addListener(() {
      if (_phoneController.text != "")
        setState(() {
          isPhoneEdit = true;
        });
      else
        setState(() {
          isPhoneEdit = false;
        });
    });

    _otpController.addListener(() {
      if (_otpController.text != "")
        setState(() {
          isAuthNoEdit = true;
        });
      else
        setState(() {
          isAuthNoEdit = false;
        });
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _phoneController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> sendOTP() async {
    try {
      await supabaseClient.auth.signInWithOtp(
        phone: "+82${_phoneController.text.trim()}",
      );
      setState(() => isOTPSend = true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending OTP: $e')));
    }
  }

  Future<void> verifyOTP() async {
    try {
      await supabaseClient.auth.verifyOTP(
        phone: "+82${_phoneController.text.trim()}",
        token: _otpController.text.trim(),
        type: OtpType.sms,
      );
      setState(() {
        isVerified = true;
        _isExpired = false;
        _isInvalid = false;
        _stateMsg = "본인인증이 완료되었습니다.";
      });
    } catch (e) {
      setState(() {
        _stateMsg = "인증 번호를 확인해주세요.";
        _isInvalid = true;
      });
    }
  }

  void startAuthTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _stateMsg = "인증 시간이 초과되었습니다.";
          _isExpired = true;
          _remainingSeconds = 0;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeInputScreen(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios), // Use your custom icon here
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: CommonText(text: "로그인/회원가입"),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: '로그인/회원가입',
                      style: TextStyle(
                        color: MainColors.MainBlack,
                        fontSize: 25,
                      ),
                    ),
                    CommonText(
                      text: "휴대폰 번호 인증으로 간편하게 이용할 수 있어요.",
                      style: TextStyle(
                        color: MainColors.MainGray,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 30),
                    CaptionTextField(
                      caption: "이름을 알려주세요!",
                      hintText: "이름",
                      controller: _nameController,
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 3,
                          child: CaptionTextField(
                            caption: "휴대폰 번호 입력",
                            controller: _phoneController,
                            hintText: "- 없이 입력",
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Container(
                            // height: 85,
                            alignment: Alignment.bottomRight,
                            child: FatButton(
                              callback:
                                  isOTPSend
                                      ? () {
                                        // 재 전송을 요청할 경우
                                        sendOTP();
                                        _remainingSeconds = 180;
                                        startAuthTimer();
                                      }
                                      : () {
                                        // 전송이 될 경우
                                        sendOTP();
                                        startAuthTimer();
                                        FocusScope.of(context).unfocus();
                                      },
                              buttonName: isOTPSend ? "재전송" : "인증요청",
                              color:
                                  isPhoneEdit
                                      ? MainColors.PrimaryColor
                                      : MainColors.MainGray,
                              // width: double.infinity,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    isOTPSend
                        ? Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Stack(
                                children: [
                                  Textfield(
                                    hintText: "인증번호를 입력해주세요",
                                    controller: _otpController,
                                    keyboardType: TextInputType.number,
                                  ),
                                  Positioned(
                                    left: 170,
                                    top: 18,
                                    child: CommonText(
                                      text: formatTime(_remainingSeconds),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: MainColors.PrimaryColorShade,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.bottomRight,
                                child: FatButton(
                                  callback:
                                      // 인증번호가 입력이 되었을 경우
                                      isAuthNoEdit
                                          ? () {
                                            if (_otpController.text != "" &&
                                                _remainingSeconds > 0) {
                                              verifyOTP();
                                              FocusScope.of(context).unfocus();
                                            }
                                          }
                                          : null,

                                  // 인증번호가 입력되지 않았을 경우 클릭 불가
                                  buttonName: "확인",
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color:
                                        isAuthNoEdit
                                            ? MainColors.PrimaryColor
                                            : MainColors.PrimaryColorDisable,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        : SizedBox(),
                    isVerified || _isExpired || _isInvalid
                        ? CommonText(
                          text: _stateMsg,
                          style: TextStyle(fontSize: 15),
                        )
                        : SizedBox(),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(bottom: 30),
                  alignment: Alignment.bottomCenter,
                  child: CommonButton(
                    buttonName: "다음",
                    callback:
                        isVerified
                            ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SignUpScreen(
                                        name: _nameController.text,
                                        phone: _phoneController.text,
                                      ),
                                  fullscreenDialog: true,
                                ),
                              );
                            }
                            : null,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:
                          isVerified
                              ? MainColors.PrimaryColor
                              : MainColors.LightGray,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
