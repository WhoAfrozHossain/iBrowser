import 'package:best_browser/Controller/Controller.dart';
import 'package:best_browser/PoJo/NewsModel.dart';
import 'package:best_browser/Screens/Browser/models/browser_model.dart';
import 'package:best_browser/Screens/Browser/models/webview_model.dart';
import 'package:best_browser/Screens/Browser/webview_tab.dart';
import 'package:best_browser/Service/Network.dart';
import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
                        height: 15,
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
