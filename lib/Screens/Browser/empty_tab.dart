import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart' as fb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iBrowser/Controller/Controller.dart';
import 'package:iBrowser/PoJo/NewsModel.dart';
import 'package:iBrowser/Screens/Browser/app_bar/global_widget.dart';
import 'package:iBrowser/Screens/Browser/models/browser_model.dart';
import 'package:iBrowser/Screens/Browser/models/webview_model.dart';
import 'package:iBrowser/Service/Network.dart';
import 'package:iBrowser/Utils/ad_network.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unity_ads_plugin/unity_ads.dart';

class EmptyTab extends StatefulWidget {
  EmptyTab({Key? key}) : super(key: key);

  @override
  _EmptyTabState createState() => _EmptyTabState();
}

class _EmptyTabState extends State<EmptyTab> {
  Controller myController = Get.put(Controller());

  late Timer _timer;

  late BannerAd _bannerAd;

  @override
  void initState() {
    _timer = Timer.periodic(Duration.zero, (timer) {
      if (mounted) setState(() {});
    });
    super.initState();

    fb.FacebookAudienceNetwork.init();

    UnityAds.init(
      gameId: unityAppId,
      testMode: testAd,
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
  }

  @override
  void dispose() {
    _timer.cancel();
    _bannerAd.dispose();
    // _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdWidget adWidget = AdWidget(ad: _bannerAd);
    return Scaffold(
      backgroundColor: Colors.white,
      body: myController.news.length == 0 ||
              myController.specialSites.length == 0
          ? Center(
              child: CupertinoActivityIndicator(),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.maxScrollExtent ==
                    scrollInfo.metrics.pixels) {
                  myController.getNews();
                }
                return true;
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.all(10),
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: adWidget,
                      width: _bannerAd.size.width.toDouble(),
                      height: _bannerAd.size.height.toDouble(),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          childAspectRatio: .8,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5),
                      itemCount: myController.specialSites.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            openNewTab(myController.specialSites[index].url);
                          },
                          child: Container(
                              child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                  child: CachedNetworkImage(
                                    imageUrl: Network().rootUrl +
                                        "images/" +
                                        myController.specialSites[index].icon!,
                                    placeholder: (context, url) =>
                                        CupertinoActivityIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                              Text(
                                myController.specialSites[index].title!,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          )),
                        );
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        width: Get.width,
                        child: Text(
                          "Discover",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: myController.news.length,
                      separatorBuilder: (context, index) {
                        return index % 4 == 0
                            ? Container(
                                width: Get.width,
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: Center(
                                  child: UnityBannerAd(
                                    placementId: unityBannerId,
                                    // listener: (state, args) {
                                    //   print('Banner Listener: $state => $args');
                                    // },
                                  ),
                                ),
                              )
                            : index % 2 == 0
                                ? Container(
                                    width: Get.width,
                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
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
                                : SizedBox(
                                    height: 10,
                                  );
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return newsItem(myController.news[index]);
                      },
                    )
                  ],
                ),
              ),
            ),
    );
  }

  void openNewTab(String? value) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();

    var webViewModel = Provider.of<WebViewModel>(context, listen: false);
    var _webViewController = webViewModel.webViewController;

    var url = Uri.parse(value!.trim());

    // print(url.scheme);

    if (!value.contains(".")) {
      url = Uri.parse(settings.searchEngine.searchUrl + value);
    } else {
      if (!value.contains("www.") && !value.startsWith("http")) {
        value = "www." + value;
      }
      if (!value.startsWith("http")) {
        value = "https://" + value;
      }
    }
    url = Uri.parse(value);

    if (_webViewController != null) {
      _webViewController.loadUrl(urlRequest: URLRequest(url: url));
    } else {
      browserModel.closeTab(webViewModel.tabIndex!);
      addNewTab(context, url: url);
      webViewModel.url = url;
    }
  }

  newsItem(NewsModel item) {
    return InkWell(
      onTap: () {
        myController.selectedNews = item;
        Get.toNamed('/newsView');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.5),
              blurRadius: 4,
              offset: Offset(4, 4), // changes position of shadow
            ),
          ],
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: Network().rootUrl + "images/" + item.image!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CupertinoActivityIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: Get.width,
                          child: Text(
                            item.title!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          child: Text(
                            item.description!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            DateFormat.yMMMd()
                                .add_jm()
                                .format(DateTime.parse(item.createdAt!)),
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                      ],
                    )),
              ],
            ),
            // SizedBox(
            //   height: 5,
            // ),
            // Row(
            //   children: [
            //     Expanded(
            //       child: Container(
            //           child: Text(
            //             item.collectFrom!,
            //             overflow: TextOverflow.ellipsis,
            //             style: TextStyle(fontSize: 12),
            //             textAlign: TextAlign.left,
            //           ),
            //           ),
            //     ),
            //     SizedBox(
            //       width: 10,
            //     ),
            //     Text(
            //       DateFormat.yMMMd()
            //           .add_jm()
            //           .format(DateTime.parse(item.createdAt!)),
            //       style: TextStyle(fontSize: 12),
            //     ),
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}
