import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class Browser extends StatefulWidget {
  @override
  _BrowserState createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  TextEditingController _searchController = TextEditingController();

  OutlineInputBorder outlineBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: const BorderRadius.all(
      const Radius.circular(50.0),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Container(
          margin: EdgeInsets.only(left: 10),
          height: 40,
          child: TextField(
            keyboardType: TextInputType.url,
            autofocus: false,
            controller: _searchController,
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10.0),
              filled: true,
              fillColor: Colors.white,
              border: outlineBorder,
              focusedBorder: outlineBorder,
              enabledBorder: outlineBorder,
              prefixIcon: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/1200px-Google_%22G%22_Logo.svg.png',
                height: 20,
              ),
              suffixIcon: Icon(
                Icons.search,
                color: Colors.grey,
              ),
              hintText: "Search or type web address",
              hintStyle: TextStyle(color: Colors.black54, fontSize: 16.0),
            ),
            style: TextStyle(color: Colors.black, fontSize: 16.0),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          )
        ],
        backgroundColor: UIColors.primaryDarkColor,
        elevation: 0,
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        child: Container(
          height: 60,
          child: new BottomAppBar(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 2,
                  child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: UIColors.primaryDarkColor,
                        size: 30,
                      )),
                ),
                Expanded(
                  flex: 2,
                  child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: UIColors.primaryColor,
                        size: 30,
                      )),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.3),
                        borderRadius: BorderRadius.circular(20)),
                    child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          CupertinoIcons.home,
                          color: Colors.grey,
                          size: 25,
                        )),
                  ),
                ),
                Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: UIColors.primaryDarkColor, width: 2),
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(child: Text("3")),
                      ),
                    )),
                Expanded(
                  flex: 2,
                  child: IconButton(
                      onPressed: () {
                        Get.bottomSheet(openBottomSheet(),
                            backgroundColor: Colors.white,
                            clipBehavior: Clip.antiAlias);
                      },
                      icon: Icon(
                        Icons.dashboard_outlined,
                        color: UIColors.primaryDarkColor,
                        size: 30,
                      )),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: UIColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Text(
            "Browse here",
            style: TextStyle(color: UIColors.primaryDarkColor, fontSize: 35.sp),
          ),
        ),
      ),
    );
  }

  openBottomSheet() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.person_alt_circle,
                  size: 60,
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
                        "Not Signed in",
                        style: TextStyle(
                            color: UIColors.blackColor, fontSize: 12.sp),
                      ),
                      Text(
                        "Sign in to sync your browsing data and coin.",
                        style: TextStyle(
                            color: UIColors.blackColor, fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 35,
                  color: UIColors.primaryDarkColor,
                )
              ],
            )),
        Container(
          width: Get.width,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(.3), width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Privacy Report",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "Details",
                    style: TextStyle(color: UIColors.primaryDarkColor),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                      child: Row(
                    children: [
                      Image.asset('assets/images/dashboard_icon_07.png'),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "500 Ads",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 9.sp),
                          ),
                          Text(
                            "Blocked",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 9.sp),
                          )
                        ],
                      )
                    ],
                  )),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Row(
                    children: [
                      Image.asset('assets/images/dashboard_icon_08.png'),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "50.00 Mb",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 9.sp),
                          ),
                          Text(
                            "Saved",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 9.sp),
                          )
                        ],
                      )
                    ],
                  )),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Row(
                    children: [
                      Image.asset('assets/images/dashboard_icon_09.png'),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "50 Min",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 9.sp),
                          ),
                          Text(
                            "Served",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 9.sp),
                          )
                        ],
                      )
                    ],
                  )),
                ],
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: GridView.count(
            physics: BouncingScrollPhysics(),
            crossAxisCount: 4,
            childAspectRatio: .9,
            shrinkWrap: true,
            children: [
              TextButton(
                  onPressed: () {
                    // Get.offAndToNamed('/pathology/information');
                  },
                  child: bottomMenuItem("Bookmarks", Icons.bookmarks)),
              TextButton(
                  onPressed: () {
                    // Get.offAndToNamed('/pathology/information');
                  },
                  child: bottomMenuItem(
                      "Desktop Mode", Icons.desktop_mac_rounded)),
              TextButton(
                  onPressed: () {
                    Get.offAndToNamed('/earning/dashboard');
                  },
                  child:
                      bottomMenuItem("Earnings", CupertinoIcons.money_dollar)),
              TextButton(
                  onPressed: () {
                    Get.offAndToNamed('/history/download');
                  },
                  child: bottomMenuItem(
                      "Downloads", CupertinoIcons.cloud_download_fill)),
              TextButton(
                  onPressed: () {
                    // Get.offAndToNamed('/history/download');
                  },
                  child: bottomMenuItem("Share", Icons.share_outlined)),
              TextButton(
                  onPressed: () {
                    Get.offAndToNamed('/history/browsing');
                  },
                  child: bottomMenuItem("History", Icons.history)),
              TextButton(
                  onPressed: () {
                    Get.offAndToNamed('/setting/account');
                  },
                  child: bottomMenuItem(
                      "Account Settngs", Icons.settings_rounded)),
              TextButton(
                  onPressed: () {
                    // Get.offAndToNamed('/setting/account');
                  },
                  child: bottomMenuItem("Settngs", CupertinoIcons.settings))
            ],
          ),
        ),
        Container(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: UIColors.primaryDarkColor,
                      size: 50,
                    )),
              ),
              Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        Icons.logout,
                        color: UIColors.primaryDarkColor,
                        size: 20,
                      )))
            ],
          ),
        )
      ],
    );
  }

  bottomMenuItem(String title, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                color: UIColors.primaryDarkColor.withOpacity(.1),
                borderRadius: BorderRadius.circular(200)),
            child: Icon(icon, color: UIColors.primaryDarkColor)),
        SizedBox(height: 3),
        Text(
          title,
          style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.normal,
              color: UIColors.blackColor),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
