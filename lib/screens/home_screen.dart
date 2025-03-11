import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toonflix/models/webtoon_models.dart';
import '../services/api_service.dart';
import '../widgets/webtoon_item.dart';
import 'package:toonflix/screens/episode_screen.dart';
import '../widgets/webtoon_list.dart';

class HomeScreen extends StatefulWidget {
  List<String>? favoriteMarks;
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _SharedPrefFavoriteKey = "FAVORITE";

  Future<void> getFavorite() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    if (sharedPrefs != null) {
      setState(() {
        widget.favoriteMarks =
            sharedPrefs.getStringList(_SharedPrefFavoriteKey);
        if (widget.favoriteMarks == null) widget.favoriteMarks = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getFavorite();
  }

  // List<WebtoonModel> webtoons = [];
  Widget buildList(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      return WebtoonList(dataSnapshot: snapshot);
    }
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Theme.of(context).appBarTheme.shadowColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        title: Center(
          child: Text(
            "오늘의 웹툰",
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: FutureBuilder(
                future: APIService.getInstance().getTodayWebtoonList(),
                builder: buildList),
          )
        ],
      ),
    );
  }
}
