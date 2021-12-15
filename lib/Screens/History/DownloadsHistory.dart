import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:iBrowser/Utils/UI_Colors.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class DownloadsHistory extends StatefulWidget {
  @override
  _DownloadsHistoryState createState() => _DownloadsHistoryState();
}

class _DownloadsHistoryState extends State<DownloadsHistory> {
  List<DownloadTask> tasks = [];

  @override
  void initState() {
    getDownloads();
    super.initState();
  }

  getDownloads() async {
    await FlutterDownloader.loadTasks().then((value) {
      setState(() {
        tasks = value!;
        tasks.sort((a, b) => b.timeCreated.compareTo(a.timeCreated));
      });
    });
    print(tasks);
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
          'Downloads',
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
        child: tasks.length == 0
            ? Center(child: Text("No files downloaded yet"))
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(10),
                child: ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 5,
                      );
                    },
                    itemBuilder: (BuildContext context, int index) {
                      var path = tasks[index].savedDir.split('/');
                      String downloadPath = "";
                      for (int i = 4; i < path.length; i++) {
                        downloadPath += "/" + path[i];
                      }
                      return InkWell(
                        onTap: () {
                          FlutterDownloader.open(taskId: tasks[index].taskId);
                        },
                        child: Container(
                          color: UIColors.backgroundColor,
                          padding: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              Image.asset('assets/images/doc_icon.png'),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tasks[index].filename!,
                                      style: TextStyle(
                                          color: UIColors.blackColor,
                                          fontSize: 12.sp),
                                    ),
                                    Text(
                                      downloadPath,
                                      style: TextStyle(
                                          color: UIColors.blackColor,
                                          fontSize: 10.sp),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(),
                                        // Text(
                                        //   "150 mb",
                                        //   style: TextStyle(
                                        //       color: UIColors.blackColor,
                                        //       fontSize: 10.sp),
                                        // ),
                                        Text(
                                          DateFormat.yMMMd().format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  tasks[index].timeCreated)),
                                          style: TextStyle(
                                              color: UIColors.blackColor,
                                              fontSize: 10.sp),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              IconButton(
                                  onPressed: () {
                                    FlutterDownloader.remove(
                                            taskId: tasks[index].taskId,
                                            shouldDeleteContent: false)
                                        .then((value) {
                                      getDownloads();
                                    });
                                  },
                                  icon: Icon(CupertinoIcons.clear_circled))
                            ],
                          ),
                        ),
                      );
                    })),
      ),
    );
  }
}
