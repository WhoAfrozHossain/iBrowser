import 'dart:math';

import 'package:app_review/app_review.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart' as fb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iBrowser/PoJo/UserModel.dart';
import 'package:iBrowser/Service/Network.dart';
import 'package:iBrowser/Utils/UI_Colors.dart';
import 'package:iBrowser/Utils/ad_network.dart';
import 'package:share/share.dart';
import 'package:sizer/sizer.dart';
import 'package:unity_ads_plugin/unity_ads.dart';

class EarningDashboard extends StatefulWidget {
  @override
  _EarningDashboardState createState() => _EarningDashboardState();
}

class _EarningDashboardState extends State<EarningDashboard> {
  static final AdRequest request = AdRequest();

  UserModel? userData;

  String? appID = "";
  String? output = "";
  String? appVersion = "";

  late BannerAd _bannerAd;

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  @override
  void initState() {
    getUserData();

    fb.FacebookAudienceNetwork.init(
      testingId: testAd ? "37b1da9d-b48c-4103-a393-2e095e734bd6" : null,
    );

    UnityAds.init(
      gameId: unityAppId,
      testMode: testAd,
      listener: (state, args) => print('Init Listener: $state => $args'),
    );

    _bannerAd = BannerAd(
      adUnitId: testAd ? BannerAd.testAdUnitId : admobBannerId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
        onAdImpression: (Ad ad) => print('$BannerAd onAdImpression.'),
      ),
    );

    _bannerAd.load();

    _createRewardedAd();

    AppReview.getPackageInfo().then((onValue) {
      setState(() {
        appID = onValue!.packageName;
        appVersion = onValue.version;
      });
    });

