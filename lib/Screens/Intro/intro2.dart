import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class IntroPageSecond extends StatefulWidget {
  @override
  _IntroPageSecondState createState() => _IntroPageSecondState();
}

class _IntroPageSecondState extends State<IntroPageSecond> {
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
                        Text("Everything is in",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                fontSize: 20.sp)),
                        Text("One Application",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 25.sp)),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "It is a long extablished fact that a renderer will be distracted by the readable content of a page when looking at its layout.",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize: 13.sp),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )),
                    Row(
                      children: [
                        Expanded(
                            child: Row(
                          children: [
                            Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 3)),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 3)),
                            )
                          ],
                        )),
                        TextButton(
                            onPressed: () {},
                            child: Text(
                              "SKIP",
                              style: TextStyle(color: Colors.white),
                            )),
                        TextButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    UIColors.buttonColor),
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(10)),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(200.0),
                                ))),
                            onPressed: () {
                              Get.toNamed('/intro/3');
                            },
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 50,
                            ))
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
