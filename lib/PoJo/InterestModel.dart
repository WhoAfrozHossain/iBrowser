class InterestModel {
  String? sId;
  String? topic;
  String? createdAt;
  String? updatedAt;

  InterestModel({this.sId, this.topic, this.createdAt, this.updatedAt});

  InterestModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    topic = json['topic'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['topic'] = this.topic;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
