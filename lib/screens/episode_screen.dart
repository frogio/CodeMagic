import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toonflix/models/webtoon_episode.dart';
import 'package:toonflix/models/webtoon_models.dart';
import 'package:toonflix/services/api_service.dart';
import 'package:toonflix/widgets/episode.dart';
import 'package:toonflix/models/webtoon_info.dart';

class EpisodeScreen extends StatefulWidget {
  WebtoonModel model;
  late WebtoonInfo info;
  late final SharedPreferences SharedPrefs;
  EpisodeScreen({super.key, required this.model});
  bool isFavorite = false;

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  static const _SharedPrefFavoriteKey = "FAVORITE";
  late List<WebtoonEpisode> episodes;

  Widget getWebtoonEpisode(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      episodes = snapshot.data;
      return Column(children: [
        for (var episode in episodes)
          Episode(model: widget.model, episode: episode),
      ]);
    }
    return Container();
  }

  Widget getWebtoonInfo(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      widget.info = snapshot.data;
      return Center(
        child: Column(
          children: [
            SizedBox(height: 30),
            Text(
              widget.info.title,
              style: TextStyle(
                color: Theme.of(context).textTheme.displayLarge!.color,
                fontSize: Theme.of(context).textTheme.displayLarge!.fontSize,
                fontWeight:
                    Theme.of(context).textTheme.displayLarge!.fontWeight,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.info.genre,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize:
                        Theme.of(context).textTheme.displayMedium!.fontSize,
                    fontWeight:
                        Theme.of(context).textTheme.displayMedium!.fontWeight,
                  ),
                ),
                SizedBox(width: 30),
                Text(
                  widget.info.age,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize:
                        Theme.of(context).textTheme.displayMedium!.fontSize,
                    fontWeight:
                        Theme.of(context).textTheme.displayMedium!.fontWeight,
                  ),
                )
              ],
            ),
            SizedBox(height: 10),
            Container(
              child: Text(
                widget.info.about,
                style: TextStyle(
                  color: Theme.of(context).textTheme.displaySmall!.color,
                  fontSize: Theme.of(context).textTheme.displaySmall!.fontSize,
                  fontWeight:
                      Theme.of(context).textTheme.displaySmall!.fontWeight,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        children: [
          SizedBox(width: double.infinity, height: 50),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  void getSharedPreferences() async {
    widget.SharedPrefs = await SharedPreferences.getInstance();
    CheckFavoriteMark();
  }

  void CheckFavoriteMark() {
    setState(() {
      List<String>? favorites =
          widget.SharedPrefs.getStringList(_SharedPrefFavoriteKey);
      if (favorites == null) favorites = [];

      if (favorites.contains(widget.model.id)) widget.isFavorite = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getSharedPreferences();
  }

  void addFavorite() async {
    List<String>? favorites =
        widget.SharedPrefs.getStringList(_SharedPrefFavoriteKey);
    if (favorites == null) favorites = [];
    setState(() {
      if (widget.isFavorite == false) {
        favorites?.add(widget.model.id);
        widget.isFavorite = true;
      } else {
        favorites?.remove(widget.model.id);
        widget.isFavorite = false;
      }
    });
    await widget.SharedPrefs.setStringList(_SharedPrefFavoriteKey, favorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Theme.of(context).appBarTheme.shadowColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          widget.model.title,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        actions: [
          IconButton(
              onPressed: addFavorite,
              icon: Icon(
                  widget.isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: Theme.of(context).textTheme.displayMedium!.color))
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            SizedBox(width: double.infinity),
            SizedBox(height: 30),
            Hero(
              tag: widget.model.id,
              child: Container(
                clipBehavior: Clip.hardEdge,
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3,
                      color: Color.fromARGB(0x55, 0x00, 0x00, 0x00),
                      offset: Offset(10, 10),
                    )
                  ],
                ),
                child: Image.network(
                  widget.model.thumb,
                  headers: {
                    "User-Agent":
                        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                  },
                ),
              ),
            ),
            FutureBuilder(
                future:
                    APIService.getInstance().getWebtoonInfo(widget.model.id),
                builder: getWebtoonInfo),
            SizedBox(height: 30),
            FutureBuilder(
              future:
                  APIService.getInstance().getWebtoonEpisodes(widget.model.id),
              builder: getWebtoonEpisode,
            )
          ],
        ),
      ),
    );
  }
}
