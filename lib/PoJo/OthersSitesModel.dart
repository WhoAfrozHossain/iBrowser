class OthersSitesModel {
  String? sId;
  int? minVisitingTime;
  int? revenue;
  String? createdAt;
  String? updatedAt;

  OthersSitesModel(
      {this.sId,
      this.minVisitingTime,
      this.revenue,
      this.createdAt,
      this.updatedAt});

  OthersSitesModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    minVisitingTime = json['minVisitingTime'];
    revenue = json['revenue'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['minVisitingTime'] = this.minVisitingTime;
    data['revenue'] = this.revenue;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
