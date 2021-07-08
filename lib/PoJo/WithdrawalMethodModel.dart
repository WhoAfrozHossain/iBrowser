class WithdrawalMethodModel {
  String? _sId;
  var _title;
  String? _createdAt;
  String? _updatedAt;

  WithdrawalMethodModel(
      {String? sId, var title, String? createdAt, String? updatedAt}) {
    this._sId = sId;
    this._title = title;
    this._createdAt = createdAt;
    this._updatedAt = updatedAt;
  }

  String? get sId => _sId;
  set sId(String? sId) => _sId = sId;
  String get title => _title;
  set title(String title) => _title = title;
  String? get createdAt => _createdAt;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  String? get updatedAt => _updatedAt;
  set updatedAt(String? updatedAt) => _updatedAt = updatedAt;

  WithdrawalMethodModel.fromJson(Map<String, dynamic> json) {
    _sId = json['_id'];
    _title = json['title'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this._sId;
    data['title'] = this._title;
    data['createdAt'] = this._createdAt;
    data['updatedAt'] = this._updatedAt;
    return data;
  }
}
