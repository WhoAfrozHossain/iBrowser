import 'dart:async';

import 'package:best_browser/Service/LocalData.dart';
import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sizer/sizer.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final localData = GetStorage();

  late Timer timer;
  double opacity = 0.0;

  bool isLogin = false;
  bool haveData = false;

  String url = '';

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (opacity != 1.0) {
        setState(() {
          opacity += 0.5;
        });
      }
    });

    new Future.delayed(const Duration(seconds: 3), () async {
      LocalData().checkLocalData();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: new BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/splash_shape.png"),
              fit: BoxFit.fitWidth),
          gradient: new LinearGradient(
              colors: [
                UIColors.primaryDarkColor,
                UIColors.primaryColor,
              ],
              begin: const FractionalOffset(0.5, -1.0),
              end: const FractionalOffset(-0.5, 1.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: Center(
          child: Container(
            width: Get.width,
            child: AnimatedOpacity(
              opacity: opacity,
              duration: Duration(seconds: 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 150,
                  ),
                  Image.asset(
                    "assets/images/icon.png",
                    height: 100,
                  ),
                  Container(
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("iBrowser",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 50.sp)),
                        Text("Best Android Browser with All Features",
                            style: TextStyle(
                                color: Colors.white, fontSize: 12.sp)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
