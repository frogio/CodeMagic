class WebtoonEpisode {
  String thumb;
  String id;
  String title;
  String rating;
  String date;

  WebtoonEpisode.fromJson(Map<String, dynamic> json)
      : this.thumb = json['thumb'],
        this.id = json['id'],
        this.title = json['title'],
        this.rating = json['rating'],
        this.date = json['date'];
}
