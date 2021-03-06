import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iBrowser/PoJo/UserModel.dart';

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
      // } else if (localData.read('login') == null || !localData.read('login')) {
      //   url = '/auth/start';
    } else if (localData.read('country') == null ||
        localData.read('city') == null) {
      url = '/setup/city';
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
    // Get.toNamed('/auth/register');
    checkLocalData();
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

  Future<void> logOut() async {
    localData.write('login', false);
    localData.write('userId', '');
    checkLocalData();
  }

  void writeDefaultSearchEngine(int index) {
    localData.write('searchEngine', index);
  }

  int readDefaultSearchEngine() {
    String? value = localData.read('searchEngine');
    return value == null ? 0 : int.parse(value);
  }
}
