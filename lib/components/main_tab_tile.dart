import 'package:english_word_app/consts/image_assets.dart';
import 'package:flutter/material.dart';
import '../components/common/common_text_button.dart';

class MainTabTile extends StatefulWidget {
  final int index;
  int selectedIndex;
  final VoidCallback clickCallback;
  final String selectedImg;
  final String unSelectedImg;
  MainTabTile({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.clickCallback,
    required this.selectedImg,
    required this.unSelectedImg,
  });

  @override
  State<MainTabTile> createState() => _MainTabTileState();
}

class _MainTabTileState extends State<MainTabTile> {
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: widget.clickCallback,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        width: deviceWidth / 3,
        height: deviceWidth / 3,
        child:
            widget.selectedIndex == widget.index
                ? Image.asset(widget.selectedImg)
                : Image.asset(widget.unSelectedImg),
      ),
    );
  }
}
