import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Loading {
  static Future? dialog;

  void show(BuildContext context) async {
    if (dialog == null) {
      dialog = viewDialog(context);
      await dialog;
    }
  }

  void dismiss() {
    if (dialog != null) {
      dialog = null;
      Get.back();
    }
  }

  Future viewDialog(BuildContext context) {
    return showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              backgroundColor: Colors.white.withOpacity(.9),
              insetPadding: EdgeInsets.symmetric(horizontal: 100),
              content: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    CircularProgressIndicator(),
                    Container(
                      child: Text(
                        "Loading...",
                        style: TextStyle(
                          color: UIColors.primaryColor,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }
}
