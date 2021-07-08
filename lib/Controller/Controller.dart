import 'dart:async';
import 'dart:math';

import 'package:best_browser/PoJo/NewsModel.dart';
import 'package:best_browser/PoJo/OthersSitesModel.dart';
import 'package:best_browser/PoJo/SpecialSitesModel.dart';
import 'package:best_browser/Service/Network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Controller extends GetxController {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController submitController = new TextEditingController();

  List<NewsModel> news = [];
  List<SpecialSitesModel> specialSites = [];
  OthersSitesModel? otherSites;

  var rng = new Random();
  late int num1, num2;

  bool isData = true;
  bool isLoading = false;

  bool? isSpecialSite;
  String? specialSiteUrl;

  Timer? _revenueTimer;

  refreshAmount() {
    update();
  }

  clear() {
    news.clear();
    specialSites.clear();
    otherSites = null;
    isSpecialSite = null;
    specialSiteUrl = null;
    _revenueTimer!.cancel();

    update();
  }

  checkSite(String url) {
    if (isSpecialSite == null) {
      setSite(url);
    } else if (isSpecialSite!) {
      if (!url.contains(specialSiteUrl!)) {
        setSite(url);
      }
    }
  }

  setSite(String url) {
    isSpecialSite = null;
    specialSiteUrl = null;

    for (int i = 0; i < specialSites.length; i++) {
      print("call loop");
      if (url.contains(specialSites[i].url!)) {
        isSpecialSite = true;
        specialSiteUrl = specialSites[i].url!;

        print(isSpecialSite);
        print(specialSiteUrl);

        setTimer(specialSites[i].minVisitingTime!, specialSites[i].sId!);
      }
    }

    if (specialSiteUrl == null) {
      print("call others");
      isSpecialSite = false;

      print(isSpecialSite);
      print(specialSiteUrl);
      setTimer(otherSites!.minVisitingTime!, otherSites!.sId!);
    }
  }

  setTimer(int minute, String siteId) {
    num1 = rng.nextInt(9);
    num2 = rng.nextInt(9);

    print("startTime $minute");

    _revenueTimer = Timer(Duration(minutes: minute), () {
      Get.defaultDialog(
          title: "Site Visiting Revenue",
          barrierDismissible: false,
          content: Form(
            key: _formKey,
            child: Column(
              children: [
                Text("$num1 + $num2 = ?"),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black)),
                  child: TextFormField(
                    controller: submitController,
                    validator: (value) {
                      if (value!.length == 0) {
                        return 'Please enter value';
                      } else if (int.parse(value) != (num1 + num2)) {
                        return 'Please enter correct value';
                      } else
                        return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: "Sum Value"),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Get.back();
                    Network().addSiteRevenue(siteId);
                  }
                },
                child: Text("Submit"))
          ]);
    });
  }

  getFavoriteSites() async {
    await Network().getSpecialSites().then((value) {
      specialSites = value;

      update();
    });
  }

  getOtherSiteRevenue() async {
    await Network().getOtherSites().then((value) {
      otherSites = value;

      update();
    });
  }

  Future<bool> getNews() async {
    if (!isLoading) {
      if (isData) {
        isLoading = true;
        update();
        await Network().getNews(news.length).then((value) {
          if (value.length < 20) {
            isData = false;
          }
          news = value;
          isLoading = false;

          update();
        });
      }
    }
    return true;
  }
}
