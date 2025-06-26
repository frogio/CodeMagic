import 'package:english_word_app/consts/colors.dart';
import './main_tab_tile.dart';
import '../consts/image_assets.dart';
import '../screens/main_screen/main_tab_screen/home_screen.dart';
import '../screens/main_screen/main_tab_screen/today_word_screen.dart';
import '../screens/main_screen/main_tab_screen/mistake_note_screen.dart';
import '../screens/main_screen/main_tab_screen/profile_screen.dart';
import 'package:flutter/material.dart';

class MainTab extends StatefulWidget {
  VoidCallback callback;

  MainTab({super.key, required this.callback});

  @override
  State<MainTab> createState() => MainTabState();
}

class MainTabState extends State<MainTab> {
  int _selectedIndex = -1;

  int getCurrentTab() => _selectedIndex;

  void returnToHome() {
    setState(() {
      _selectedIndex = -1;
    });
  }

  void controlTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget swapScreen() {
    switch (_selectedIndex) {
      case 0:
        return TodayWordScreen();
      case 1:
        return MistakeNoteScreen();
      case 2:
        return ProfileScreen();
      case -1:
        return HomeScreen();
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MainColors.MainWhite,
      child: Column(
        children: [
          Expanded(
            flex: 9,
            child: SizedBox(width: double.infinity, child: swapScreen()),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                MainTabTile(
                  index: 0,
                  selectedIndex: _selectedIndex,
                  clickCallback: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                    widget.callback();
                  },
                  selectedImg: ImageAssets.TAB1_ENABLE,
                  unSelectedImg: ImageAssets.TAB1_DISABLE,
                ),
                MainTabTile(
                  index: 1,
                  selectedIndex: _selectedIndex,
                  clickCallback: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                    widget.callback();
                  },
                  selectedImg: ImageAssets.TAB2_ENABLE,
                  unSelectedImg: ImageAssets.TAB2_DISABLE,
                ),
                MainTabTile(
                  index: 2,
                  selectedIndex: _selectedIndex,
                  clickCallback: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                    widget.callback();
                  },
                  selectedImg: ImageAssets.TAB3_ENABLE,
                  unSelectedImg: ImageAssets.TAB3_DISABLE,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
