import 'package:best_browser/PoJo/BookmarkModel.dart';
import 'package:best_browser/Service/Network.dart';
import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class Bookmarks extends StatefulWidget {
  @override
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  List<BookmarkModel>? bookmarks = [];

  @override
  void initState() {
    getBookmarks();
    super.initState();
  }

  getBookmarks() {
    Network().getBookmarks().then((value) {
      setState(() {
        bookmarks = value;
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
          'Bookmarks',
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
      body: SafeArea(
        child: bookmarks == null
            ? Center(child: CircularProgressIndicator())
            : bookmarks!.length == 0
                ? Center(child: Text("No bookmarks yet"))
                : SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(10),
                    child: ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: bookmarks!.length,
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
                                Icon(
                                  CupertinoIcons.link_circle,
                                  size: 30,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bookmarks![index].title!,
                                        style: TextStyle(
                                            color: UIColors.blackColor,
                                            fontSize: 12.sp),
                                      ),
                                      Text(
                                        bookmarks![index].siteUrl!,
                                        style: TextStyle(
                                            color: UIColors.blackColor,
                                            fontSize: 10.sp),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          DateFormat.yMMMEd().format(
                                              DateTime.parse(bookmarks![index]
                                                  .updatedAt!)),
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
                                    Network()
                                        .deleteBookmark(bookmarks![index].sId)
                                        .then((value) {
                                      getBookmarks();
                                    });
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
