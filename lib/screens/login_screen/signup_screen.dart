import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:english_word_app/components/dialog/common_dialog.dart';
import 'package:english_word_app/consts/image_assets.dart';
import 'package:english_word_app/screens/common/safe_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:english_word_app/components/caption_text_field.dart';
import 'package:english_word_app/components/common/common_text.dart';
import '../../components/common/common_button.dart';
import '../../components/common/fat_button.dart';
import '../../consts/colors.dart';

class SignUpScreen extends StatefulWidget {
  final String name; // 실제 사용자 이름
  final String phone;

  const SignUpScreen({super.key, required this.name, required this.phone});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _id = TextEditingController();
  TextEditingController _pw = TextEditingController();
  TextEditingController _pwConfirm = TextEditingController();

  SupabaseClient supabaseClient = Supabase.instance.client;

  bool _isIDEdit = false;
  bool _checkDuplicatedId = false;
  bool _isDuplicatedId = true;
  bool _isNotMatchedPw = false;
  bool _isSelectedGrade = false;

  final List<String> _grades = ["1학년", "2학년", "3학년"];
  String? _selectedGrade = null;
  int _grade = -1;

  @override
  void dispose() {
    _pw.dispose();
    _pwConfirm.dispose();
    _id.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _id.addListener(() {
      if (_id.text != "")
        setState(() {
          _isIDEdit = true;
        });
      else
        setState(() {
          _isIDEdit = false;
        });
    });
  }

  Future<void> checkDuplicatedId() async {
    _checkDuplicatedId = true;
    final username = _id.text.trim();

    // Check for duplicate username
    final exists =
        await supabaseClient
            .from('profiles')
            .select()
            .eq('username', username)
            .maybeSingle();

    if (exists != null) // 이미 아이디가 존재하면
      setState(() {
        _isDuplicatedId = true; // 중복됨
      });
    else
      setState(() {
        _isDuplicatedId = false;
      }); // 아이디가 존재하지 않으면
  }

  Future<void> registerUser() async {
    final username = _id.text.trim();
    final password = _pw.text.trim();
    final user = supabaseClient.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    if (_pw.text != _pwConfirm.text) {
      setState(() {
        _isNotMatchedPw = true;
      });
      return;
    }

    final res = await supabaseClient.functions.invoke(
      'Account',
      method: HttpMethod.post,
      headers: {'Content-Type': 'application/json'},
      body: {
        "target": "user",
        "action": "phone_signup",
        "id": user.id,
        "username": username,
        "name": widget.name,
        "pw": password,
        "is_admin": false,
        "birthday": "000000",
        "phone": widget.phone,
        "class_no": "-1",
        "grade": _grade,
      },
    );
    final data = res.data;

    showAcceptDialog();
  }

  // 300, 250
  void showAcceptDialog() {
    List<Widget> contents = [
      Image.asset(ImageAssets.CONFIRM_MARK),
      CommonText(
        text: "가입을 축하해요!",
        style: TextStyle(
          color: MainColors.MainBlack,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      SizedBox(height: 30),
      CommonButton(
        buttonName: "다음",
        callback: () {
          Navigator.pop(context);
        },
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: MainColors.PrimaryColor,
        ),
      ),
    ];
    showDialog(
      context: context,
      builder: (context) => CommonDialog.makeCommonDialog(contents, 300, 250),
    );
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
                flex: 3,
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
                    SizedBox(height: 50),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 3,
                          child: CaptionTextField(
                            caption: "아이디",
                            controller: _id,
                            hintText: "아이디",
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.bottomRight,
                            child: FatButton(
                              callback: _isIDEdit ? checkDuplicatedId : null,
                              buttonName: "중복확인",
                              color:
                                  _isIDEdit
                                      ? MainColors.PrimaryColor
                                      : MainColors.MainGray,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _isDuplicatedId && _checkDuplicatedId
                        ? CommonText(
                          text: "사용중인 아이디입니다.",
                          style: TextStyle(fontSize: 15, color: Colors.red),
                        )
                        : SizedBox(height: 15),
                    SizedBox(height: 20),

                    _isDuplicatedId == false
                        ? Column(
                          children: [
                            CaptionTextField(
                              caption: "비밀번호",
                              controller: _pw,
                              hintText: "비밀번호",
                              obsecureMode: true,
                            ),
                            SizedBox(height: 10),
                            CaptionTextField(
                              caption: "비밀번호 확인",
                              controller: _pwConfirm,
                              hintText: "비밀번호 확인",
                              obsecureMode: true,
                            ),
                            SizedBox(height: 20),
                            _isNotMatchedPw
                                ? CommonText(
                                  text: "비밀번호가 일치하지 않습니다. 비밀번호를 확인해주세요",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.red,
                                  ),
                                )
                                : SizedBox(height: 15),
                            // SizedBox(height: 20),
                            Column(
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
                                        _isSelectedGrade = true;
                                      });
                                      switch (_selectedGrade) {
                                        case "1학년":
                                          _grade = 1;
                                          break;
                                        case "2학년":
                                          _grade = 2;
                                          break;
                                        case "3학년":
                                          _grade = 3;
                                          break;
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                        _checkDuplicatedId &&
                                _isDuplicatedId == false &&
                                _isSelectedGrade // 중복체크를 한번 이상하고, 중복되지 않을 경우, 학년이 선택되었을 경우
                            ? registerUser
                            : null, // registerUser 메서드에서 Password 일치 여부 검사를 함
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:
                          _checkDuplicatedId &&
                                  _isDuplicatedId == false &&
                                  _isSelectedGrade // 중복체크를 한번 이상하고, 중복되지 않을 경우, 학년이 선택되었을 경우
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
