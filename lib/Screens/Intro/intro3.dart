import 'package:best_browser/Service/LocalData.dart';
import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class IntroPageThird extends StatefulWidget {
  @override
  _IntroPageThirdState createState() => _IntroPageThirdState();
}

class _IntroPageThirdState extends State<IntroPageThird> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.blackColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FractionallySizedBox(
                widthFactor: .9,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Align(
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          'assets/images/intro_adblock_2.png',
                          height: 150,
                        )),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          'assets/images/intro_adblock_1.png',
                        ))
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Your very own",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize: 20.sp)),
                      Text("Adblocker System",
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
                  ),
                  SizedBox(
                    height: 50,
                  ),
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
                                border:
                                    Border.all(color: Colors.white, width: 3)),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3)),
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
                        ],
                      )),
                      // TextButton(
                      //     onPressed: () {},
                      //     child: Text(
                      //       "SKIP",
                      //       style: TextStyle(color: Colors.white),
                      //     )),
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  UIColors.buttonColor),
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.all(10)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(200.0),
                              ))),
                          onPressed: () {
                            LocalData().viewedIntro();
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
            )
          ],
        ),
      ),
    );
  }
}
