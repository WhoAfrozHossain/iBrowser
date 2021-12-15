import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iBrowser/Utils/UI_Colors.dart';
import 'package:sizer/sizer.dart';

loginNotifyDialog() {
  Get.defaultDialog(
      title: "Sorry",
      content: Container(
        width: Get.width,
        child: Text(
          "Please login first",
          style: TextStyle(color: UIColors.blackColor, fontSize: 12.sp),
          textAlign: TextAlign.center,
        ),
      ),
      actions: [
        Container(
          width: Get.width,
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Get.offAndToNamed('/auth/login');
                  },
                  child: Text(
                    "Ok, Login",
                    style: TextStyle(color: UIColors.primaryColor),
                  ),
                ),
              )
            ],
          ),
        )
      ]);
}
