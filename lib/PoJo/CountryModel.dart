class CountryModel {
  var _sId;
  var _name;
  var _userId;
  var _createdAt;
  var _updatedAt;

  CountryModel(
      {var sId,
        var name,
        var userId,
        var createdAt,
        var updatedAt}) {
    this._sId = sId;
    this._name = name;
    this._userId = userId;
    this._createdAt = createdAt;
    this._updatedAt = updatedAt;
  }

  String get sId => _sId;
  set sId(String sId) => _sId = sId;
  String get name => _name;
  set name(String name) => _name = name;
  String get userId => _userId;
  set userId(String userId) => _userId = userId;
  String get createdAt => _createdAt;
  set createdAt(String createdAt) => _createdAt = createdAt;
  String get updatedAt => _updatedAt;
  set updatedAt(String updatedAt) => _updatedAt = updatedAt;

  CountryModel.fromJson(Map<String, dynamic> json) {
    _sId = json['_id'];
    _name = json['name'];
    _userId = json['userId'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this._sId;
    data['name'] = this._name;
    data['userId'] = this._userId;
    data['createdAt'] = this._createdAt;
    data['updatedAt'] = this._updatedAt;
    return data;
  }
}
