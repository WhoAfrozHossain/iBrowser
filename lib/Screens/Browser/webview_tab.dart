import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:app_review/app_review.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart' as fb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:iBrowser/Controller/Controller.dart';
import 'package:iBrowser/Dialog/LoginDialog.dart';
import 'package:iBrowser/PoJo/UserModel.dart';
import 'package:iBrowser/Screens/Browser/empty_tab.dart';
import 'package:iBrowser/Screens/Browser/models/webview_model.dart';
import 'package:iBrowser/Screens/Browser/tab_popup_menu_actions.dart';
import 'package:iBrowser/Screens/Browser/util.dart';
import 'package:iBrowser/Service/LocalData.dart';
import 'package:iBrowser/Service/Network.dart';
import 'package:iBrowser/Service/SQFlite/DBQueries.dart';
import 'package:iBrowser/Utils/UI_Colors.dart';
import 'package:iBrowser/Utils/ad_network.dart';
import 'package:iBrowser/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:sizer/sizer.dart';

import 'javascript_console_result.dart';
import 'long_press_alert_dialog.dart';
import 'models/browser_model.dart';

class WebViewTab extends StatefulWidget {
  final GlobalKey<WebViewTabState> key;

  WebViewTab({required this.key, required this.webViewModel}) : super(key: key);

  final WebViewModel webViewModel;

  @override
  WebViewTabState createState() => WebViewTabState();
}

class WebViewTabState extends State<WebViewTab> with WidgetsBindingObserver {
  Controller myController = Get.put(Controller());

  InAppWebViewController? _webViewController;
  bool _isWindowClosed = false;

  TextEditingController _httpAuthUsernameController = TextEditingController();
  TextEditingController _httpAuthPasswordController = TextEditingController();

  GlobalKey tabInkWellKey = new GlobalKey();

  ReceivePort _port = ReceivePort();

  UserModel? userData;

  String? appID = "";
  String? output = "";
  String? appVersion = "";

  late WebViewModel webView;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();

    webView = widget.webViewModel;

    Network().getUserData().then((value) {
      setState(() {
        userData = value;
      });
    });

    AppReview.getPackageInfo().then((onValue) {
      setState(() {
        appID = onValue!.packageName;
        appVersion = onValue.version;
      });
    });

    fb.FacebookAudienceNetwork.init();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    _webViewController = null;
    widget.webViewModel.webViewController = null;

    _httpAuthUsernameController.dispose();
    _httpAuthPasswordController.dispose();

    WidgetsBinding.instance!.removeObserver(this);

