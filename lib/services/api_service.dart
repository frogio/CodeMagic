import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:toonflix/models/webtoon_episode.dart';
import 'package:toonflix/models/webtoon_models.dart';
import '../models/webtoon_info.dart';

class APIService {
  static APIService instance = APIService();
  static const String _baseUrl =
      "https://webtoon-crawler.nomadcoders.workers.dev";

  _APIService() {}

  static APIService getInstance() {
    return instance;
  }

  Future<List<WebtoonModel>> getTodayWebtoonList() async {
    List<WebtoonModel> webtoons = [];
    Uri uri = Uri.parse("$_baseUrl/today");

    try {
      final response = await http.get(uri);
      final list = jsonDecode(response.body); // raw JSON 객체를 받고

      for (var webtoon in list) {
        var model = WebtoonModel.fromJSON(webtoon); // WebtoonModel을 생성해낸다
        webtoons.add(model);
      }
    } catch (e) {
      throw e;
    }

    return webtoons;
  }

  Future<WebtoonInfo> getWebtoonInfo(String id) async {
    WebtoonInfo info;
    Uri uri = Uri.parse("$_baseUrl/$id");
    try {
      final response = await http.get(uri);
      final json = jsonDecode(response.body);
      info = WebtoonInfo.fromJSON(json);
    } catch (e) {
      throw e;
    }

    return info;
  }

  Future<List<WebtoonEpisode>> getWebtoonEpisodes(String id) async {
    List<WebtoonEpisode> episodes = [];
    Uri uri = Uri.parse("$_baseUrl/$id/episodes");
    try {
      final response = await http.get(uri);
      final json = jsonDecode(response.body);
      for (var episode in json) episodes.add(WebtoonEpisode.fromJson(episode));
    } catch (e) {
      throw e;
    }
    return episodes;
  }
}
