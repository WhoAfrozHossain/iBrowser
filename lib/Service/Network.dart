import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:iBrowser/Dialog/LoadingDialog.dart';
import 'package:iBrowser/Dialog/LoginDialog.dart';
import 'package:iBrowser/Dialog/MyDialog.dart';
import 'package:iBrowser/PoJo/AdsModel.dart';
import 'package:iBrowser/PoJo/BookmarkModel.dart';
import 'package:iBrowser/PoJo/CityModel.dart';
import 'package:iBrowser/PoJo/CountryModel.dart';
import 'package:iBrowser/PoJo/InterestModel.dart';
import 'package:iBrowser/PoJo/NewsModel.dart';
import 'package:iBrowser/PoJo/OthersSitesModel.dart';
import 'package:iBrowser/PoJo/SpecialSitesModel.dart';
import 'package:iBrowser/PoJo/UserModel.dart';
import 'package:iBrowser/PoJo/WithdrawalMethodModel.dart';
import 'package:iBrowser/PoJo/WithdrawalRequestModel.dart';
import 'package:iBrowser/Service/LocalData.dart';

class Network {
  String rootUrl = 'https://agile-anchorage-05164.herokuapp.com/';

  var http = Client();

  BuildContext? context = Get.context;

  final localData = GetStorage();

  Future<UserModel?> getUserData() async {
    if (LocalData().checkUserLogin()) {
      var jsonData;
      var response = await http.get(
        Uri.parse(rootUrl + "api/user/get-one/${LocalData().getUserId()}"),
      );
      jsonData = json.decode(response.body);

      var jsonUserData = jsonData['user'];

      return UserModel.fromJson(jsonUserData);
    } else {
      return null;
    }
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
      'email': email.toLowerCase(),
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

    print(jsonData);

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
      LocalData().storeLoginUserData(jsonUserData, false);
    }
  }

  userLogin(
    String email,
    String password,
  ) async {
    Loading().show(context!);

    Map<String, dynamic> data = {
      'email': email.toLowerCase(),
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
      LocalData().storeLoginUserData(jsonUserData, false);
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
      LocalData().storeLoginUserData(jsonUserData, false);
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

    print(jsonData);

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

    print(jsonData);

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

  createBookmark(String? title, String? url) async {
    if (LocalData().checkUserLogin()) {
      Loading().show(context!);

      Map<String, dynamic> data = {
        'title': title,
        'siteUrl': url,
        'userId': LocalData().getUserId()
      };
      var jsonData;
      var response = await http.post(Uri.parse(rootUrl + "api/bookmark/create"),
          headers: {'Accept': 'application/json'},
          body: data,
          encoding: Encoding.getByName("utf-8"));

      jsonData = json.decode(response.body);

      print(jsonData);

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
                body: "Bookmark Added Successfully",
                isOkButton: true,
                okButtonText: "OK",
                okButtonClick: () {
                  Get.back();
                },
                isCancelButton: false)
            .show();
      }
    } else {
      loginNotifyDialog();
    }
  }

  Future<List<BookmarkModel>> getBookmarks() async {
    var jsonData;

    var response = await http.get(Uri.parse(
        rootUrl + "api/bookmark/get-by-user/${LocalData().getUserId()}"));
    var jsonOriginal = json.decode(response.body);

    jsonData = jsonOriginal['bookmark'];

    List<BookmarkModel> value = jsonData.map<BookmarkModel>((json) {
      return BookmarkModel.fromJson(json);
    }).toList();

    return value;
  }

  Future<bool> deleteBookmark(String? id) async {
    Loading().show(context!);

    // Map<String, dynamic> data = {
    //   'title': title,
    //   'siteUrl': url,
    //   'userId': LocalData().getUserId()
    // };
    var jsonData;
    var response = await http.delete(
        Uri.parse(rootUrl + "api/bookmark/delete-one/$id"),
        headers: {'Accept': 'application/json'},
        encoding: Encoding.getByName("utf-8"));

    jsonData = json.decode(response.body);

    print(jsonData);

    Loading().dismiss();

    return true;
  }

  Future<bool> createWithdrawRequest(
      String? withdrawalMethodId, String? accountNo, String? amount) async {
    Loading().show(context!);

    Map<String, dynamic> data = {
      'withdrawalMethodId': withdrawalMethodId,
      'accountNo': accountNo,
      'amount': amount,
      'status': "",
      'note': "",
      'userId': LocalData().getUserId()
    };
    var jsonData;
    var response = await http.post(
        Uri.parse(rootUrl + "api/withdrawal-request/create"),
        headers: {'Accept': 'application/json'},
        body: data,
        encoding: Encoding.getByName("utf-8"));

    print(data);

    jsonData = json.decode(response.body);

    print(jsonData);

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
              body: "Withdraw Request Added Successfully",
              isOkButton: true,
              okButtonText: "OK",
              okButtonClick: () {
                Get.back();
              },
              isCancelButton: false)
          .show();
    }
    return true;
  }

  Future<List<WithdrawalRequestModel>> getWithdrawalRequests() async {
    var jsonData;

    var response = await http.get(Uri.parse(rootUrl +
        "api/withdrawal-request/get-by-user/${LocalData().getUserId()}"));
    var jsonOriginal = json.decode(response.body);

    jsonData = jsonOriginal['withdrawalRequest'];

    List<WithdrawalRequestModel> value =
        jsonData.map<WithdrawalRequestModel>((json) {
      return WithdrawalRequestModel.fromJson(json);
    }).toList();

    return value;
  }
}
