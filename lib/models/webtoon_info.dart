class WebtoonInfo {
  late String title;
  late String about;
  late String genre;
  late String age;
  late String thumb;

  WebtoonInfo.fromJSON(Map<String, dynamic> json)
      : this.title = json['title'],
        this.about = json['about'],
        this.genre = json['genre'],
        this.age = json['age'],
        this.thumb = json['thumb'];
}
