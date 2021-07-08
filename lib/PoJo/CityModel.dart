class CityModel {
  var _sId;
  var _name;
  var _countryId;
  var _userCount;
  var _createdAt;
  var _updatedAt;

  CityModel(
      {var sId,
      var name,
      var countryId,
      var userCount,
      var createdAt,
      var updatedAt}) {
    this._sId = sId;
    this._name = name;
    this._countryId = countryId;
    this._userCount = userCount;
    this._createdAt = createdAt;
    this._updatedAt = updatedAt;
  }

  String get sId => _sId;
  set sId(String sId) => _sId = sId;
  String get name => _name;
  set name(String name) => _name = name;
  String get countryId => _countryId;
  set countryId(String countryId) => _countryId = countryId;
  int get userCount => _userCount;
  set userCount(int userCount) => _userCount = userCount;
  String get createdAt => _createdAt;
  set createdAt(String createdAt) => _createdAt = createdAt;
  String get updatedAt => _updatedAt;
  set updatedAt(String updatedAt) => _updatedAt = updatedAt;

  CityModel.fromJson(Map<String, dynamic> json) {
    _sId = json['_id'];
    _name = json['name'];
    _countryId = json['countryId'];
    _userCount = json['userCount'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this._sId;
    data['name'] = this._name;
    data['countryId'] = this._countryId;
    data['userCount'] = this._userCount;
    data['createdAt'] = this._createdAt;
    data['updatedAt'] = this._updatedAt;
    return data;
  }
}
