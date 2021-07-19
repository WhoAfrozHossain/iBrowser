import 'dart:io';

import 'package:best_browser/Screens/Browser/app_bar/url_info_popup.dart';
import 'package:best_browser/Screens/Browser/custom_image.dart';
import 'package:best_browser/Screens/Browser/models/browser_model.dart';
import 'package:best_browser/Screens/Browser/models/favorite_model.dart';
import 'package:best_browser/Screens/Browser/models/search_engine_model.dart';
import 'package:best_browser/Screens/Browser/models/webview_model.dart';
import 'package:best_browser/Screens/Browser/pages/developers/main.dart';
import 'package:best_browser/Screens/Browser/pages/settings/main.dart';
import 'package:best_browser/Service/Network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:share_extend/share_extend.dart';

import '../custom_popup_dialog.dart';
import '../custom_popup_menu_item.dart';
import '../popup_menu_actions.dart';
import '../project_info_popup.dart';
import '../webview_tab.dart';

class WebViewTabAppBar extends StatefulWidget {
  final void Function()? showFindOnPage;

  WebViewTabAppBar({Key? key, this.showFindOnPage}) : super(key: key);

  @override
  _WebViewTabAppBarState createState() => _WebViewTabAppBarState();
}

class _WebViewTabAppBarState extends State<WebViewTabAppBar>
    with SingleTickerProviderStateMixin {
  TextEditingController? _searchController = TextEditingController();
  FocusNode? _focusNode;

  GlobalKey tabInkWellKey = new GlobalKey();

  Duration customPopupDialogTransitionDuration =
      const Duration(milliseconds: 300);
  CustomPopupDialogPageRoute? route;

  OutlineInputBorder outlineBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: const BorderRadius.all(
      const Radius.circular(50.0),
    ),
  );

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode?.addListener(() async {
      if (_focusNode != null &&
          !_focusNode!.hasFocus &&
          _searchController != null &&
          _searchController!.text.isEmpty) {
        var browserModel = Provider.of<BrowserModel>(context, listen: true);
        var webViewModel = browserModel.getCurrentTab()?.webViewModel;
        InAppWebViewController? _webViewController =
            webViewModel?.webViewController;
        _searchController!.text =
            (await _webViewController?.getUrl())?.toString() ?? "";
      }
    });
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _focusNode = null;
    _searchController?.dispose();
    _searchController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? leading = _buildAppBarHomePageWidget();
    return Selector<WebViewModel, Uri?>(
        selector: (context, webViewModel) => webViewModel.url,
        builder: (context, url, child) {
          if (url == null) {
            _searchController?.text = "";
          }
          if (url != null && _focusNode != null && !_focusNode!.hasFocus) {
            _searchController?.text = url.toString();
          }

          return Selector<WebViewModel, bool>(
              selector: (context, webViewModel) => webViewModel.isIncognitoMode,
              builder: (context, isIncognitoMode, child) {
                return leading != null
                    ? AppBar(
                        backgroundColor:
                            isIncognitoMode ? Colors.black87 : Colors.blue,
                        leading: _buildAppBarHomePageWidget(),
                        titleSpacing: 0.0,
                        title: _buildSearchTextField(),
                        actions: _buildActionsMenu(),
                      )
                    : AppBar(
                        automaticallyImplyLeading: false,
                        backgroundColor:
                            isIncognitoMode ? Colors.black87 : Colors.blue,
                        titleSpacing: 10.0,
                        title: _buildSearchTextField(),
                        actions: _buildActionsMenu(),
                      );
              });
        });
  }

  Widget? _buildAppBarHomePageWidget() {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();

    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    var _webViewController = webViewModel.webViewController;

    if (!settings.homePageEnabled) {
      return null;
    }

    return IconButton(
      icon: Icon(Icons.home),
      onPressed: () {
        if (_webViewController != null) {
          var url =
              settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
                  ? Uri.parse(settings.customUrlHomePage)
                  : Uri.parse(settings.searchEngine.url);
          _webViewController.loadUrl(urlRequest: URLRequest(url: url));
        } else {
          addNewTab();
        }
      },
    );
  }

  Widget _buildSearchTextField() {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();

    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    var _webViewController = webViewModel.webViewController;

    return Container(
      height: 40.0,
      child: Stack(
        children: <Widget>[
          TextField(
            onTap: () {
              final newText = _searchController!.text.toLowerCase();
              _searchController!.value = _searchController!.value.copyWith(
                text: newText,
                selection: TextSelection(
                    baseOffset: newText.length, extentOffset: newText.length),
                composing: TextRange.empty,
              );
            },
            onSubmitted: (value) {
              var url = Uri.parse(value.trim());

              // print(url.scheme);

              if (!value.contains(".")) {
                url = Uri.parse(settings.searchEngine.searchUrl + value);
              } else {
                if (!value.contains("www.")) {
                  value = "www." + value;
                  url = Uri.parse(value);
                }
                if (!value.startsWith("http")) {
                  url = Uri.parse("https://" + value);
                }
              }

              if (_webViewController != null) {
                _webViewController.loadUrl(urlRequest: URLRequest(url: url));
              } else {
                addNewTab(url: url);
                webViewModel.url = url;
              }
            },
            keyboardType: TextInputType.url,
            focusNode: _focusNode,
            autofocus: false,
            controller: _searchController,
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(
                  left: 45.0, top: 10.0, right: 10.0, bottom: 10.0),
              filled: true,
              fillColor: Colors.white,
              border: outlineBorder,
              focusedBorder: outlineBorder,
              enabledBorder: outlineBorder,
              suffixIcon: IconButton(
                onPressed: () {
                  Network().createBookmark(
                      webViewModel.title, webViewModel.url.toString());
                },
                icon: Icon(
                  Icons.star,
                  color: Colors.yellow,
                ),
              ),
              hintText: "Search or type web address",
              hintStyle: TextStyle(color: Colors.black54, fontSize: 16.0),
            ),
            style: TextStyle(color: Colors.black, fontSize: 16.0),
          ),
          IconButton(
            icon: Selector<WebViewModel, bool>(
              selector: (context, webViewModel) => webViewModel.isSecure,
              builder: (context, isSecure, child) {
                var icon = Icons.info_outline;
                if (webViewModel.isIncognitoMode) {
                  icon = Icons.privacy_tip_rounded;
                } else if (isSecure) {
                  if (webViewModel.url != null &&
                      webViewModel.url!.scheme == "file") {
                    icon = Icons.offline_pin;
                  }
                  /* else {
                    icon = Icons.lock;
                  }*/
                }

                return Image.asset(settings.searchEngine.assetIcon);

                // return Icon(
                //   icon,
                //   color: isSecure ? Colors.green : Colors.grey,
                // );
              },
            ),
            onPressed: () {
              // showUrlInfo();

              showSearchEngineDialog(webViewModel, browserModel);
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionsMenu() {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();

    return <Widget>[
      settings.homePageEnabled
          ? SizedBox(
              width: 0.0,
            )
          : Container(),
      // InkWell(
      //   key: tabInkWellKey,
      //   onLongPress: () {
      //     final RenderBox? box =
      //         tabInkWellKey.currentContext!.findRenderObject() as RenderBox?;
      //     if (box == null) {
      //       return;
      //     }
      //
      //     Offset position = box.localToGlobal(Offset.zero);
      //
      //     showMenu(
      //             context: context,
      //             position: RelativeRect.fromLTRB(position.dx,
      //                 position.dy + box.size.height, box.size.width, 0),
      //             items: TabPopupMenuActions.choices.map((tabPopupMenuAction) {
      //               IconData? iconData;
      //               switch (tabPopupMenuAction) {
      //                 case TabPopupMenuActions.CLOSE_TABS:
      //                   iconData = Icons.cancel;
      //                   break;
      //                 case TabPopupMenuActions.NEW_TAB:
      //                   iconData = Icons.add;
      //                   break;
      //                 case TabPopupMenuActions.NEW_INCOGNITO_TAB:
      //                   iconData = Icons.privacy_tip_rounded;
      //                   break;
      //               }
      //
      //               return PopupMenuItem<String>(
      //                 value: tabPopupMenuAction,
      //                 child: Row(children: [
      //                   Icon(
      //                     iconData,
      //                     color: Colors.black,
      //                   ),
      //                   Container(
      //                     padding: EdgeInsets.only(left: 10.0),
      //                     child: Text(tabPopupMenuAction),
      //                   )
      //                 ]),
      //               );
      //             }).toList())
      //         .then((value) {
      //       switch (value) {
      //         case TabPopupMenuActions.CLOSE_TABS:
      //           browserModel.closeAllTabs();
      //           break;
      //         case TabPopupMenuActions.NEW_TAB:
      //           addNewTab();
      //           break;
      //         case TabPopupMenuActions.NEW_INCOGNITO_TAB:
      //           addNewIncognitoTab();
      //           break;
      //       }
      //     });
      //   },
      //   onTap: () async {
      //     if (browserModel.webViewTabs.length > 0) {
      //       var webViewModel = browserModel.getCurrentTab()?.webViewModel;
      //       var webViewController = webViewModel?.webViewController;
      //       var widgetsBingind = WidgetsBinding.instance;
      //
      //       if (widgetsBingind != null &&
      //           widgetsBingind.window.viewInsets.bottom > 0.0) {
      //         SystemChannels.textInput.invokeMethod('TextInput.hide');
      //         if (FocusManager.instance.primaryFocus != null)
      //           FocusManager.instance.primaryFocus!.unfocus();
      //         if (webViewController != null) {
      //           await webViewController.evaluateJavascript(
      //               source: "document.activeElement.blur();");
      //         }
      //         await Future.delayed(Duration(milliseconds: 300));
      //       }
      //
      //       if (webViewModel != null && webViewController != null) {
      //         webViewModel.screenshot = await webViewController
      //             .takeScreenshot(
      //                 screenshotConfiguration: ScreenshotConfiguration(
      //                     compressFormat: CompressFormat.JPEG, quality: 20))
      //             .timeout(
      //               Duration(milliseconds: 1500),
      //               onTimeout: () => null,
      //             );
      //       }
      //
      //       browserModel.showTabScroller = true;
      //     }
      //   },
      //   child: Container(
      //     margin:
      //         EdgeInsets.only(left: 10.0, top: 15.0, right: 10.0, bottom: 15.0),
      //     decoration: BoxDecoration(
      //         border: Border.all(width: 2.0, color: Colors.white),
      //         shape: BoxShape.rectangle,
      //         borderRadius: BorderRadius.circular(5.0)),
      //     constraints: BoxConstraints(minWidth: 25.0),
      //     child: Center(
      //         child: Text(
      //       browserModel.webViewTabs.length.toString(),
      //       style: TextStyle(
      //           color: Colors.white,
      //           fontWeight: FontWeight.bold,
      //           fontSize: 14.0),
      //     )),
      //   ),
      // ),
      PopupMenuButton<String>(
        onSelected: _popupMenuChoiceAction,
        itemBuilder: (popupMenuContext) {
          var items = [
            CustomPopupMenuItem<String>(
              enabled: true,
              isIconButtonRow: true,
              child: StatefulBuilder(
                builder: (statefulContext, setState) {
                  var browserModel =
                      Provider.of<BrowserModel>(statefulContext, listen: true);
                  var webViewModel =
                      Provider.of<WebViewModel>(statefulContext, listen: true);
                  var _webViewController = webViewModel.webViewController;

                  var isFavorite = false;
                  FavoriteModel? favorite;

                  if (webViewModel.url != null &&
                      webViewModel.url!.toString().isNotEmpty) {
                    favorite = FavoriteModel(
                        url: webViewModel.url,
                        title: webViewModel.title ?? "",
                        favicon: webViewModel.favicon);
                    isFavorite = browserModel.containsFavorite(favorite);
                  }

                  var children = <Widget>[];

                  if (Platform.isIOS) {
                    children.add(
                      Container(
                          width: 35.0,
                          child: IconButton(
                              padding: const EdgeInsets.all(0.0),
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                _webViewController?.goBack();
                                Navigator.pop(popupMenuContext);
                              })),
                    );
                  }

                  children.addAll([
                    Container(
                        width: 35.0,
                        child: IconButton(
                            padding: const EdgeInsets.all(0.0),
                            icon: Icon(
                              Icons.arrow_forward,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              _webViewController?.goForward();
                              Navigator.pop(popupMenuContext);
                            })),
                    // Container(
                    //     width: 35.0,
                    //     child: IconButton(
                    //         padding: const EdgeInsets.all(0.0),
                    //         icon: Icon(
                    //           isFavorite ? Icons.star : Icons.star_border,
                    //           color: Colors.black,
                    //         ),
                    //         onPressed: () {
                    //           setState(() {
                    //             if (favorite != null) {
                    //               if (!browserModel
                    //                   .containsFavorite(favorite)) {
                    //                 browserModel.addFavorite(favorite);
                    //               } else if (browserModel
                    //                   .containsFavorite(favorite)) {
                    //                 browserModel.removeFavorite(favorite);
                    //               }
                    //             }
                    //           });
                    //         })),
                    // Container(
                    //     width: 35.0,
                    //     child: IconButton(
                    //         padding: const EdgeInsets.all(0.0),
                    //         icon: Icon(
                    //           Icons.file_download,
                    //           color: Colors.black,
                    //         ),
                    //         onPressed: () async {
                    //           Navigator.pop(popupMenuContext);
                    //           if (webViewModel.url != null &&
                    //               webViewModel.url!.scheme.startsWith("http")) {
                    //             var url = webViewModel.url;
                    //             if (url == null) {
                    //               return;
                    //             }
                    //
                    //             String webArchivePath = WEB_ARCHIVE_DIR +
                    //                 Platform.pathSeparator +
                    //                 url.scheme +
                    //                 "-" +
                    //                 url.host +
                    //                 url.path.replaceAll("/", "-") +
                    //                 DateTime.now()
                    //                     .microsecondsSinceEpoch
                    //                     .toString() +
                    //                 "." +
                    //                 (Platform.isAndroid
                    //                     ? WebArchiveFormat.MHT.toValue()
                    //                     : WebArchiveFormat.WEBARCHIVE
                    //                         .toValue());
                    //
                    //             String? savedPath =
                    //                 (await _webViewController?.saveWebArchive(
                    //                     filePath: webArchivePath,
                    //                     autoname: false));
                    //
                    //             var webArchiveModel = WebArchiveModel(
                    //                 url: url,
                    //                 path: savedPath,
                    //                 title: webViewModel.title,
                    //                 favicon: webViewModel.favicon,
                    //                 timestamp: DateTime.now());
                    //
                    //             if (savedPath != null) {
                    //               browserModel.addWebArchive(
                    //                   url.toString(), webArchiveModel);
                    //               ScaffoldMessenger.of(context)
                    //                   .showSnackBar(SnackBar(
                    //                 content: Text(
                    //                     "${webViewModel.url} saved offline!"),
                    //               ));
                    //               browserModel.save();
                    //             } else {
                    //               ScaffoldMessenger.of(context)
                    //                   .showSnackBar(SnackBar(
                    //                 content: Text("Unable to save!"),
                    //               ));
                    //             }
                    //           }
                    //         })),
                    // Container(
                    //     width: 35.0,
                    //     child: IconButton(
                    //         padding: const EdgeInsets.all(0.0),
                    //         icon: Icon(
                    //           Icons.info_outline,
                    //           color: Colors.black,
                    //         ),
                    //         onPressed: () async {
                    //           Navigator.pop(popupMenuContext);
                    //
                    //           await route?.completed;
                    //           showUrlInfo();
                    //         })),
                    Container(
                        width: 35.0,
                        child: IconButton(
                            padding: const EdgeInsets.all(0.0),
                            icon: Icon(
                              Icons.settings_cell_outlined,
                              color: Colors.black,
                            ),
                            onPressed: () async {
                              Navigator.pop(popupMenuContext);

                              await route?.completed;

                              takeScreenshotAndShow();
                            })),
                    Container(
                        width: 35.0,
                        child: IconButton(
                            padding: const EdgeInsets.all(0.0),
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              _webViewController?.reload();
                              Navigator.pop(popupMenuContext);
                            })),
                  ]);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: children,
                  );
                },
              ),
            )
          ];

          items.addAll(PopupMenuActions.choices.map((choice) {
            switch (choice) {
              case PopupMenuActions.NEW_TAB:
                return CustomPopupMenuItem<String>(
                  enabled: true,
                  value: choice,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(choice),
                        Icon(
                          Icons.add,
                          color: Colors.black,
                        )
                      ]),
                );
              case PopupMenuActions.NEW_PRIVATE_TAB:
                return CustomPopupMenuItem<String>(
                  enabled: true,
                  value: choice,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(choice),
                        Icon(
                          Icons.lock,
                          color: Colors.black,
                        )
                      ]),
                );
              case PopupMenuActions.BOOKMARKS:
                return CustomPopupMenuItem<String>(
                  enabled: true,
                  value: choice,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(choice),
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                        )
                      ]),
                );
              case PopupMenuActions.DESKTOP_MODE:
                return CustomPopupMenuItem<String>(
                  enabled: browserModel.getCurrentTab() != null,
                  value: choice,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(choice),
                        Selector<WebViewModel, bool>(
                          selector: (context, webViewModel) =>
                              webViewModel.isDesktopMode,
                          builder: (context, value, child) {
                            return Icon(
                              value
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: Colors.black,
                            );
                          },
                        )
                      ]),
                );
              case PopupMenuActions.HISTORY:
                return CustomPopupMenuItem<String>(
                  // enabled: browserModel.getCurrentTab() != null,
                  value: choice,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(choice),
                        Icon(
                          Icons.history,
                          color: Colors.black,
                        )
                      ]),
                );
              case PopupMenuActions.DOWNLOADS:
                return CustomPopupMenuItem<String>(
                  // enabled: browserModel.getCurrentTab() != null,
                  value: choice,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(choice),
                        Icon(
                          Icons.download,
                          color: Colors.black,
                        )
                      ]),
                );
              case PopupMenuActions.SHARE:
                return CustomPopupMenuItem<String>(
                  enabled: browserModel.getCurrentTab() != null,
                  value: choice,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(choice),
                        Icon(
                          Icons.share,
                          color: Colors.green,
                        )
                      ]),
                );
              default:
                return CustomPopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
            }
          }).toList());

          return items;
        },
      )
    ];
  }

  void _popupMenuChoiceAction(String choice) async {
    switch (choice) {
      case PopupMenuActions.NEW_TAB:
        addNewTab();
        break;
      case PopupMenuActions.NEW_PRIVATE_TAB:
        addNewIncognitoTab();
        break;
      case PopupMenuActions.BOOKMARKS:
        Get.toNamed('/bookmarks');
        break;
      case PopupMenuActions.HISTORY:
        Get.toNamed('/history/browsing');
        // showHistory();
        break;
      case PopupMenuActions.DOWNLOADS:
        Get.toNamed('/history/download');
        // showHistory();
        break;
      case PopupMenuActions.SHARE:
        share();
        break;
      case PopupMenuActions.DESKTOP_MODE:
        toggleDesktopMode();
        break;
    }
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

  void showFavorites() {
    showDialog(
        context: context,
        builder: (context) {
          var browserModel = Provider.of<BrowserModel>(context, listen: true);

          return AlertDialog(
              contentPadding: EdgeInsets.all(0.0),
              content: Container(
                  width: double.maxFinite,
                  child: ListView(
                    children: browserModel.favorites.map((favorite) {
                      var url = favorite.url;
                      var faviconUrl = favorite.favicon != null
                          ? favorite.favicon!.url
                          : Uri.parse((url?.origin ?? "") + "/favicon.ico");

                      return ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // CachedNetworkImage(
                            //   placeholder: (context, url) =>
                            //       CircularProgressIndicator(),
                            //   imageUrl: faviconUrl,
                            //   height: 30,
                            // )
                            CustomImage(
                              url: faviconUrl,
                              maxWidth: 30.0,
                              height: 30.0,
                            )
                          ],
                        ),
                        title: Text(
                            favorite.title ?? favorite.url?.toString() ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        subtitle: Text(favorite.url?.toString() ?? "",
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        isThreeLine: true,
                        onTap: () {
                          setState(() {
                            addNewTab(url: favorite.url);
                            Navigator.pop(context);
                          });
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.close, size: 20.0),
                              onPressed: () {
                                setState(() {
                                  browserModel.removeFavorite(favorite);
                                  if (browserModel.favorites.length == 0) {
                                    Navigator.pop(context);
                                  }
                                });
                              },
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  )));
        });
  }

  void showHistory() {
    showDialog(
        context: context,
        builder: (context) {
          var webViewModel = Provider.of<WebViewModel>(context, listen: true);

          return AlertDialog(
              contentPadding: EdgeInsets.all(0.0),
              content: FutureBuilder(
                future:
                    webViewModel.webViewController?.getCopyBackForwardList(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  WebHistory history = snapshot.data as WebHistory;
                  return Container(
                      width: double.maxFinite,
                      child: ListView(
                        children: history.list?.reversed.map((historyItem) {
                              var url = historyItem.url;

                              return ListTile(
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    // CachedNetworkImage(
                                    //   placeholder: (context, url) =>
                                    //       CircularProgressIndicator(),
                                    //   imageUrl: (url?.origin ?? "") + "/favicon.ico",
                                    //   height: 30,
                                    // )
                                    CustomImage(
                                        url: Uri.parse((url?.origin ?? "") +
                                            "/favicon.ico"),
                                        maxWidth: 30.0,
                                        height: 30.0)
                                  ],
                                ),
                                title: Text(historyItem.title ?? url.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                subtitle: Text(url?.toString() ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                isThreeLine: true,
                                onTap: () {
                                  webViewModel.webViewController
                                      ?.goTo(historyItem: historyItem);
                                  Navigator.pop(context);
                                },
                              );
                            }).toList() ??
                            <Widget>[],
                      ));
                },
              ));
        });
  }

  void showWebArchives() async {
    showDialog(
        context: context,
        builder: (context) {
          var browserModel = Provider.of<BrowserModel>(context, listen: true);
          var webArchives = browserModel.webArchives;

          var listViewChildren = <Widget>[];
          webArchives.forEach((key, webArchive) {
            var path = webArchive.path;
            // String fileName = path.substring(path.lastIndexOf('/') + 1);

            var url = webArchive.url;

            listViewChildren.add(ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // CachedNetworkImage(
                  //   placeholder: (context, url) => CircularProgressIndicator(),
                  //   imageUrl: (url?.origin ?? "") + "/favicon.ico",
                  //   height: 30,
                  // )
                  CustomImage(
                      url: Uri.parse((url?.origin ?? "") + "/favicon.ico"),
                      maxWidth: 30.0,
                      height: 30.0)
                ],
              ),
              title: Text(webArchive.title ?? url?.toString() ?? "",
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(url?.toString() ?? "",
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  setState(() {
                    browserModel.removeWebArchive(webArchive);
                    browserModel.save();
                  });
                },
              ),
              isThreeLine: true,
              onTap: () {
                if (path != null) {
                  var browserModel =
                      Provider.of<BrowserModel>(context, listen: false);
                  browserModel.addTab(WebViewTab(
                    key: GlobalKey(),
                    webViewModel:
                        WebViewModel(url: Uri.parse("file://" + path)),
                  ));
                }
                Navigator.pop(context);
              },
            ));
          });

          return AlertDialog(
              contentPadding: EdgeInsets.all(0.0),
              content: Builder(
                builder: (context) {
                  return Container(
                      width: double.maxFinite,
                      child: ListView(
                        children: listViewChildren,
                      ));
                },
              ));
        });
  }

  void share() {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var webViewModel = browserModel.getCurrentTab()?.webViewModel;
    var url = webViewModel?.url;
    if (url != null) {
      Share.share(url.toString(), subject: webViewModel?.title);
    }
  }

  void toggleDesktopMode() async {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var webViewModel = browserModel.getCurrentTab()?.webViewModel;
    var _webViewController = webViewModel?.webViewController;

    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: false);

    if (_webViewController != null) {
      webViewModel?.isDesktopMode = !webViewModel.isDesktopMode;
      currentWebViewModel.isDesktopMode = webViewModel?.isDesktopMode ?? false;

      await _webViewController.setOptions(
          options: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                  preferredContentMode: webViewModel?.isDesktopMode ?? false
                      ? UserPreferredContentMode.DESKTOP
                      : UserPreferredContentMode.RECOMMENDED)));
      await _webViewController.reload();
    }
  }

  void showSearchEngineDialog(var webViewModel, var browserModel) {
    var settings = browserModel.getSettings();

    var url = webViewModel.url;
    if (url == null || url.toString().isEmpty) {
      return;
    }

    route = CustomPopupDialog.show(
      context: context,
      transitionDuration: customPopupDialogTransitionDuration,
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: SearchEngines.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                  width: 30,
                  child: Center(
                      child: Image.asset(SearchEngines[index].assetIcon))),
              horizontalTitleGap: 10,
              title: Text(SearchEngines[index].name),
              subtitle: Text(SearchEngines[index].url),
              onTap: () {
                setState(() {
                  settings.searchEngine = SearchEngines[index];

                  browserModel.updateSettings(settings);
                });
                Get.back();
              },
            );
          },
        );
        // return ListTile(
        //   title: const Text("Search Engine"),
        //   subtitle: Text(settings.searchEngine.name),
        //   trailing: DropdownButton<SearchEngineModel>(
        //     hint: Text("Search Engine"),
        //     onChanged: (value) {
        //       setState(() {
        //         if (value != null) {
        //           settings.searchEngine = value;
        //         }
        //         browserModel.updateSettings(settings);
        //       });
        //     },
        //     value: settings.searchEngine,
        //     items: SearchEngines.map((searchEngine) {
        //       return DropdownMenuItem(
        //         value: searchEngine,
        //         child: Text(searchEngine.name),
        //       );
        //     }).toList(),
        //   ),
        // );
      },
    );
  }

  void showUrlInfo() {
    var webViewModel = Provider.of<WebViewModel>(context, listen: false);
    var url = webViewModel.url;
    if (url == null || url.toString().isEmpty) {
      return;
    }

    route = CustomPopupDialog.show(
      context: context,
      transitionDuration: customPopupDialogTransitionDuration,
      builder: (context) {
        return UrlInfoPopup(
          route: route!,
          transitionDuration: customPopupDialogTransitionDuration,
          onWebViewTabSettingsClicked: () {
            goToSettingsPage();
          },
        );
      },
    );
  }

  void goToDevelopersPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DevelopersPage()));
  }

  void goToSettingsPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingsPage()));
  }

  void openProjectPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return ProjectInfoPopup();
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  void takeScreenshotAndShow() async {
    var webViewModel = Provider.of<WebViewModel>(context, listen: false);
    var screenshot = await webViewModel.webViewController?.takeScreenshot();

    if (screenshot != null) {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/" +
          "screenshot_" +
          DateTime.now().microsecondsSinceEpoch.toString() +
          ".png");
      await file.writeAsBytes(screenshot);

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Image.memory(screenshot),
            actions: <Widget>[
              ElevatedButton(
                child: Text("Share"),
                onPressed: () async {
                  await ShareExtend.share(file.path, "image");
                },
              )
            ],
          );
        },
      );

      file.delete();
    }
  }
}
