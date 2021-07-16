import 'package:best_browser/PoJo/HistoryModel.dart';
import 'package:best_browser/Service/SQFlite/DBQueries.dart';
import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class BrowsingHistory extends StatefulWidget {
  @override
  _BrowsingHistoryState createState() => _BrowsingHistoryState();
}

class _BrowsingHistoryState extends State<BrowsingHistory> {
  List<HistoryModel>? histories = [];

  @override
  void initState() {
    getHistory();
    super.initState();
  }

  getHistory() {
    DBQueries().getHistory().then((value) {
      setState(() {
        histories = value;
      });
    });
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
          'History',
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
        child: histories == null
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(10),
                child: ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: histories!.length,
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
                            histories![index].favicon != null
                                ? Container(
                                    height: 30,
                                    width: 30,
                                    child: Image.network(
                                        histories![index].favicon!),
                                  )
                                : Icon(
                                    CupertinoIcons.link_circle,
                                    size: 30,
                                  ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    histories![index].title!,
                                    style: TextStyle(
                                        color: UIColors.blackColor,
                                        fontSize: 12.sp),
                                  ),
                                  Text(
                                    histories![index].url!,
                                    style: TextStyle(
                                        color: UIColors.blackColor,
                                        fontSize: 10.sp),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      DateFormat.yMMMEd().format(DateTime.parse(
                                          histories![index].date!)),
                                      style: TextStyle(
                                          color: UIColors.blackColor,
                                          fontSize: 10.sp),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            IconButton(
                              icon: Icon(CupertinoIcons.clear_circled),
                              onPressed: () {
                                DBQueries().deleteHistory(
                                    histories![index].id.toString());
                              },
                            )
                          ],
                        ),
                      );
                    })),
      ),
    );
  }
}
