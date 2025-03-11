class WebtoonModel {
  final String title, thumb, id;

  WebtoonModel.fromJSON(Map<String, dynamic> json)
      : this.title = json['title'],
        this.thumb = json['thumb'],
        this.id = json['id'];
}
