import 'package:best_browser/PoJo/UserModel.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocalData {
  final localData = GetStorage();

  void checkLocalData() {
    String url = '';
    if (localData.read('introView') == null || !localData.read('introView')) {
      url = '/intro/1';
      // } else if (localData.read('country') == null ||
      //     localData.read('city') == null) {
      //   url = '/setup/city';
    } else if (localData.read('interest') == null) {
      url = '/interest';
    } else if (localData.read('login') == null || !localData.read('login')) {
      url = '/auth/start';
    } else {
      url = '/browser';
    }
    Get.toNamed(url);
  }

  void viewedIntro() {
    localData.write('introView', true);
    checkLocalData();
  }

  void setInterests() {
    localData.write('interest', true);
    checkLocalData();
  }

  void saveCountryAndCity(String countryId, String cityId) {
    localData.write('country', countryId);
    localData.write('city', cityId);
    Get.toNamed('/auth/register');
  }

  void storeLoginUserData(var data, bool isSkip) {
    localData.write('login', true);

    if (!isSkip) {
      UserModel user = UserModel.fromJson(data);
      localData.write('userId', user.sId);
    }
    checkLocalData();
  }

  bool checkUserLogin() {
    if (localData.read('userId') != null)
      return true;
    else
      return false;
  }

  String getUserId() {
    return localData.read('userId');
  }

  void logOut() {
    localData.write('login', false);
    localData.write('userId', '');
    checkLocalData();
  }
}
