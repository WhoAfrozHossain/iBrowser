class BookmarkModel {
  String? sId;
  String? title;
  String? siteUrl;
  String? userId;
  String? createdAt;
  String? updatedAt;

  BookmarkModel(
      {this.sId,
      this.title,
      this.siteUrl,
      this.userId,
      this.createdAt,
      this.updatedAt});

  BookmarkModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    siteUrl = json['siteUrl'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['siteUrl'] = this.siteUrl;
    data['userId'] = this.userId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
