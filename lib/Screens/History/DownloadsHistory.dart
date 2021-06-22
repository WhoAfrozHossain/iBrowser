import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class DownloadsHistory extends StatefulWidget {
  @override
  _DownloadsHistoryState createState() => _DownloadsHistoryState();
}

class _DownloadsHistoryState extends State<DownloadsHistory> {
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
          'Downloads',
        ),
        actions: [
          IconButton(
              icon: Icon(
                CupertinoIcons.search_circle,
                size: 30,
              ),
              onPressed: () {})
        ],
        backgroundColor: UIColors.primaryDarkColor,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(10),
            child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 20,
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 5,
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color: UIColors.backgroundColor,
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Image.asset('assets/images/doc_icon.png'),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "FileName",
                                style: TextStyle(
                                    color: UIColors.blackColor,
                                    fontSize: 12.sp),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "150 mb",
                                    style: TextStyle(
                                        color: UIColors.blackColor,
                                        fontSize: 10.sp),
                                  ),
                                  Text(
                                    "05 Jan 2021",
                                    style: TextStyle(
                                        color: UIColors.blackColor,
                                        fontSize: 10.sp),
                                  ),
                                ],
                              ),
                              Text(
                                "File Location",
                                style: TextStyle(
                                    color: UIColors.blackColor,
                                    fontSize: 10.sp),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(Icons.more_vert)
                      ],
                    ),
                  );
                })),
      ),
    );
  }
}
