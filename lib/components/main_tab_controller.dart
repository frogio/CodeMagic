import 'package:flutter/material.dart';
import 'main_tab.dart';

class MainTabController {
  GlobalKey<MainTabState> _tabKey = GlobalKey<MainTabState>();
  static MainTabController _instance = MainTabController._private();
  MainTabController._private();

  static MainTabController getInstance() {
    return _instance;
  }

  void getTab(int index) {
    _tabKey.currentState!.controlTap(index);
  }

  int getCurrentTab() {
    return _tabKey.currentState!.getCurrentTab();
  }

  GlobalKey<MainTabState> getKey() => _tabKey;
}
