import 'package:english_word_app/api/supabase_api.dart';
import 'package:english_word_app/screens/common/disabled_screen.dart';
import 'package:english_word_app/screens/login_screen/login_screen.dart';
import 'package:flutter/material.dart';
import '../../components/common/common_text.dart';
import '../../components/common/common_button.dart';
import '../../consts/colors.dart';
import '../../components/caption_text_field.dart';

class FindIdResultScreen extends StatelessWidget {
  final String name;
  final String phone;
  bool disable = false;
  TextEditingController _id = TextEditingController();

  FindIdResultScreen({super.key, required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    SupabaseAPI client = SupabaseAPI.getInstance();
    _id.text = "여기에 찾은 ID";

    return DisabledScreen(
      disabled: disable,
      child: Scaffold(
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
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: '아이디 찾기',
                      style: TextStyle(
                        color: MainColors.MainBlack,
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(height: 30),
                    FutureBuilder(
                      future: client.FindIdByPhone(phone),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          _id.text = snapshot.data.toString();
                          return CaptionTextField(
                            caption: "$name님의 아이디입니다.",
                            hintText: "이름",
                            controller: _id,
                            enabled: false,
                          );
                        } else {
                          return Center(
                            child: CommonText(text: "아이디가 존재하지 않습니다."),
                          );
                        }
                      },
                    ),
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
                    callback: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (Route<dynamic> route) =>
                            false, // removes all previous routes
                      );
                    },
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: MainColors.PrimaryColor,
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
