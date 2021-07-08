import 'dart:convert';

import 'package:best_browser/Dialog/LoadingDialog.dart';
import 'package:best_browser/Dialog/MyDialog.dart';
import 'package:best_browser/PoJo/AdsModel.dart';
import 'package:best_browser/PoJo/CityModel.dart';
import 'package:best_browser/PoJo/CountryModel.dart';
import 'package:best_browser/PoJo/InterestModel.dart';
import 'package:best_browser/PoJo/NewsModel.dart';
import 'package:best_browser/PoJo/OthersSitesModel.dart';
import 'package:best_browser/PoJo/SpecialSitesModel.dart';
import 'package:best_browser/PoJo/UserModel.dart';
import 'package:best_browser/PoJo/WithdrawalMethodModel.dart';
import 'package:best_browser/Service/LocalData.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';

class Network {
  String rootUrl = 'https://i-browser-api.herokuapp.com/';

  var http = Client();

  BuildContext? context = Get.context;

  final localData = GetStorage();

  Future<UserModel> getUserData() async {
    var jsonData;
    var response = await http.get(
      Uri.parse(rootUrl + "api/user/get-one/${LocalData().getUserId()}"),
    );
    jsonData = json.decode(response.body);

    var jsonUserData = jsonData['user'];

    return UserModel.fromJson(jsonUserData);
  }

  Future<List<CountryModel>> getCountries() async {
    var jsonData;

    var response = await http.get(Uri.parse(rootUrl + "api/country/get-all"));
    var jsonOriginal = json.decode(response.body);

    jsonData = jsonOriginal['country'];

    List<CountryModel> zones = jsonData.map<CountryModel>((json) {
      return CountryModel.fromJson(json);
    }).toList();

    return zones;
  }

  Future<List<CityModel>> getCities() async {
    var jsonData;

    var response = await http.get(Uri.parse(rootUrl + "api/city/get-all"));
    var jsonOriginal = json.decode(response.body);

    jsonData = jsonOriginal['city'];

    List<CityModel> zones = jsonData.map<CityModel>((json) {
      return CityModel.fromJson(json);
    }).toList();

    return zones;
  }

  userRegistration(
    String name,
    String email,
    String password,
  ) async {
    Loading().show(context!);

    Map<String, dynamic> data = {
      'name': name,
      'phone': "",
      'email': email,
      'password': password,
      'gender': "",
      'countryId': localData.read('country'),
      'cityId': localData.read('city'),
      'withdrawalMethodId': "",
      'accountNo': ""
    };
    var jsonData;
    var response = await http.post(Uri.parse(rootUrl + "api/user/create"),
        headers: {'Accept': 'application/json'},
        body: data,
        encoding: Encoding.getByName("utf-8"));

    jsonData = json.decode(response.body);

    Loading().dismiss();

    if (jsonData['error']) {
      CustomDialog(
              title: 'Message',
              body: jsonData['message'],
              isOkButton: true,
              okButtonText: "OK",
              okButtonClick: () {
                Get.back();
              },
              isCancelButton: false)
          .show();
    } else {
      var jsonUserData = jsonData['user'];
      LocalData().storeLoginUserData(jsonUserData);
    }
  }

  userLogin(
    String email,
    String password,
  ) async {
    Loading().show(context!);

    Map<String, dynamic> data = {
      'email': email,
      'password': password,
    };
    var jsonData;
    var response = await http.post(Uri.parse(rootUrl + "api/user/user-login"),
        headers: {'Accept': 'application/json'},
        body: data,
        encoding: Encoding.getByName("utf-8"));

    jsonData = json.decode(response.body);

    Loading().dismiss();

    if (jsonData['error']) {
      CustomDialog(
              title: 'Message',
              body: jsonData['message'],
              isOkButton: true,
              okButtonText: "OK",
              okButtonClick: () {
                Get.back();
              },
              isCancelButton: false)
          .show();
    } else {
      var jsonUserData = jsonData['user'];
      LocalData().storeLoginUserData(jsonUserData);
    }
  }

  userUpdate(
    String name,
    String phone,
    String gender,
    String countryId,
    String cityId,
    String withdrawalMethod,
    String accountNo,
  ) async {
    Loading().show(context!);

    Map<String, dynamic> data = {
      'name': name,
      'phone': phone,
      'gender': gender,
      'countryId': countryId,
      'cityId': cityId,
      'withdrawalMethodId': withdrawalMethod,
      'accountNo': accountNo
    };
    var jsonData;
    var response = await http.patch(
        Uri.parse(rootUrl + "api/user/update-one/${LocalData().getUserId()}"),
        headers: {'Accept': 'application/json'},
        body: data,
        encoding: Encoding.getByName("utf-8"));

    jsonData = json.decode(response.body);

    Loading().dismiss();

    if (jsonData['error']) {
      CustomDialog(
              title: 'Message',
              body: jsonData['message'],
              isOkButton: true,
              okButtonText: "OK",
              okButtonClick: () {
                Get.back();
              },
              isCancelButton: false)
          .show();
    } else {
      LocalData().saveCountryAndCity(countryId, cityId);
      Get.snackbar("Success", "User Information Updated Successfully");
      var jsonUserData = jsonData['user'];
      LocalData().storeLoginUserData(jsonUserData);
    }
  }

