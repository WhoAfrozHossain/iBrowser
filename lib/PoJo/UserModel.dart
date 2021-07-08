class UserModel {
  List<String>? _interests;
  String? _sId;
  String? _name;
  String? _phone;
  String? _email;
  String? _password;
  String? _gender;
  String? _countryId;
  String? _cityId;
  String? _withdrawalMethodId;
  String? _accountNo;
  int? _walletAmount;
  int? _totalMinuteServed;
  int? _totalAdsViewed;
  String? _createdAt;
  String? _updatedAt;

  UserModel(
      {List<String>? interests,
      String? sId,
      String? name,
      String? phone,
      String? email,
      String? password,
      String? gender,
      String? countryId,
      String? cityId,
      String? withdrawalMethodId,
      String? accountNo,
      int? walletAmount,
      int? totalMinuteServed,
      int? totalAdsViewed,
      String? createdAt,
      String? updatedAt}) {
    this._interests = interests;
    this._sId = sId;
    this._name = name;
    this._phone = phone;
    this._email = email;
    this._password = password;
    this._gender = gender;
    this._countryId = countryId;
    this._cityId = cityId;
    this._withdrawalMethodId = withdrawalMethodId;
    this._accountNo = accountNo;
    this._walletAmount = walletAmount;
    this._totalMinuteServed = totalMinuteServed;
    this._totalAdsViewed = totalAdsViewed;
    this._createdAt = createdAt;
    this._updatedAt = updatedAt;
  }

  List<String>? get interests => _interests;
  set interests(List<String>? interests) => _interests = interests;
  String? get sId => _sId;
  set sId(String? sId) => _sId = sId;
  String? get name => _name;
  set name(String? name) => _name = name;
  String? get phone => _phone;
  set phone(String? phone) => _phone = phone;
  String? get email => _email;
  set email(String? email) => _email = email;
  String? get password => _password;
  set password(String? password) => _password = password;
  String? get gender => _gender;
  set gender(String? gender) => _gender = gender;
  String? get countryId => _countryId;
  set countryId(String? countryId) => _countryId = countryId;
  String? get cityId => _cityId;
  set cityId(String? cityId) => _cityId = cityId;
  String? get withdrawalMethodId => _withdrawalMethodId;
  set withdrawalMethodId(String? withdrawalMethodId) =>
      _withdrawalMethodId = withdrawalMethodId;
  String? get accountNo => _accountNo;
  set accountNo(String? accountNo) => _accountNo = accountNo;
  int? get walletAmount => _walletAmount;
  set walletAmount(int? walletAmount) => _walletAmount = walletAmount;
  int? get totalMinuteServed => _totalMinuteServed;
  set totalMinuteServed(int? totalMinuteServed) =>
      _totalMinuteServed = totalMinuteServed;
  int? get totalAdsViewed => _totalAdsViewed;
  set totalAdsViewed(int? totalAdsViewed) => _totalAdsViewed = totalAdsViewed;
  String? get createdAt => _createdAt;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  String? get updatedAt => _updatedAt;
  set updatedAt(String? updatedAt) => _updatedAt = updatedAt;

  UserModel.fromJson(Map<String, dynamic> json) {
    _interests = json['interests'].cast<String>();
    _sId = json['_id'];
    _name = json['name'];
    _phone = json['phone'];
    _email = json['email'];
    _password = json['password'];
    _gender = json['gender'];
    _countryId = json['countryId'];
    _cityId = json['cityId'];
    _withdrawalMethodId = json['withdrawalMethodId'];
    _accountNo = json['accountNo'];
    _walletAmount = json['walletAmount'];
    _totalMinuteServed = json['totalMinuteServed'];
    _totalAdsViewed = json['totalAdsViewed'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['interests'] = this._interests;
    data['_id'] = this._sId;
    data['name'] = this._name;
    data['phone'] = this._phone;
    data['email'] = this._email;
    data['password'] = this._password;
    data['gender'] = this._gender;
    data['countryId'] = this._countryId;
    data['cityId'] = this._cityId;
    data['withdrawalMethodId'] = this._withdrawalMethodId;
    data['accountNo'] = this._accountNo;
    data['walletAmount'] = this._walletAmount;
    data['totalMinuteServed'] = this._totalMinuteServed;
    data['totalAdsViewed'] = this._totalAdsViewed;
    data['createdAt'] = this._createdAt;
    data['updatedAt'] = this._updatedAt;
    return data;
  }
}
