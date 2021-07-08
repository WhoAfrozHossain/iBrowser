class AdsModel {
  String? sId;
  String? url;
  int? minVisitingTime;
  String? instruction;
  int? revenue;
  String? createdAt;
  String? updatedAt;
  String? title;

  AdsModel(
      {this.sId,
      this.url,
      this.minVisitingTime,
      this.instruction,
      this.revenue,
      this.createdAt,
      this.updatedAt,
      this.title});

  AdsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    url = json['url'];
    minVisitingTime = json['minVisitingTime'];
    instruction = json['instruction'];
    revenue = json['revenue'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['url'] = this.url;
    data['minVisitingTime'] = this.minVisitingTime;
    data['instruction'] = this.instruction;
    data['revenue'] = this.revenue;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['title'] = this.title;
    return data;
  }
}
