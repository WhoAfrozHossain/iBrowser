import 'dart:async';
import 'dart:io';

import 'package:best_browser/Screens/Browser/app_bar/browser_app_bar.dart';
import 'package:best_browser/Screens/Browser/custom_image.dart';
import 'package:best_browser/Screens/Browser/models/webview_model.dart';
import 'package:best_browser/Screens/Browser/tab_popup_menu_actions.dart';
import 'package:best_browser/Screens/Browser/tab_viewer.dart';
import 'package:best_browser/Screens/Browser/webview_tab.dart';
import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'app_bar/tab_viewer_app_bar.dart';
import 'empty_tab.dart';
import 'models/browser_model.dart';

class Browser extends StatefulWidget {
  Browser({Key? key}) : super(key: key);

  @override
  _BrowserState createState() => _BrowserState();
}

class _BrowserState extends State<Browser> with SingleTickerProviderStateMixin {
  static const platform =
      const MethodChannel('com.pichillilorenzo.flutter_browser.intent_data');

  var _isRestored = false;

  GlobalKey tabInkWellKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    getIntentData();
  }

  getIntentData() async {
    if (Platform.isAndroid) {
      String? url = await platform.invokeMethod("getIntentData");
      if (url != null) {
        var browserModel = Provider.of<BrowserModel>(context, listen: false);
        browserModel.addTab(WebViewTab(
          key: GlobalKey(),
          webViewModel: WebViewModel(url: Uri.parse(url)),
        ));
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  restore() async {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    browserModel.restore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isRestored) {
      _isRestored = true;
      restore();
    }
    precacheImage(AssetImage("assets/icon/icon.png"), context);
  }

  @override
  Widget build(BuildContext context) {
    return _buildBrowser();
  }

  Widget _buildBrowser() {
    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: true);
    var browserModel = Provider.of<BrowserModel>(context, listen: true);

    browserModel.addListener(() {
      browserModel.save();
    });
    currentWebViewModel.addListener(() {
      browserModel.save();
    });

    var canShowTabScroller =
        browserModel.showTabScroller && browserModel.webViewTabs.isNotEmpty;

    return IndexedStack(
      index: canShowTabScroller ? 1 : 0,
      children: [
        _buildWebViewTabs(),
        canShowTabScroller ? _buildWebViewTabsViewer() : Container()
      ],
    );
  }

  Widget _buildWebViewTabs() {
    return WillPopScope(
        onWillPop: () async {
          var browserModel = Provider.of<BrowserModel>(context, listen: false);
          var webViewModel = browserModel.getCurrentTab()?.webViewModel;
          var _webViewController = webViewModel?.webViewController;

          if (_webViewController != null) {
            if (await _webViewController.canGoBack()) {
              _webViewController.goBack();
              return false;
            }
          }

          if (webViewModel != null && webViewModel.tabIndex != null) {
            setState(() {
              browserModel.closeTab(webViewModel.tabIndex!);
            });
            FocusScope.of(context).unfocus();
            return false;
          }

          return browserModel.webViewTabs.length == 0;
        },
        child: Listener(
          onPointerUp: (_) {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              currentFocus.focusedChild!.unfocus();
            }
          },
          child: Scaffold(
            appBar: BrowserAppBar(),
            body: _buildWebViewTabsContent(),
            bottomNavigationBar: _bottomNavigationBar(),
          ),
        ));
  }

  Widget _buildWebViewTabsContent() {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);

    if (browserModel.webViewTabs.length == 0) {
      return EmptyTab();
    }

    var stackChildren = <Widget>[
      IndexedStack(
        index: browserModel.getCurrentTabIndex(),
        children: browserModel.webViewTabs.map((webViewTab) {
          var isCurrentTab = webViewTab.webViewModel.tabIndex ==
              browserModel.getCurrentTabIndex();

          if (isCurrentTab) {
            Future.delayed(const Duration(milliseconds: 100), () {
              webViewTab.key.currentState?.onShowTab();
            });
          } else {
            webViewTab.key.currentState?.onHideTab();
          }

          return webViewTab;
        }).toList(),
      ),
      _createProgressIndicator()
    ];

    return Stack(
      children: stackChildren,
    );
  }

  Widget _createProgressIndicator() {
    return Selector<WebViewModel, double>(
        selector: (context, webViewModel) => webViewModel.progress,
        builder: (context, progress, child) {
          if (progress >= 1.0) {
            return Container();
          }
          return PreferredSize(
              preferredSize: Size(double.infinity, 4.0),
              child: SizedBox(
                  height: 4.0,
                  child: LinearProgressIndicator(
                    value: progress,
                  )));
        });
  }

  Widget _buildWebViewTabsViewer() {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);

    return WillPopScope(
        onWillPop: () async {
          browserModel.showTabScroller = false;
          return false;
        },
        child: Scaffold(
            appBar: TabViewerAppBar(),
            body: TabViewer(
              currentIndex: browserModel.getCurrentTabIndex(),
              children: browserModel.webViewTabs.map((webViewTab) {
                webViewTab.key.currentState?.pause();
                var screenshotData = webViewTab.webViewModel.screenshot;
                Widget screenshotImage = Container(
                  decoration: BoxDecoration(color: Colors.white),
                  width: double.infinity,
                  child: screenshotData != null
                      ? Image.memory(screenshotData)
                      : null,
                );

                var url = webViewTab.webViewModel.url;
                var faviconUrl = webViewTab.webViewModel.favicon != null
                    ? webViewTab.webViewModel.favicon!.url
                    : (url != null && ["http", "https"].contains(url.scheme)
                        ? Uri.parse(url.origin + "/favicon.ico")
                        : null);

                var isCurrentTab = browserModel.getCurrentTabIndex() ==
                    webViewTab.webViewModel.tabIndex;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Material(
                      color: isCurrentTab
                          ? Colors.blue
                          : (webViewTab.webViewModel.isIncognitoMode
                              ? Colors.black
                              : Colors.white),
                      child: Container(
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              // CachedNetworkImage(
                              //   placeholder: (context, url) =>
                              //   url == "about:blank"
                              //       ? Container()
                              //       : CircularProgressIndicator(),
                              //   imageUrl: faviconUrl,
                              //   height: 30,
                              // )
                              CustomImage(
                                  url: faviconUrl, maxWidth: 30.0, height: 30.0)
                            ],
                          ),
                          title: Text(
                              webViewTab.webViewModel.title ??
                                  webViewTab.webViewModel.url?.toString() ??
                                  "",
                              maxLines: 2,
                              style: TextStyle(
                                color:
                                    webViewTab.webViewModel.isIncognitoMode ||
                                            isCurrentTab
                                        ? Colors.white
                                        : Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                              webViewTab.webViewModel.url?.toString() ?? "",
                              style: TextStyle(
                                color:
                                    webViewTab.webViewModel.isIncognitoMode ||
                                            isCurrentTab
                                        ? Colors.white60
                                        : Colors.black54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 20.0,
                                  color:
                                      webViewTab.webViewModel.isIncognitoMode ||
                                              isCurrentTab
                                          ? Colors.white60
                                          : Colors.black54,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (webViewTab.webViewModel.tabIndex !=
                                        null) {
                                      browserModel.closeTab(
                                          webViewTab.webViewModel.tabIndex!);
                                      if (browserModel.webViewTabs.length ==
                                          0) {
                                        browserModel.showTabScroller = false;
                                      }
                                    }
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: screenshotImage,
                    )
                  ],
                );
              }).toList(),
              onTap: (index) async {
                browserModel.showTabScroller = false;
                browserModel.showTab(index);
              },
            )));
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
      );
    });
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

  void addNewTab({Uri? url}) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();

    if (url == null) {
      url = settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
          ? Uri.parse(settings.customUrlHomePage)
          : Uri.parse(settings.searchEngine.url);
    }

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
