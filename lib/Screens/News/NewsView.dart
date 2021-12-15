import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart' as fb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iBrowser/Controller/Controller.dart';
import 'package:iBrowser/PoJo/NewsModel.dart';
import 'package:iBrowser/Screens/Browser/models/browser_model.dart';
import 'package:iBrowser/Screens/Browser/models/webview_model.dart';
import 'package:iBrowser/Screens/Browser/webview_tab.dart';
import 'package:iBrowser/Service/Network.dart';
import 'package:iBrowser/Utils/UI_Colors.dart';
import 'package:iBrowser/Utils/ad_network.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unity_ads_plugin/unity_ads.dart';

class NewsView extends StatefulWidget {
  const NewsView({Key? key}) : super(key: key);

  @override
  _NewsViewState createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  Controller myController = Get.put(Controller());

  late NewsModel item;

  @override
  void initState() {
    item = myController.selectedNews!;
    super.initState();

    fb.FacebookAudienceNetwork.init(
      testingId: testAd ? "37b1da9d-b48c-4103-a393-2e095e734bd6" : null,
    );

    UnityAds.init(
      gameId: unityAppId,
      testMode: testAd,
      listener: (state, args) => print('Init Listener: $state => $args'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: UIColors.blackColor,
          ),
        ),
        title: Container(
          width: Get.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.topic!,
                style: TextStyle(
                  color: UIColors.blackColor,
                  fontSize: 15,
                ),
              ),
              Text(
                DateFormat.yMMMd().format(DateTime.parse(item.updatedAt!)),
                style: TextStyle(
                  color: UIColors.blackColor,
                  fontSize: 13,
                ),
              )
            ],
          ),
        ),
        elevation: 0,
        backgroundColor: UIColors.backgroundColor,
      ),
      backgroundColor: UIColors.backgroundColor,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        width: Get.width,
                        child: Text(
                          item.title!,
                          style: TextStyle(
                            color: UIColors.primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: UnityBannerAd(
                          placementId: unityBannerId,
                          listener: (state, args) {
                            print('Banner Listener: $state => $args');
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: Get.width,
                        child: CachedNetworkImage(
                          imageUrl: Network().rootUrl + "images/" + item.image!,
                          placeholder: (context, url) =>
                              CupertinoActivityIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: Get.width,
                        child: Text(
                          item.description!,
                          style: TextStyle(
                            color: UIColors.blackColor,
                            fontSize: 17,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
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
              SizedBox(
                height: 10,
              ),
              Container(
                width: Get.width,
                child: TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(UIColors.buttonColor),
                        padding: MaterialStateProperty.all(EdgeInsets.all(15)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(200.0),
                        ))),
                    onPressed: () {
                      Get.back();
                      openNewTab(item.collectFrom);
                    },
                    child: Text(
                      "View Full News",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openNewTab(String? value) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();

    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(
          url: Uri.parse(value!.contains(".")
              ? value
              : settings.searchEngine.searchUrl + value)),
    ));
  }
}
