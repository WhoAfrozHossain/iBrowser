class NewsModel {
  String? sId;
  String? title;
  String? description;
  String? collectFrom;
  String? topic;
  String? image;
  String? createdAt;
  String? updatedAt;

  NewsModel(
      {this.sId,
      this.title,
      this.description,
      this.collectFrom,
      this.topic,
      this.image,
      this.createdAt,
      this.updatedAt});

  NewsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    collectFrom = json['collectFrom'];
    topic = json['topic'];
    image = json['image'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['collectFrom'] = this.collectFrom;
    data['topic'] = this.topic;
    data['image'] = this.image;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