    IsolateNameServer.removePortNameMapping('downloader_send_port');

    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_webViewController != null && Platform.isAndroid) {
      if (state == AppLifecycleState.paused) {
        pauseAll();
      } else {
        resumeAll();
      }
    }
  }

  void pauseAll() {
    if (Platform.isAndroid) {
      _webViewController?.android.pause();
    }
    pauseTimers();
  }

  void resumeAll() {
    if (Platform.isAndroid) {
      _webViewController?.android.resume();
    }
    resumeTimers();
  }

  void pause() {
    if (Platform.isAndroid) {
      _webViewController?.android.pause();
    }
  }

  void resume() {
    if (Platform.isAndroid) {
      _webViewController?.android.resume();
    }
  }

  void pauseTimers() {
    _webViewController?.pauseTimers();
  }

  void resumeTimers() {
    _webViewController?.resumeTimers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNavigationBar(),
      body: Container(
        color: Colors.white,
        child: webView.url == null ? EmptyTab() : _buildWebView(),
      ),
    );
  }

  _bottomNavigationBar() {
    return StatefulBuilder(builder: (statefulContext, setState) {
      var browserModel =
          Provider.of<BrowserModel>(statefulContext, listen: true);
      var webViewModel =
          Provider.of<WebViewModel>(statefulContext, listen: true);
      var _webViewController = webViewModel.webViewController;

      return ClipRRect(
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
                      onPressed: () {
                        _webViewController?.goBack();
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: UIColors.primaryDarkColor,
                        size: 30,
                      )),
                ),
                Expanded(
                  flex: 2,
                  child: IconButton(
                      onPressed: () {
                        _webViewController?.goForward();
                      },
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
                        onPressed: () {
                          setState(() {
                            // webViewModel = WebViewTab(
                            //   key: GlobalKey(),
                            //   webViewModel: WebViewModel(url: url),
                            // );
                            // webView.url = null;
                            // webViewModel.url = null;
                            // webViewModel = WebViewModel(url: null);

                            browserModel.closeTab(webViewModel.tabIndex!);
                            browserModel.addTab(WebViewTab(
                              key: GlobalKey(),
                              webViewModel: WebViewModel(url: null),
                            ));
                          });
                        },
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
                      key: tabInkWellKey,
                      onLongPress: () {
                        final RenderBox? box = tabInkWellKey.currentContext!
                            .findRenderObject() as RenderBox?;
                        if (box == null) {
                          return;
                        }

                        Offset position = box.localToGlobal(Offset.zero);

                        showMenu(
                                context: context,
                                position: RelativeRect.fromLTRB(
                                    position.dx,
                                    position.dy + box.size.height,
                                    box.size.width,
                                    0),
                                items: TabPopupMenuActions.choices
                                    .map((tabPopupMenuAction) {
                                  IconData? iconData;
                                  switch (tabPopupMenuAction) {
                                    case TabPopupMenuActions.CLOSE_TABS:
                                      iconData = Icons.cancel;
                                      break;
                                    case TabPopupMenuActions.NEW_TAB:
                                      iconData = Icons.add;
                                      break;
                                    case TabPopupMenuActions.NEW_INCOGNITO_TAB:
                                      iconData = Icons.privacy_tip_rounded;
                                      break;
                                  }

                                  return PopupMenuItem<String>(
                                    value: tabPopupMenuAction,
                                    child: Row(children: [
                                      Icon(
                                        iconData,
                                        color: Colors.black,
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: Text(tabPopupMenuAction),
                                      )
                                    ]),
                                  );
                                }).toList())
                            .then((value) {
                          switch (value) {
                            case TabPopupMenuActions.CLOSE_TABS:
                              browserModel.closeAllTabs();
                              break;
                            case TabPopupMenuActions.NEW_TAB:
                              addNewTab();
                              break;
                            case TabPopupMenuActions.NEW_INCOGNITO_TAB:
                              addNewIncognitoTab();
                              break;
                          }
                        });
                      },
                      onTap: () async {
                        if (browserModel.webViewTabs.length > 0) {
                          var webViewModel =
                              browserModel.getCurrentTab()?.webViewModel;
                          var webViewController =
                              webViewModel?.webViewController;
                          var widgetsBingind = WidgetsBinding.instance;

                          if (widgetsBingind != null &&
                              widgetsBingind.window.viewInsets.bottom > 0.0) {
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                            if (FocusManager.instance.primaryFocus != null)
                              FocusManager.instance.primaryFocus!.unfocus();
                            if (webViewController != null) {
                              await webViewController.evaluateJavascript(
                                  source: "document.activeElement.blur();");
                            }
                            await Future.delayed(Duration(milliseconds: 300));
                          }

                          if (webViewModel != null &&
                              webViewController != null) {
                            webViewModel.screenshot = await webViewController
                                .takeScreenshot(
                                    screenshotConfiguration:
                                        ScreenshotConfiguration(
                                            compressFormat: CompressFormat.JPEG,
                                            quality: 20))
                                .timeout(
                                  Duration(milliseconds: 1500),
                                  onTimeout: () => null,
                                );
                          }

                          browserModel.showTabScroller = true;
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            left: 10.0, top: 15.0, right: 10.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 2.0, color: UIColors.primaryDarkColor),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(5.0)),
                        constraints: BoxConstraints(minWidth: 25.0),
                        child: Center(
                            child: Text(
                          browserModel.webViewTabs.length.toString(),
                          style: TextStyle(
                              color: UIColors.primaryDarkColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0),
                        )),
                      ),
                    )),
                Expanded(
                  flex: 2,
                  child: IconButton(
                      onPressed: () {
                        Get.bottomSheet(
                          openBottomSheet(),
                          backgroundColor: Colors.white,
                          clipBehavior: Clip.antiAlias,
                          isScrollControlled: true,
                        );
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
      );
    });
  }

  openBottomSheet() {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    WebViewModel? webViewModel = browserModel.getCurrentTab()?.webViewModel;
    var _webViewController = webViewModel?.webViewController;

    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: false);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment(0.5, 1),
            child: fb.FacebookBannerAd(
              placementId: testAd
                  ? "IMG_16_9_APP_INSTALL#$facebookBannerId"
                  : facebookBannerId,
              bannerSize: fb.BannerSize.MEDIUM_RECTANGLE,
              listener: (result, value) {
                print(value);
              },
            ),
          ),
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
                    child: InkWell(
                      onTap: () {
                        if (userData == null) {
                          Get.toNamed('/auth/login');
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData != null
                                ? userData!.name!
                                : "Not Signed in",
                            style: TextStyle(
                                color: UIColors.blackColor, fontSize: 12.sp),
                          ),
                          Text(
                            userData != null
                                ? userData!.email!
                                : "Sign in to sync your browsing data and coin.",
                            style: TextStyle(
                                color: UIColors.blackColor, fontSize: 10.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   width: 10,
                  // ),
                  // Icon(
                  //   Icons.arrow_forward_ios_rounded,
                  //   size: 35,
                  //   color: UIColors.primaryDarkColor,
                  // )
                ],
              )),
          // Container(
          //   width: Get.width,
          //   padding: EdgeInsets.all(10),
          //   margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
          //   decoration: BoxDecoration(
          //     border: Border.all(color: Colors.grey.withOpacity(.3), width: 1),
          //     borderRadius: BorderRadius.circular(10),
          //   ),
          //   child: Column(
          //     children: [
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Text(
          //             "Privacy Report",
          //             style: TextStyle(color: Colors.grey),
          //           ),
          //           // Text(
          //           //   "Details",
          //           //   style: TextStyle(color: UIColors.primaryDarkColor),
          //           // )
          //         ],
          //       ),
          //       SizedBox(
          //         height: 10,
          //       ),
          //       Row(
          //         children: [
          //           Expanded(
          //               child: Row(
          //             children: [
          //               Image.asset('assets/images/dashboard_icon_07.png'),
          //               SizedBox(
          //                 width: 5,
          //               ),
          //               Column(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text(
          //                     "500 Ads",
          //                     style:
          //                         TextStyle(color: Colors.grey, fontSize: 9.sp),
          //                   ),
          //                   Text(
          //                     "Blocked",
          //                     style:
          //                         TextStyle(color: Colors.grey, fontSize: 9.sp),
          //                   )
          //                 ],
          //               )
          //             ],
          //           )),
          //           SizedBox(
          //             width: 10,
          //           ),
          //           Expanded(
          //               child: Row(
          //             children: [
          //               Image.asset('assets/images/dashboard_icon_08.png'),
          //               SizedBox(
          //                 width: 5,
          //               ),
          //               Column(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text(
          //                     "50.00 Mb",
          //                     style:
          //                         TextStyle(color: Colors.grey, fontSize: 9.sp),
          //                   ),
          //                   Text(
          //                     "Saved",
          //                     style:
          //                         TextStyle(color: Colors.grey, fontSize: 9.sp),
          //                   )
          //                 ],
          //               )
          //             ],
          //           )),
          //           SizedBox(
          //             width: 10,
          //           ),
          //           Expanded(
          //               child: Row(
          //             children: [
          //               Image.asset('assets/images/dashboard_icon_09.png'),
          //               SizedBox(
          //                 width: 5,
          //               ),
          //               Column(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text(
          //                     "50 Min",
          //                     style:
          //                         TextStyle(color: Colors.grey, fontSize: 9.sp),
          //                   ),
          //                   Text(
          //                     "Served",
          //                     style:
          //                         TextStyle(color: Colors.grey, fontSize: 9.sp),
          //                   )
          //                 ],
          //               )
          //             ],
          //           )),
          //         ],
          //       )
          //     ],
          //   ),
          // ),
          if (userData != null)
            Container(
              width: Get.width,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: UIColors.backgroundColor.withOpacity(.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Earning Report",
                        style: TextStyle(color: Colors.grey),
                      ),
                      // Text(
                      //   "Details",
                      //   style:
                      //       TextStyle(color: UIColors.primaryDarkColor),
                      // )
                    ],
                  ),
                  if (userData != null)
                    SizedBox(
                      height: 10,
                    ),
                  if (userData != null)
                    Container(
                      height: 50,
                      child: Row(
                        children: [
                          // Expanded(
                          //     child: Row(
                          //   children: [
                          //     Image.asset(
                          //         'assets/images/dashboard_icon_07.png'),
                          //     SizedBox(
                          //       width: 5,
                          //     ),
                          //     Column(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       crossAxisAlignment:
                          //           CrossAxisAlignment.start,
                          //       children: [
                          //         Text(
                          //           "500 Coins",
                          //           style: TextStyle(
                          //               color: Colors.grey, fontSize: 8.sp),
                          //         ),
                          //         Text(
                          //           "Earned",
                          //           style: TextStyle(
                          //               color: Colors.grey, fontSize: 8.sp),
                          //         )
                          //       ],
                          //     )
                          //   ],
                          // )),
                          // SizedBox(
                          //   width: 10,
                          // ),
                          Expanded(
                              child: Row(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Image.asset(
                                  'assets/images/dashboard_icon_08.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${userData!.totalMinuteServed} Min",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14.sp),
                                    ),
                                    Text(
                                      "Served",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12.sp),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Row(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Image.asset(
                                  'assets/images/dashboard_icon_09.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${userData!.totalAdsViewed} Ads",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14.sp),
                                    ),
                                    Text(
                                      "Viewed",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12.sp),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )),
                        ],
                      ),
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
                      if (LocalData().checkUserLogin()) {
                        Get.offAndToNamed('/bookmarks');
                      } else {
                        Get.back();
                        loginNotifyDialog();
                      }
                    },
                    child: bottomMenuItem("Bookmarks", Icons.bookmarks)),
                // if (browserModel.webViewTabs.length > 0)
                //   TextButton(
                //       onPressed: () async {
                //         if (_webViewController != null) {
                //           webViewModel?.isDesktopMode =
                //               !webViewModel.isDesktopMode;
                //           currentWebViewModel.isDesktopMode =
                //               webViewModel?.isDesktopMode ?? false;
                //
                //           await _webViewController.setOptions(
                //               options: InAppWebViewGroupOptions(
                //                   crossPlatform: InAppWebViewOptions(
                //                       preferredContentMode:
                //                           webViewModel?.isDesktopMode ?? false
                //                               ? UserPreferredContentMode.DESKTOP
                //                               : UserPreferredContentMode
                //                                   .RECOMMENDED)));
                //           await _webViewController.reload();
                //           Get.back();
                //         }
                //       },
                //       child: bottomMenuItem(
                //           "${webViewModel!.isDesktopMode ? "Mobile" : "Desktop"} Mode",
                //           webViewModel.isDesktopMode
                //               ? Icons.phone_android
                //               : Icons.desktop_mac_rounded)),
                TextButton(
                    onPressed: () {
                      if (LocalData().checkUserLogin()) {
                        Get.offAndToNamed('/earning/dashboard');
                      } else {
                        Get.back();
                        loginNotifyDialog();
                      }
                    },
                    child: bottomMenuItem(
                        "Earnings", CupertinoIcons.money_dollar)),
                TextButton(
                    onPressed: () {
                      Get.offAndToNamed('/history/download');
                    },
                    child: bottomMenuItem(
                        "Downloads", CupertinoIcons.cloud_download_fill)),
                TextButton(
                    onPressed: () {
                      Get.back();
                      Share.share(
                          "https://play.google.com/store/apps/details?id=$appID",
                          subject: "iBrowser");
                    },
                    child: bottomMenuItem("Share", Icons.share_outlined)),
                TextButton(
                    onPressed: () {
                      Get.offAndToNamed('/history/browsing');
                    },
                    child: bottomMenuItem("History", Icons.history)),
                TextButton(
                    onPressed: () {
                      if (LocalData().checkUserLogin()) {
                        Get.offAndToNamed('/setting/account');
                      } else {
                        Get.back();
                        loginNotifyDialog();
                      }
                    },
                    child: bottomMenuItem(
                        "Account Settngs", Icons.settings_rounded)),
                TextButton(
                    onPressed: () {
                      // if (LocalData().checkUserLogin()) {
                      LocalData().logOut().then((value) {
                        Get.back();
                        setState(() {
                          userData = null;
                        });
                      });
                      // } else {
                      //   Get.back();
                      //   loginNotifyDialog();
                      // }
                    },
                    child: bottomMenuItem("Logout", Icons.logout))
              ],
            ),
          ),
          // Container(
          //   child: Stack(
          //     children: [
          //       Align(
          //         alignment: Alignment.center,
          //         child: IconButton(
          //             onPressed: () {
          //               Get.back();
          //             },
          //             icon: Icon(
          //               Icons.keyboard_arrow_down,
          //               color: UIColors.primaryDarkColor,
          //               size: 50,
          //             )),
          //       ),
          //       Align(
          //           alignment: Alignment.centerRight,
          //           child: IconButton(
          //               onPressed: () {
          //                 LocalData().logOut();
          //               },
          //               icon: Icon(
          //                 Icons.logout,
          //                 color: UIColors.primaryDarkColor,
          //                 size: 20,
          //               )))
          //     ],
          //   ),
          // )
        ],
      ),
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

  List<String> blockUrls = [
    'googleadservices.com',
    'doubleclick.net',
    'haunigre.net',
    'pesoaniz.com',
    'googletagmanager.com',
    'naucaish.net',
    'jighucme.com',
    'zpujlrylfvk.com',
    'mxtzwvylpjcoq.com',
    'sorryfearknockout.com',
    'visariomedia.com'
  ];

  List<String> unBlockUrls = [
    'jobsexamalert.com',
    'jobstestbd.com',
    'breakingnews24.com.bd',
  ];

  InAppWebView _buildWebView() {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();
    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: true);

    if (Platform.isAndroid) {
      AndroidInAppWebViewController.setWebContentsDebuggingEnabled(
          settings.debuggingEnabled);
    }

    var initialOptions = widget.webViewModel.options!;
    initialOptions.crossPlatform.useOnDownloadStart = true;
    initialOptions.crossPlatform.useOnLoadResource = true;
    // initialOptions.crossPlatform.useShouldOverrideUrlLoading = true;
    initialOptions.crossPlatform.javaScriptCanOpenWindowsAutomatically = true;
    initialOptions.crossPlatform.userAgent =
        "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36";
    initialOptions.crossPlatform.transparentBackground = true;

    initialOptions.android.useShouldInterceptRequest = true;
    initialOptions.android.safeBrowsingEnabled = true;
    initialOptions.android.disableDefaultErrorPage = true;
    initialOptions.android.supportMultipleWindows = true;
    initialOptions.android.useHybridComposition = true;
    initialOptions.android.verticalScrollbarThumbColor =
        Color.fromRGBO(0, 0, 0, 0.5);
    initialOptions.android.horizontalScrollbarThumbColor =
        Color.fromRGBO(0, 0, 0, 0.5);

    initialOptions.ios.allowsLinkPreview = false;
    initialOptions.ios.isFraudulentWebsiteWarningEnabled = true;
    initialOptions.ios.disableLongPressContextMenuOnLinks = true;
    initialOptions.ios.allowingReadAccessTo =
        Uri.parse('file://$WEB_ARCHIVE_DIR/');

    return InAppWebView(
      initialUrlRequest: URLRequest(url: widget.webViewModel.url),
      initialOptions: initialOptions,
      shouldOverrideUrlLoading: (
        controller,
        NavigationAction shouldOverrideUrlLoadingRequest,
      ) async {
        print('shouldOverrideUrlLoading: $shouldOverrideUrlLoadingRequest');
        return null;
      },
      androidShouldInterceptRequest: (
        controller,
        WebResourceRequest request,
      ) async {
        String currentUrl = request.url.toString();
        bool isAd = false;

        for (int i = 0; i < blockUrls.length; i++) {
          if (currentUrl.contains(blockUrls[i])) {
            isAd = true;
          }
        }

        for (int i = 0; i < unBlockUrls.length; i++) {
          if (currentUrl.contains(unBlockUrls[i])) {
            isAd = false;
          }
        }

        WebResourceResponse response = WebResourceResponse();

        if (isAd) {
          return response;
        } else {
          return null;
        }
      },

      onEnterFullscreen: (controller) async {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      },
      onExitFullscreen: (controller) async {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitDown,
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      },

      windowId: widget.webViewModel.windowId,
      // value: (InAppWebViewController controller,
      //     ShouldOverrideUrlLoadingRequest
      //         shouldOverrideUrlLoadingRequest) async {
      //   if (Platform.isAndroid ||
      //       shouldOverrideUrlLoadingRequest.iosWKNavigationType ==
      //           IOSWKNavigationType.LINK_ACTIVATED) {
      //     await controller.loadUrl(
      //         url: shouldOverrideUrlLoadingRequest.url,
      //         headers: {"custom-header": "value"});
      //     return ShouldOverrideUrlLoadingAction.CANCEL;
      //   }
      //   return ShouldOverrideUrlLoadingAction.ALLOW;
      // },
      onWebViewCreated: (controller) async {
        initialOptions.crossPlatform.transparentBackground = false;
        await controller.setOptions(options: initialOptions);

        _webViewController = controller;
        widget.webViewModel.webViewController = controller;

        if (Platform.isAndroid) {
          controller.android.startSafeBrowsing();
        }

        widget.webViewModel.options = await controller.getOptions();

        if (isCurrentTab(currentWebViewModel)) {
          currentWebViewModel.updateWithValue(widget.webViewModel);
        }
      },
      onLoadStart: (controller, url) async {
        widget.webViewModel.isSecure = Util.urlIsSecure(url!);
        widget.webViewModel.url = url;
        widget.webViewModel.loaded = false;
        widget.webViewModel.setLoadedResources([]);
        widget.webViewModel.setJavaScriptConsoleResults([]);

        // Open inserting history

        String? title, currentUrl, favicon;

        await controller.getTitle().then((value) => title = value);
        await controller
            .getUrl()
            .then((value) => currentUrl = value.toString());
        await controller
            .getFavicons()
            .then((value) => favicon = value[0].url.toString());

        DBQueries().insertHistory(title, currentUrl, favicon);

        // Close inserting history

        // Check URL
        myController.checkSite(currentUrl!);
        // Check URL

        if (isCurrentTab(currentWebViewModel)) {
          currentWebViewModel.updateWithValue(widget.webViewModel);
        } else if (widget.webViewModel.needsToCompleteInitialLoad) {
          controller.stopLoading();
        }
      },
      onLoadStop: (controller, url) async {
        widget.webViewModel.url = url;
        widget.webViewModel.favicon = null;
        widget.webViewModel.loaded = true;

        var sslCertificateFuture = _webViewController?.getCertificate();
        var titleFuture = _webViewController?.getTitle();
        var faviconsFuture = _webViewController?.getFavicons();

        var sslCertificate = await sslCertificateFuture;
        if (sslCertificate == null && !Util.isLocalizedContent(url!)) {
          widget.webViewModel.isSecure = false;
        }

        widget.webViewModel.title = await titleFuture;

        List<Favicon>? favicons = await faviconsFuture;
        if (favicons != null && favicons.isNotEmpty) {
          for (var fav in favicons) {
            if (widget.webViewModel.favicon == null) {
              widget.webViewModel.favicon = fav;
            } else {
              if ((widget.webViewModel.favicon!.width == null &&
                      !widget.webViewModel.favicon!.url
                          .toString()
                          .endsWith("favicon.ico")) ||
                  (fav.width != null &&
                      widget.webViewModel.favicon!.width != null &&
                      fav.width! > widget.webViewModel.favicon!.width!)) {
                widget.webViewModel.favicon = fav;
              }
            }
          }
        }

        if (isCurrentTab(currentWebViewModel)) {
          widget.webViewModel.needsToCompleteInitialLoad = false;
          currentWebViewModel.updateWithValue(widget.webViewModel);

          var screenshotData = _webViewController
              ?.takeScreenshot(
                  screenshotConfiguration: ScreenshotConfiguration(
                      compressFormat: CompressFormat.JPEG, quality: 20))
              .timeout(
                Duration(milliseconds: 1500),
                onTimeout: () => null,
              );
          widget.webViewModel.screenshot = await screenshotData;
        }
      },
      onProgressChanged: (controller, progress) {
        widget.webViewModel.progress = progress / 100;

        if (isCurrentTab(currentWebViewModel)) {
          currentWebViewModel.updateWithValue(widget.webViewModel);
        }
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) async {
        widget.webViewModel.url = url;
        widget.webViewModel.title = await _webViewController?.getTitle();

        if (isCurrentTab(currentWebViewModel)) {
          currentWebViewModel.updateWithValue(widget.webViewModel);
        }
      },
      onLongPressHitTestResult: (controller, hitTestResult) async {
        if (LongPressAlertDialog.HIT_TEST_RESULT_SUPPORTED
            .contains(hitTestResult.type)) {
          var requestFocusNodeHrefResult =
              await _webViewController?.requestFocusNodeHref();

          if (requestFocusNodeHrefResult != null) {
            showDialog(
              context: context,
              builder: (context) {
                return LongPressAlertDialog(
                  webViewModel: widget.webViewModel,
                  hitTestResult: hitTestResult,
                  requestFocusNodeHrefResult: requestFocusNodeHrefResult,
                );
              },
            );
          }
        }
      },
      onConsoleMessage: (controller, consoleMessage) {
        Color consoleTextColor = Colors.black;
        Color consoleBackgroundColor = Colors.transparent;
        IconData? consoleIconData;
        Color? consoleIconColor;
        if (consoleMessage.messageLevel == ConsoleMessageLevel.ERROR) {
          consoleTextColor = Colors.red;
          consoleIconData = Icons.report_problem;
          consoleIconColor = Colors.red;
        } else if (consoleMessage.messageLevel == ConsoleMessageLevel.TIP) {
          consoleTextColor = Colors.blue;
          consoleIconData = Icons.info;
          consoleIconColor = Colors.blueAccent;
        } else if (consoleMessage.messageLevel == ConsoleMessageLevel.WARNING) {
          consoleBackgroundColor = Color.fromRGBO(255, 251, 227, 1);
          consoleIconData = Icons.report_problem;
          consoleIconColor = Colors.orangeAccent;
        }

        widget.webViewModel.addJavaScriptConsoleResults(JavaScriptConsoleResult(
          data: consoleMessage.message,
          textColor: consoleTextColor,
          backgroundColor: consoleBackgroundColor,
          iconData: consoleIconData,
          iconColor: consoleIconColor,
        ));

        if (isCurrentTab(currentWebViewModel)) {
          currentWebViewModel.updateWithValue(widget.webViewModel);
        }
      },
      onLoadResource: (controller, resource) {
        widget.webViewModel.addLoadedResources(resource);

        if (isCurrentTab(currentWebViewModel)) {
          currentWebViewModel.updateWithValue(widget.webViewModel);
        }
      },
      onDownloadStart: (controller, url) async {
        if (await Permission.storage.request().isGranted) {
          Directory? downloadPath =
              await DownloadsPathProvider.downloadsDirectory;
          print(downloadPath!.path);
          String path = url.path;
          String fileName = path.substring(path.lastIndexOf('/') + 1);

          print((await getTemporaryDirectory()).path);
          print("start download");
          print(downloadPath);
          print(path);
          print(fileName);

          final taskId = await FlutterDownloader.enqueue(
            url: url.toString(),
            fileName: fileName,
            savedDir: downloadPath.path,
            showNotification: true,
            openFileFromNotification: true,
          );
        }
      },
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        var sslError = challenge.protectionSpace.sslError;
        if (sslError != null &&
            (sslError.iosError != null || sslError.androidError != null)) {
          if (Platform.isIOS && sslError.iosError == IOSSslError.UNSPECIFIED) {
            return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.PROCEED);
          }
          widget.webViewModel.isSecure = false;
          if (isCurrentTab(currentWebViewModel)) {
            currentWebViewModel.updateWithValue(widget.webViewModel);
          }
          return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.CANCEL);
        }
        return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED);
      },
      onLoadError: (controller, url, code, message) async {
        if (Platform.isIOS && code == -999) {
          // NSURLErrorDomain
          return;
        }

        var errorUrl =
            url ?? widget.webViewModel.url ?? Uri.parse('about:blank');

        _webViewController?.loadData(data: """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <style>
    ${await _webViewController?.getTRexRunnerCss()}
    </style>
    <style>
    .interstitial-wrapper {
        box-sizing: border-box;
        font-size: 1em;
        line-height: 1.6em;
        margin: 0 auto 0;
        max-width: 600px;
        width: 100%;
    }
    </style>
</head>
<body>
    ${await _webViewController?.getTRexRunnerHtml()}
    <div class="interstitial-wrapper">
      <h1>Website not available</h1>
      <p>Could not load web pages at <strong>$errorUrl</strong> because:</p>
      <p>$message</p>
    </div>
</body>
    """, baseUrl: errorUrl, androidHistoryUrl: errorUrl);

        widget.webViewModel.url = url;
        widget.webViewModel.isSecure = false;

        if (isCurrentTab(currentWebViewModel)) {
          currentWebViewModel.updateWithValue(widget.webViewModel);
        }
      },
      onTitleChanged: (controller, title) async {
        widget.webViewModel.title = title;

        if (isCurrentTab(currentWebViewModel)) {
          currentWebViewModel.updateWithValue(widget.webViewModel);
        }
      },
      onCreateWindow: (controller, createWindowRequest) async {
        var webViewTab = WebViewTab(
          key: GlobalKey(),
          webViewModel: WebViewModel(
              url: Uri.parse("about:blank"),
              windowId: createWindowRequest.windowId),
        );

        browserModel.addTab(webViewTab);

        return true;
      },
      onCloseWindow: (controller) {
        if (_isWindowClosed) {
          return;
        }
        _isWindowClosed = true;
        if (widget.webViewModel.tabIndex != null) {
          browserModel.closeTab(widget.webViewModel.tabIndex!);
        }
      },
      androidOnPermissionRequest: (InAppWebViewController controller,
          String origin, List<String> resources) async {
        return PermissionRequestResponse(
            resources: resources,
            action: PermissionRequestResponseAction.GRANT);
      },
      onReceivedHttpAuthRequest: (InAppWebViewController controller,
          URLAuthenticationChallenge challenge) async {
        var action = await createHttpAuthDialog(challenge);
        return HttpAuthResponse(
            username: _httpAuthUsernameController.text.trim(),
            password: _httpAuthPasswordController.text,
            action: action,
            permanentPersistence: true);
      },
    );
  }

  bool isCurrentTab(WebViewModel currentWebViewModel) {
    return currentWebViewModel.tabIndex == widget.webViewModel.tabIndex;
  }

  Future<HttpAuthResponseAction> createHttpAuthDialog(
      URLAuthenticationChallenge challenge) async {
    HttpAuthResponseAction action = HttpAuthResponseAction.CANCEL;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Login"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(challenge.protectionSpace.host),
              TextField(
                decoration: InputDecoration(labelText: "Username"),
                controller: _httpAuthUsernameController,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Password"),
                controller: _httpAuthPasswordController,
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text("Cancel"),
              onPressed: () {
                action = HttpAuthResponseAction.CANCEL;
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Ok"),
              onPressed: () {
                action = HttpAuthResponseAction.PROCEED;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return action;
  }

  void onShowTab() async {
    this.resume();
    if (widget.webViewModel.needsToCompleteInitialLoad) {
      widget.webViewModel.needsToCompleteInitialLoad = false;
      await widget.webViewModel.webViewController
          ?.loadUrl(urlRequest: URLRequest(url: widget.webViewModel.url));
    }
  }

  void onHideTab() async {
    this.pause();
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
      NavigationActionPolicy shouldOverrideUrlLoadingRequest) async {
    return NavigationActionPolicy.CANCEL;
  }

  void addNewTab({Uri? url}) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();

    // if (url == null) {
    //   url = settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
    //       ? Uri.parse(settings.customUrlHomePage)
    //       : Uri.parse(settings.searchEngine.url);
    // }

    // browserModel.addTab(EmptyTab());

    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(url: url),
    ));
  }

  void addNewIncognitoTab({Uri? url}) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();

    if (url == null) {
      url = settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
          ? Uri.parse(settings.customUrlHomePage)
          : Uri.parse(settings.searchEngine.url);
    }

    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(url: url, isIncognitoMode: true),
    ));
  }
}
