import 'package:facebook_audience_network/facebook_audience_network.dart' as fb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iBrowser/PoJo/AdsModel.dart';
import 'package:iBrowser/Service/Network.dart';
import 'package:iBrowser/Utils/UI_Colors.dart';
import 'package:iBrowser/Utils/ad_network.dart';
import 'package:sizer/sizer.dart';
import 'package:unity_ads_plugin/unity_ads.dart';

class AdsBrowsing extends StatefulWidget {
  @override
  _AdsBrowsingState createState() => _AdsBrowsingState();
}

class _AdsBrowsingState extends State<AdsBrowsing> {
  List<AdsModel> ads = [];

  bool isData = true;
  bool isLoading = false;

  late BannerAd _bannerAd;

  void initState() {
    getData();

    fb.FacebookAudienceNetwork.init();

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

    super.initState();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<bool> getData() async {
    if (!isLoading) {
      if (isData) {
        setState(() {
          isLoading = true;
        });
        await Network().getAds(ads.length).then((value) {
          if (value.length < 20) {
            isData = false;
          }
          setState(() {
            ads = value;
            isLoading = false;
          });
        });
      }
    }
    return true;
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
          'Browse Ads',
        ),
        // actions: [
        //   IconButton(
        //       icon: Icon(
        //         CupertinoIcons.search_circle,
        //         size: 30,
        //       ),
        //       onPressed: () {})
        // ],
        backgroundColor: UIColors.primaryDarkColor,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.maxScrollExtent == scrollInfo.metrics.pixels) {
            getData();
          }
          return true;
        },
        child: SafeArea(
          child: ads.length == 0 && isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ads.length == 0
                  ? Center(
                      child: Text("No Ads Available"),
                    )
                  : SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: ads.length,
                              separatorBuilder: (context, index) {
                                return index % 9 == 0
                                    ? Container(
                                        alignment: Alignment.center,
                                        child: adWidget,
                                        width: _bannerAd.size.width.toDouble(),
                                        height:
                                            _bannerAd.size.height.toDouble(),
                                      )
                                    : index % 6 == 0
                                        ? Center(
                                            child: UnityBannerAd(
                                              placementId: unityBannerId,
                                              listener: (state, args) {
                                                print(
                                                    'Banner Listener: $state => $args');
                                              },
                                            ),
                                          )
                                        : index % 3 == 0
                                            ? Container(
                                                alignment: Alignment(0.5, 1),
                                                child: fb.FacebookBannerAd(
                                                  placementId: testAd
                                                      ? "IMG_16_9_APP_INSTALL#$facebookBannerId"
                                                      : facebookBannerId,
                                                  bannerSize:
                                                      fb.BannerSize.STANDARD,
                                                  listener: (result, value) {
                                                    print(value);
                                                  },
                                                ),
                                              )
                                            : SizedBox(
                                                height: 10,
                                              );
                              },
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    Get.defaultDialog(
                                        title: "Ad Instruction",
                                        barrierDismissible: false,
                                        content: Text(ads[index].instruction!),
                                        actions: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  width: Get.width,
                                                  child: TextButton(
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .grey),
                                                          padding:
                                                              MaterialStateProperty
                                                                  .all(EdgeInsets
                                                                      .all(15)),
                                                          shape: MaterialStateProperty.all<
                                                                  RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        200.0),
                                                          ))),
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      child: Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12.sp),
                                                      )),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  width: Get.width,
                                                  child: TextButton(
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(UIColors
                                                                      .buttonColor),
                                                          padding:
                                                              MaterialStateProperty
                                                                  .all(EdgeInsets
                                                                      .all(15)),
                                                          shape: MaterialStateProperty.all<
                                                                  RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        200.0),
                                                          ))),
                                                      onPressed: () {
                                                        print(ads[index].title);
                                                        print(ads[index]
                                                            .minVisitingTime);
                                                        print(
                                                            ads[index].revenue);
                                                        Get.offAndToNamed(
                                                            '/ads/visit/${ads[index].sId}');
                                                      },
                                                      child: Text(
                                                        "Continue",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12.sp),
                                                      )),
                                                ),
                                              )
                                            ],
                                          )
                                        ]);
                                  },
                                  child: Container(
                                    color: UIColors.backgroundColor,
                                    padding: EdgeInsets.all(5),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.language,
                                          color: UIColors.primaryDarkColor,
                                          size: 40,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ads[index].title!,
                                                style: TextStyle(
                                                    color: UIColors.blackColor,
                                                    fontSize: 13.sp),
                                              ),
                                              Text(
                                                "You need to visit this website and click on somewhere",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    color: UIColors.blackColor,
                                                    fontSize: 11.sp),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          CupertinoIcons.forward,
                                          color: UIColors.primaryDarkColor,
                                          size: 30,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          if (isLoading)
                            Center(
                              child: CircularProgressIndicator(),
                            )
                        ],
                      )),
        ),
      ),
    );
  }
}
