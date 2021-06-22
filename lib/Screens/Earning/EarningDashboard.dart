import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class EarningDashboard extends StatefulWidget {
  @override
  _EarningDashboardState createState() => _EarningDashboardState();
}

class _EarningDashboardState extends State<EarningDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        titleSpacing: 0,
        title: Text(
          'Earning Dashboard',
        ),
        actions: [
          Center(
              child: Container(
                  padding: EdgeInsets.only(right: 20),
                  child: Text(
                    "350 ${new String.fromCharCodes(new Runes('\u0024'))}",
                    style: TextStyle(fontSize: 18),
                  )))
        ],
        backgroundColor: UIColors.primaryDarkColor,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Container(
                width: Get.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  gradient: new LinearGradient(
                      colors: [
                        UIColors.primaryColor,
                        UIColors.primaryDarkColor,
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/dashboard_icon_01.png',
                      width: 50,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Wallet Balance",
                            style:
                                TextStyle(color: Colors.white, fontSize: 10.sp),
                          ),
                          Text(
                            "500",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30.sp),
                          ),
                          Text(
                            "Update in every 24 hours",
                            style:
                                TextStyle(color: Colors.white, fontSize: 11.sp),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(UIColors.buttonColor),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(10)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(200.0),
                            ))),
                        onPressed: () {
                          Get.toNamed('/auth/start');
                        },
                        child: Text(
                          "Withdraw",
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  Get.toNamed('/ads/browse');
                },
                child: Container(
                  width: Get.width,
                  padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/dashboard_icon_02.png',
                        width: 50,
                        fit: BoxFit.fitWidth,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Browse Ads",
                              style: TextStyle(
                                  color: UIColors.blackColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp),
                            ),
                            Text(
                              "Browse more ads and earn more! Get rewards fairly for your browsing activity.",
                              style: TextStyle(
                                  color: UIColors.blackColor,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.sp),
                            )
                          ],
                        ),
                      ),
                      Icon(
                        CupertinoIcons.forward,
                        color: UIColors.primaryDarkColor,
                        size: 30,
                      )
                    ],
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () {},
                child: Container(
                  width: Get.width,
                  padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/dashboard_icon_03.png',
                        width: 50,
                        fit: BoxFit.fitWidth,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Browse your favorite sites",
                              style: TextStyle(
                                  color: UIColors.blackColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp),
                            ),
                            Text(
                              "Browse favorite websites and earn more! Get rewards for browsing activity.",
                              style: TextStyle(
                                  color: UIColors.blackColor,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.sp),
                            )
                          ],
                        ),
                      ),
                      Icon(
                        CupertinoIcons.forward,
                        color: UIColors.primaryDarkColor,
                        size: 30,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: Get.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: UIColors.backgroundColor.withOpacity(.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Earning Report",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          "Details",
                          style: TextStyle(color: UIColors.primaryDarkColor),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Row(
                          children: [
                            Image.asset('assets/images/dashboard_icon_07.png'),
                            SizedBox(
                              width: 5,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "500 Coins",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 8.sp),
                                ),
                                Text(
                                  "Earned",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 8.sp),
                                )
                              ],
                            )
                          ],
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Row(
                          children: [
                            Image.asset('assets/images/dashboard_icon_08.png'),
                            SizedBox(
                              width: 5,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "50 Min",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 8.sp),
                                ),
                                Text(
                                  "Served",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 8.sp),
                                )
                              ],
                            )
                          ],
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Row(
                          children: [
                            Image.asset('assets/images/dashboard_icon_09.png'),
                            SizedBox(
                              width: 5,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "50 Ads",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 8.sp),
                                ),
                                Text(
                                  "Viewed",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 8.sp),
                                )
                              ],
                            )
                          ],
                        )),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  width: Get.width,
                  padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/dashboard_icon_04.png',
                        width: 50,
                        fit: BoxFit.fitWidth,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Browse your favorite sites",
                              style: TextStyle(
                                  color: UIColors.blackColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp),
                            ),
                            Text(
                              "Browse favorite websites and earn more! Get rewards for browsing activity.",
                              style: TextStyle(
                                  color: UIColors.blackColor,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.sp),
                            )
                          ],
                        ),
                      ),
                      Icon(
                        CupertinoIcons.forward,
                        color: UIColors.primaryDarkColor,
                        size: 30,
                      )
                    ],
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () {},
                child: Container(
                  width: Get.width,
                  padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/dashboard_icon_05.png',
                        width: 50,
                        fit: BoxFit.fitWidth,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Browse your favorite sites",
                              style: TextStyle(
                                  color: UIColors.blackColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp),
                            ),
                            Text(
                              "Browse favorite websites and earn more! Get rewards for browsing activity.",
                              style: TextStyle(
                                  color: UIColors.blackColor,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.sp),
                            )
                          ],
                        ),
                      ),
                      Icon(
                        CupertinoIcons.forward,
                        color: UIColors.primaryDarkColor,
                        size: 30,
                      )
                    ],
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () {},
                child: Container(
                  width: Get.width,
                  padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/dashboard_icon_06.png',
                        width: 50,
                        fit: BoxFit.fitWidth,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Browse your favorite sites",
                              style: TextStyle(
                                  color: UIColors.blackColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp),
                            ),
                            Text(
                              "Browse favorite websites and earn more! Get rewards for browsing activity.",
                              style: TextStyle(
                                  color: UIColors.blackColor,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.sp),
                            )
                          ],
                        ),
                      ),
                      Icon(
                        CupertinoIcons.forward,
                        color: UIColors.primaryDarkColor,
                        size: 30,
                      )
                    ],
                  ),
                ),
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
