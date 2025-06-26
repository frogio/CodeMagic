import 'package:english_word_app/api/supabase_api.dart';
import 'package:english_word_app/components/caption_text_field.dart';
import 'package:english_word_app/components/common/common_button.dart';
import 'package:english_word_app/components/common/common_text.dart';
import 'package:english_word_app/components/dialog/common_dialog.dart';
import 'package:english_word_app/consts/colors.dart';
import 'package:english_word_app/consts/image_assets.dart';
import 'package:english_word_app/consts/layout.dart';
import 'package:english_word_app/provider/session.dart';
import 'package:english_word_app/screens/common/disabled_screen.dart';
import 'package:english_word_app/screens/common/safe_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePWScreen extends ConsumerStatefulWidget {
  const ChangePWScreen({super.key});

  @override
  ConsumerState<ChangePWScreen> createState() => _ChangePWScreenState();
}

class _ChangePWScreenState extends ConsumerState<ChangePWScreen> {
  TextEditingController _pw = TextEditingController();
  TextEditingController _pwConfirm = TextEditingController();
  String _pwText = "", _pwConfirmText = "";

  bool _isNoneBlanked = false;
  bool _isDisabled = false;

  @override
  void initState() {
    _pw.addListener(() {
      _pwText = _pw.text;
      if (_pwText == "" || _pwConfirmText == "") {
        setState(() {
          _isNoneBlanked = false;
        });
      } else {
        setState(() {
          _isNoneBlanked = true;
        });
      }
    });

    _pwConfirm.addListener(() {
      _pwConfirmText = _pwConfirm.text;
      if (_pwText == "" || _pwConfirmText == "") {
        setState(() {
          _isNoneBlanked = false;
        });
      } else {
        setState(() {
          _isNoneBlanked = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(userSessionTokenProvider);

    return DisabledScreen(
      disabled: _isDisabled,
      child: SafeInputScreen(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios), // Use your custom icon here
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: CommonText(text: "비밀번호 변경"),
          ),
          body: Container(
            padding: ScreenLayout.COMMON_TAB_PADING,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CommonText(
                      text: '비밀번호 변경',
                      style: TextStyle(
                        color: MainColors.MainBlack,
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(height: 35),
                    CaptionTextField(
                      controller: _pw,
                      caption: "비밀번호",
                      hintText: "비밀번호",
                      obsecureMode: true,
                    ),
                    SizedBox(height: 10),
                    CaptionTextField(
                      controller: _pwConfirm,
                      caption: "비밀번호 확인",
                      hintText: "비밀번호 확인",
                      obsecureMode: true,
                    ),
                  ],
                ),
                Column(
                  children: [
                    CommonButton(
                      buttonName: "변경",
                      callback:
                          _isNoneBlanked
                              ? () async {
                                if (_pwText != _pwConfirmText) {
                                  List<Widget> contents = [
                                    Icon(
                                      Icons.error,
                                      size: 100,
                                      color: MainColors.MainRed,
                                    ),
                                    CommonText(
                                      text: "비밀번호가 일치하지 않습니다!",
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
                                        Navigator.pop(context, true);
                                      },
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
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
                                  return;
                                } else {
                                  setState(() {
                                    _isDisabled = true;
                                  });
                                  SupabaseAPI client =
                                      SupabaseAPI.getInstance();

                                  await client.changeUserPassword(
                                    userInfo.id,
                                    _pwText,
                                    userInfo.accessJwt,
                                  );

                                  setState(() {
                                    _isDisabled = false;
                                  });

                                  List<Widget> contents = [
                                    Image.asset(ImageAssets.CONFIRM_MARK),
                                    CommonText(
                                      text: "비밀번호가 변경되었습니다.",
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
                                        Navigator.pop(context);
                                      },
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: MainColors.PrimaryColor,
                                      ),
                                    ),
                                  ];
                                  await showDialog(
                                    context: context,
                                    builder:
                                        (context) =>
                                            CommonDialog.makeCommonDialog(
                                              contents,
                                              300,
                                              250,
                                            ),
                                  );
                                  Navigator.pop(context);
                                }
                              }
                              : null,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:
                            _isNoneBlanked
                                ? MainColors.PrimaryColor
                                : MainColors.PrimaryColorDisable,
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
