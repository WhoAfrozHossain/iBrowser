import 'package:best_browser/PoJo/AdsModel.dart';
import 'package:best_browser/Service/Network.dart';
import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class AdsBrowsing extends StatefulWidget {
  @override
  _AdsBrowsingState createState() => _AdsBrowsingState();
}

class _AdsBrowsingState extends State<AdsBrowsing> {
  List<AdsModel> ads = [];

  bool isData = true;
  bool isLoading = false;

  void initState() {
    getData();

    super.initState();
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
                                return SizedBox(
                                  height: 5,
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
