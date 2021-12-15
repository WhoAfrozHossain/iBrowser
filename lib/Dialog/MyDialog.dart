import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:iBrowser/Utils/UI_Colors.dart';
import 'package:sizer/sizer.dart';

class CustomDialog {
  String? title;
  String? body;
  bool isOkButton;
  String? okButtonText;
  VoidCallback? okButtonClick;
  bool isCancelButton;
  String? cancelButtonText;
  VoidCallback? cancelButtonClick;

  CustomDialog(
      {this.title,
      this.body,
      required this.isOkButton,
      this.okButtonText,
      this.okButtonClick,
      required this.isCancelButton,
      this.cancelButtonText,
      this.cancelButtonClick}) {
    dataValidator();
  }

  void dataValidator() {
    if (title == null) {
      title = "Title";
    }
    if (body == null) {
      body = "Body shows here";
    }
    if (okButtonText == null) {
      okButtonText = "OK";
    }
    if (okButtonClick == null) {
      okButtonClick = () {
        Get.back();
      };
    }
    if (cancelButtonText == null) {
      cancelButtonText = "Cancel";
    }
    if (cancelButtonClick == null) {
      cancelButtonClick = () {
        Get.back();
      };
    }
  }

  void show() {
    Get.defaultDialog(
      title: title!,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Text(
              body!,
              style: TextStyle(color: Colors.black, fontSize: 15.sp),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCancelButton)
                Container(
                  height: 35,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: UIColors.primaryColor)),
                  child: TextButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.all(5.0)),
                        overlayColor: MaterialStateProperty.all(Colors.grey)),
                    onPressed: cancelButtonClick,
                    child: Text(
                      cancelButtonText!,
                      style: TextStyle(fontSize: 15.sp, color: Colors.black),
                    ),
                  ),
                ),
              if (isCancelButton && isOkButton)
                SizedBox(
                  width: 5,
                ),
              if (isOkButton)
                Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: UIColors.primaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.all(5.0)),
                    ),
                    onPressed: okButtonClick,
                    child: Text(
                      okButtonText!,
                      style: TextStyle(fontSize: 15.sp, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
