import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class GettingStarted extends StatefulWidget {
  @override
  _GettingStartedState createState() => _GettingStartedState();
}

class _GettingStartedState extends State<GettingStarted> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.primaryColor,
      body: Container(
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Image.asset('assets/images/intro_shape.png'),
                Image.asset('assets/images/intro_image.png')
              ],
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Create a account to",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontSize: 17.sp)),
                        Text("Get access full Application",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 20.sp)),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "For one Thing they usually step all over the hedge and plants on the side of someone's House killing them.",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize: 12.sp),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )),
                    Container(
                      width: Get.width,
                      child: TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  UIColors.buttonColor),
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.all(15)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(200.0),
                              ))),
                          onPressed: () {
                            Get.toNamed('/auth/login');
                          },
                          child: Text(
                            "Get Started",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12.sp),
                          )),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an Account? ",
                          style:
                              TextStyle(color: Colors.white, fontSize: 11.sp),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed('/auth/register');
                          },
                          child: Text(
                            "Register Now",
                            style: TextStyle(
                                color: UIColors.buttonColor,
                                decoration: TextDecoration.underline,
                                fontSize: 11.sp),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