    super.initState();
  }

  getUserData() {
    Network().getUserData().then((value) {
      setState(() {
        userData = value;
      });
    });
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: RewardedAd.testAdUnitId,
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts <= maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (RewardedAd ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type}');
    });
    _rewardedAd = null;
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdWidget adWidget = AdWidget(ad: _bannerAd);
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
        // actions: [
        //   Center(
        //       child: Container(
        //           padding: EdgeInsets.only(right: 20),
        //           child: Text(
        //             "350 ${new String.fromCharCodes(new Runes('\u0024'))}",
        //             style: TextStyle(fontSize: 18),
        //           )))
        // ],
        backgroundColor: UIColors.primaryDarkColor,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: userData == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
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
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10.sp),
                                ),
                                Text(
                                  userData!.walletAmount.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30.sp),
                                ),
                                // Text(
                                //   "Update in every 24 hours",
                                //   style: TextStyle(
                                //       color: Colors.white, fontSize: 11.sp),
                                // )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
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
                                Get.toNamed('/withdraw')!
                                    .then((value) => getUserData());
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
                    Container(
                      alignment: Alignment.center,
                      child: adWidget,
                      width: _bannerAd.size.width.toDouble(),
                      height: _bannerAd.size.height.toDouble(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        Get.toNamed('/ads/browse')!.then((value) {
                          getUserData();
                        });
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
                      onTap: () {
                        var rng = new Random();

                        int num = rng.nextInt(100);

                        if (num % 3 == 0) {
                          _showRewardedAd();
                        } else if (num % 3 == 1) {
                          UnityAds.showVideoAd(
                            placementId: unityRewardId,
                            listener: (state, args) => print(
                                'Rewarded Video Listener: $state => $args'),
                          );
                        } else if (num % 3 == 2) {
                          fb.FacebookRewardedVideoAd.loadRewardedVideoAd(
                            placementId: facebookRewardId,
                            listener: (result, value) {
                              print(value);
                            },
                          );
                        }
                      },
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
                                    "Browse More Ads",
                                    style: TextStyle(
                                        color: UIColors.blackColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp),
                                  ),
                                  Text(
                                    "Browse more ads get rewards.",
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
                    Center(
                      child: UnityBannerAd(
                        placementId: unityBannerId,
                        listener: (state, args) {
                          print('Banner Listener: $state => $args');
                        },
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
                              // Text(
                              //   "Details",
                              //   style:
                              //       TextStyle(color: UIColors.primaryDarkColor),
                              // )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 50,
                            child: Row(
                              children: [
                                // Expanded(
                                //     child: Row(
                                //   children: [
                                //     Image.asset(
                                //         'assets/images/dashboard_icon_07.png'),
                                //     SizedBox(
                                //       width: 5,
                                //     ),
                                //     Column(
                                //       mainAxisAlignment: MainAxisAlignment.center,
                                //       crossAxisAlignment:
                                //           CrossAxisAlignment.start,
                                //       children: [
                                //         Text(
                                //           "500 Coins",
                                //           style: TextStyle(
                                //               color: Colors.grey, fontSize: 8.sp),
                                //         ),
                                //         Text(
                                //           "Earned",
                                //           style: TextStyle(
                                //               color: Colors.grey, fontSize: 8.sp),
                                //         )
                                //       ],
                                //     )
                                //   ],
                                // )),
                                // SizedBox(
                                //   width: 10,
                                // ),
                                Expanded(
                                    child: Row(
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 1,
                                      child: Image.asset(
                                        'assets/images/dashboard_icon_08.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${userData!.totalMinuteServed} Min",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14.sp),
                                          ),
                                          Text(
                                            "Served",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12.sp),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: Row(
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 1,
                                      child: Image.asset(
                                        'assets/images/dashboard_icon_09.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${userData!.totalAdsViewed} Ads",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14.sp),
                                          ),
                                          Text(
                                            "Viewed",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12.sp),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        AppReview.storeListing.then((onValue) {
                          setState(() {
                            output = onValue;
                          });
                        });
                      },
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
                                    "Rate Our App",
                                    style: TextStyle(
                                        color: UIColors.blackColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp),
                                  ),
                                  Text(
                                    "Enjoying Fulldive? Leave us a amazing 5 star review.",
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
                    // Divider(),
                    // InkWell(
                    //   onTap: () {},
                    //   child: Container(
                    //     width: Get.width,
                    //     padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                    //     child: Row(
                    //       children: [
                    //         Image.asset(
                    //           'assets/images/dashboard_icon_05.png',
                    //           width: 50,
                    //           fit: BoxFit.fitWidth,
                    //         ),
                    //         SizedBox(
                    //           width: 10,
                    //         ),
                    //         Expanded(
                    //           child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.start,
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               Text(
                    //                 "Browse your favorite sites",
                    //                 style: TextStyle(
                    //                     color: UIColors.blackColor,
                    //                     fontWeight: FontWeight.bold,
                    //                     fontSize: 14.sp),
                    //               ),
                    //               Text(
                    //                 "Browse favorite websites and earn more! Get rewards for browsing activity.",
                    //                 style: TextStyle(
                    //                     color: UIColors.blackColor,
                    //                     fontWeight: FontWeight.normal,
                    //                     fontSize: 12.sp),
                    //               )
                    //             ],
                    //           ),
                    //         ),
                    //         Icon(
                    //           CupertinoIcons.forward,
                    //           color: UIColors.primaryDarkColor,
                    //           size: 30,
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Divider(),
                    InkWell(
                      onTap: () {
                        Share.share(
                            "https://play.google.com/store/apps/details?id=$appID",
                            subject: "iBrowser");
                      },
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
                                    "Share in Facebook",
                                    style: TextStyle(
                                        color: UIColors.blackColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp),
                                  ),
                                  Text(
                                    "Post about the app on Facebook.",
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
                    Container(
                      alignment: Alignment(0.5, 1),
                      child: fb.FacebookBannerAd(
                        placementId: testAd
                            ? "IMG_16_9_APP_INSTALL#$facebookBannerId"
                            : facebookBannerId,
                        bannerSize: fb.BannerSize.STANDARD,
                        listener: (result, value) {
                          print(value);
                        },
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
