import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:iBrowser/PoJo/HistoryModel.dart';
import 'package:iBrowser/Screens/Browser/app_bar/global_widget.dart';
import 'package:iBrowser/Screens/Browser/models/browser_model.dart';
import 'package:iBrowser/Screens/Browser/models/webview_model.dart';
import 'package:iBrowser/Service/SQFlite/DBQueries.dart';
import 'package:iBrowser/Utils/UI_Colors.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class UrlSearch extends StatefulWidget {
  @override
  _UrlSearchState createState() => _UrlSearchState();
}

class _UrlSearchState extends State<UrlSearch> {
  TextEditingController? _searchController = TextEditingController();
  FocusNode? _focusNode;

  List<HistoryModel>? histories = [];

  String searchTest = '';

  OutlineInputBorder outlineBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: const BorderRadius.all(
      const Radius.circular(50.0),
    ),
  );

  @override
  void initState() {
    getHistory();
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

  getHistory() {
    DBQueries().getHistory().then((value) {
      print(value.length);
      setState(() {
        histories = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? leading = _buildAppBarHomePageWidget();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Selector<WebViewModel, Uri?>(
                selector: (context, webViewModel) =>
                    webViewModel.url == null ? Uri.parse("") : webViewModel.url,
                builder: (context, url, child) {
                  if (url == null) {
                    _searchController?.text = "";
                  }
                  if (url != null &&
                      _focusNode != null &&
                      !_focusNode!.hasFocus) {
                    _searchController?.text = url.toString();
                  }

                  return Selector<WebViewModel, bool>(
                      selector: (context, webViewModel) =>
                          webViewModel.isIncognitoMode,
                      builder: (context, isIncognitoMode, child) {
                        return leading != null
                            ? AppBar(
                                backgroundColor: Colors.black87,
                                leading: _buildAppBarHomePageWidget(),
                                titleSpacing: 0.0,
                                title: _buildSearchTextField(),
                                // actions: _buildActionsMenu(),
                              )
                            : AppBar(
                                automaticallyImplyLeading: false,
                                backgroundColor: Colors.black87,
                                titleSpacing: 10.0,
                                title: _buildSearchTextField(),
                                // actions: _buildActionsMenu(),
                              );
                      });
                }),
            // AppBar(
            //   automaticallyImplyLeading: false,
            //   backgroundColor: Colors.black87,
            //   titleSpacing: 10.0,
            //   title: _buildSearchTextField(),
            //   // actions: _buildActionsMenu(),
            // ),
            Expanded(
              child: histories == null
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height:
                                  histories![index].url!.contains(searchTest)
                                      ? 8
                                      : 0,
                            );
                          },
                          itemCount: histories!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return histories![index].url!.contains(searchTest)
                                ? historyItem(index)
                                : Container();
                          }),
                    ),
            ),
          ],
        ),
      ),
    );
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
          addNewTab(context);
        }
      },
    );
  }

  bool select = true;

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
              if (select) {
                final newText = _searchController!.text.toLowerCase();
                _searchController!.value = _searchController!.value.copyWith(
                  text: newText,
                  selection: TextSelection(
                      baseOffset: 0, extentOffset: newText.length),
                  composing: TextRange.empty,
                );

                select = false;
              }
            },
            onSubmitted: (value) {
              openUrl(value, settings, _webViewController, webViewModel);
            },
            onChanged: (value) {
              if (histories!.length > 0)
                setState(() {
                  searchTest = value;
                });
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
              hintText: "Search or type web address",
              hintStyle: TextStyle(color: Colors.black54, fontSize: 16.0),
            ),
            style: TextStyle(color: Colors.black, fontSize: 16.0),
          ),
          IconButton(
            icon: Selector<WebViewModel, bool>(
              selector: (context, webViewModel) => webViewModel.isSecure,
              builder: (context, isSecure, child) {
                return Image.asset(settings.searchEngine.assetIcon);
              },
            ),
            onPressed: () {
              // showUrlInfo();

              // showSearchEngineDialog(webViewModel, browserModel, context);
              showSearchEngineDialog(browserModel, context);
            },
          ),
        ],
      ),
    );
  }

  openUrl(
      String value, var settings, var _webViewController, var webViewModel) {
    var url = Uri.parse(value.trim());

    if (!value.contains(".")) {
      value = settings.searchEngine.searchUrl + value;
    } else {
      if (!value.contains("www.") && !value.startsWith("http")) {
        value = "www." + value;
      }
      if (!value.startsWith("http")) {
        value = "https://" + value;
      }
    }
    url = Uri.parse(value);

    if (_webViewController != null) {
      _webViewController.loadUrl(urlRequest: URLRequest(url: url));
    } else {
      addNewTab(context, url: url);
      webViewModel.url = url;
    }
    Get.back();
  }

  historyItem(int index) {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();

    var webViewModel = Provider.of<WebViewModel>(context, listen: true);
    var _webViewController = webViewModel.webViewController;

    return InkWell(
      onTap: () {
        openUrl(
            histories![index].url!, settings, _webViewController, webViewModel);
      },
      child: Container(
        color: UIColors.backgroundColor,
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            histories![index].favicon != null
                ? Container(
                    height: 30,
                    width: 30,
                    child: Image.network(histories![index].favicon!),
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
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: UIColors.blackColor, fontSize: 12.sp),
                  ),
                  Text(
                    histories![index].url!,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: UIColors.blackColor, fontSize: 10.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
