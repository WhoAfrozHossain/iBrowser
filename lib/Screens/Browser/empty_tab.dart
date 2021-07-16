import 'dart:async';

import 'package:best_browser/Controller/Controller.dart';
import 'package:best_browser/PoJo/NewsModel.dart';
import 'package:best_browser/Screens/Browser/models/browser_model.dart';
import 'package:best_browser/Screens/Browser/models/webview_model.dart';
import 'package:best_browser/Screens/Browser/webview_tab.dart';
import 'package:best_browser/Service/Network.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EmptyTab extends StatefulWidget {
  EmptyTab({Key? key}) : super(key: key);

  @override
  _EmptyTabState createState() => _EmptyTabState();
}

class _EmptyTabState extends State<EmptyTab> {
  Controller myController = Get.put(Controller());

  late Timer _timer;

  @override
  void initState() {
    _timer = Timer.periodic(Duration.zero, (timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        return SizedBox(
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

    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(
          url: Uri.parse(value!.contains(".")
              ? value
              : settings.searchEngine.searchUrl + value)),
    ));
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
                                fontSize: 18, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          child: Text(
                            item.description!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.justify,
                          ),
                        )
                      ],
                    )),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    child: Text(
                      item.collectFrom!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  DateFormat.yMMMd()
                      .add_jm()
                      .format(DateTime.parse(item.createdAt!)),
                  style: TextStyle(fontSize: 12),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