  Future<List<WithdrawalMethodModel>> getWithdrawalMethods() async {
    var jsonData;

    var response =
        await http.get(Uri.parse(rootUrl + "api/withdrawal-method/get-all"));
    var jsonOriginal = json.decode(response.body);

    jsonData = jsonOriginal['withdrawalMethod'];

    List<WithdrawalMethodModel> methods =
        jsonData.map<WithdrawalMethodModel>((json) {
      return WithdrawalMethodModel.fromJson(json);
    }).toList();

    return methods;
  }

  Future<List<AdsModel>> getAds(int start) async {
    var jsonData;

    var response =
        await http.get(Uri.parse(rootUrl + "api/ads/get-limit/$start"));
    var jsonOriginal = json.decode(response.body);

    jsonData = jsonOriginal['ads'];

    List<AdsModel> ads = jsonData.map<AdsModel>((json) {
      return AdsModel.fromJson(json);
    }).toList();

    return ads;
  }

  Future<AdsModel> getAd(String id) async {
    var jsonData;
    var response = await http.get(
      Uri.parse(rootUrl + "api/ads/get-one/$id"),
    );
    jsonData = json.decode(response.body);

    var jsonUserData = jsonData['ads'];

    return AdsModel.fromJson(jsonUserData);
  }

  adRevenue(String adsId) async {
    Loading().show(context!);

    Map<String, dynamic> data = {
      'adsId': adsId,
      'userId': LocalData().getUserId()
    };
    var jsonData;
    var response = await http.post(Uri.parse(rootUrl + "api/viewed-ads/create"),
        headers: {'Accept': 'application/json'},
        body: data,
        encoding: Encoding.getByName("utf-8"));

    jsonData = json.decode(response.body);

    Loading().dismiss();

    if (jsonData['error']) {
      CustomDialog(
              title: 'Sorry',
              body: "Something went wrong",
              isOkButton: true,
              okButtonText: "OK",
              okButtonClick: () {
                Get.back();
              },
              isCancelButton: false)
          .show();
    } else {
      CustomDialog(
              title: 'Success',
              body: "Revenue Added Successfully",
              isOkButton: true,
              okButtonText: "OK",
              okButtonClick: () {
                Get.back();
              },
              isCancelButton: false)
          .show();
    }
  }

  Future<List<SpecialSitesModel>> getSpecialSites() async {
    var jsonData;

    var response =
        await http.get(Uri.parse(rootUrl + "api/special-revenue-site/get-all"));
    var jsonOriginal = json.decode(response.body);

    jsonData = jsonOriginal['specialRevenueSite'];

    List<SpecialSitesModel> ads = jsonData.map<SpecialSitesModel>((json) {
      return SpecialSitesModel.fromJson(json);
    }).toList();

    return ads;
  }

  Future<List<NewsModel>> getNews(int start) async {
    var jsonData;

    var response =
        await http.get(Uri.parse(rootUrl + "api/news/get-limit/$start"));
    var jsonOriginal = json.decode(response.body);

    jsonData = jsonOriginal['news'];

    List<NewsModel> news = jsonData.map<NewsModel>((json) {
      return NewsModel.fromJson(json);
    }).toList();

    return news;
  }

  Future<OthersSitesModel> getOtherSites() async {
    var jsonData;

    var response =
        await http.get(Uri.parse(rootUrl + "api/other-revenue-site/get-all"));
    var jsonOriginal = json.decode(response.body);

    jsonData = jsonOriginal['otherRevenueSite'];

    List<OthersSitesModel> ads = jsonData.map<OthersSitesModel>((json) {
      return OthersSitesModel.fromJson(json);
    }).toList();

    return ads[0];
  }

  addSiteRevenue(String siteId) async {
    Loading().show(context!);

    Map<String, dynamic> data = {
      'siteId': siteId,
      'userId': LocalData().getUserId()
    };
    var jsonData;
    var response = await http.post(
        Uri.parse(rootUrl + "api/add-site-revenue/create"),
        headers: {'Accept': 'application/json'},
        body: data,
        encoding: Encoding.getByName("utf-8"));

    jsonData = json.decode(response.body);

    Loading().dismiss();

    if (jsonData['error']) {
      CustomDialog(
              title: 'Sorry',
              body: "Something went wrong",
              isOkButton: true,
              okButtonText: "OK",
              okButtonClick: () {
                Get.back();
              },
              isCancelButton: false)
          .show();
    } else {
      CustomDialog(
              title: 'Success',
              body: "Revenue Added Successfully",
              isOkButton: true,
              okButtonText: "OK",
              okButtonClick: () {
                Get.back();
              },
              isCancelButton: false)
          .show();
    }
  }

  Future<List<InterestModel>> getInterests() async {
    var jsonData;

    var response = await http.get(Uri.parse(rootUrl + "api/interest/get-all"));
    var jsonOriginal = json.decode(response.body);

    jsonData = jsonOriginal['interest'];

    List<InterestModel> value = jsonData.map<InterestModel>((json) {
      return InterestModel.fromJson(json);
    }).toList();

    return value;
  }
}
