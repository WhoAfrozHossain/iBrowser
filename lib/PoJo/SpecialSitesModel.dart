class SpecialSitesModel {
  String? sId;
  String? title;
  String? url;
  int? minVisitingTime;
  int? revenue;
  String? createdAt;
  String? updatedAt;
  String? icon;

  SpecialSitesModel(
      {this.sId,
      this.title,
      this.url,
      this.minVisitingTime,
      this.revenue,
      this.createdAt,
      this.updatedAt,
      this.icon});

  SpecialSitesModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    url = json['url'];
    minVisitingTime = json['minVisitingTime'];
    revenue = json['revenue'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['url'] = this.url;
    data['minVisitingTime'] = this.minVisitingTime;
    data['revenue'] = this.revenue;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['icon'] = this.icon;
    return data;
  }
}
