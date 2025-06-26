import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:english_word_app/components/caption_text_field.dart';
import 'package:english_word_app/components/common/common_button.dart';
import 'package:english_word_app/components/common/common_text.dart';
import 'package:english_word_app/components/common/fat_button.dart';
import 'package:english_word_app/components/common/text_field.dart';
import 'package:english_word_app/components/date_picker.dart';
import 'package:english_word_app/consts/colors.dart';
import 'package:english_word_app/consts/enums.dart';
import 'package:english_word_app/consts/layout.dart';
import 'package:flutter/material.dart';

class AppendExtraInfoScreen extends StatefulWidget {
  String? phoneNumber;
  SocialLoginType type;

  AppendExtraInfoScreen({super.key, this.phoneNumber, required this.type});

  @override
  State<AppendExtraInfoScreen> createState() => _AppendExtraInfoScreenState();
}

class _AppendExtraInfoScreenState extends State<AppendExtraInfoScreen> {
  String? _selectedGrade = null;
  TextEditingController _hpController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  bool _isBlanked = false;
  bool _isExistPhone = false;
  String _blankedMsg = "";

  final List<String> _gradeList = ["1 학년", "2 학년", "3 학년"];
  @override
  void dispose() {
    _hpController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // 카카오톡으로 이미 전화번호를 받았다면, 받은 전화번호를 Textfield에 입력한다.
    if (widget.type == SocialLoginType.KAKAO) {
      _hpController.text = widget.phoneNumber!;
      _isExistPhone = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), // Use your custom icon here
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: CommonText(text: "추가 정보 기재"),
      ),
      body: Container(
        padding: ScreenLayout.COMMON_TAB_PADING,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CaptionTextField(
                  caption: "전화번호",
                  hintText: "- 없이 기재",
                  controller: _hpController,
                  enabled: !_isExistPhone,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                widget.type == SocialLoginType.GOOGLE
                    ? DatePickerField(controller: _dateController)
                    : SizedBox(),
                SizedBox(height: 10),
                DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    hint: Text("학년을 선택해 주세요."),
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
                        _gradeList.map<DropdownMenuItem<String>>((
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
                        _gradeList.length,
                        (index) => 70, // 👈 custom height per item
                      ),
                    ),
                    onChanged: (String? grade) {
                      setState(() {
                        _selectedGrade = grade;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                _isBlanked
                    ? CommonText(
                      text: _blankedMsg,
                      style: TextStyle(color: MainColors.MainRed),
                    )
                    : SizedBox(),
              ],
            ),
            // SizedBox(width: 10),
            Column(
              children: [
                CommonButton(
                  buttonName: "확인",
                  decoration: BoxDecoration(
                    color: MainColors.PrimaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  callback: () {
                    if (_isExistPhone == false) {
                      final regex = RegExp(r'^01[016789]\d{7,8}$');

                      if (regex.hasMatch(_hpController.text) == false) {
                        setState(() {
                          _isBlanked = true;
                          _blankedMsg = "유효한 전화번호가 아닙니다.";
                        });
                        return;
                      }
                    }

                    if (_dateController.text == "" &&
                        widget.type == SocialLoginType.GOOGLE) {
                      setState(() {
                        _isBlanked = true;
                        _blankedMsg = "생년월일을 입력해 주세요";
                      });
                      return;
                    }

                    if (_selectedGrade == null) {
                      setState(() {
                        _isBlanked = true;
                        _blankedMsg = "학년이 선택되지 않았습니다.";
                      });
                      return;
                    }

                    Map<String, String?> extraInfo = {
                      "phone": _hpController.text,
                      "grade": _selectedGrade,
                      "birthday": _dateController.text,
                    };

                    Navigator.pop(context, extraInfo);
                  },
                ),
                SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
