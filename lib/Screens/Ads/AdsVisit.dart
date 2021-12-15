import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:iBrowser/PoJo/AdsModel.dart';
import 'package:iBrowser/Service/Network.dart';
import 'package:iBrowser/Utils/UI_Colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AdsVisit extends StatefulWidget {
  @override
  _AdsVisitState createState() => _AdsVisitState();
}

class _AdsVisitState extends State<AdsVisit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController submitController = new TextEditingController();

  String? adId = Get.parameters['id'];

  final GlobalKey webViewKey = GlobalKey();

  AdsModel? ads;

  var rng = new Random();
  late int num1, num2;

  double progress = 0;

  late Timer adVisitingTimer;

  InAppWebViewController? webViewController;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;

  void initState() {
    num1 = rng.nextInt(9);
    num2 = rng.nextInt(9);

    Network().getAd(adId!).then((value) {
      setState(() {
        ads = value;
      });
      webViewController?.loadUrl(
          urlRequest: URLRequest(url: Uri.parse(ads!.url!)));

      adVisitingTimer =
          Timer(Duration(seconds: ads!.minVisitingTime!), () => setVisited());
    });

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    adVisitingTimer.cancel();
    super.dispose();
  }

  setVisited() {
    Get.defaultDialog(
        title: "Ad Revenue",
        barrierDismissible: false,
        content: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("$num1 + $num2 = ?"),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black)),
                child: TextFormField(
                  controller: submitController,
                  validator: (value) {
                    if (value!.length == 0) {
                      return 'Please enter value';
                    } else if (int.parse(value) != (num1 + num2)) {
                      return 'Please enter correct value';
                    } else
                      return null;
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: "Sum Value"),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Get.back();
                  Network().adRevenue(ads!.sId!);
                }
              },
              child: Text("Submit"))
        ]).then((value) => Get.back());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        titleSpacing: 0,
        title: Text(
          ads != null ? ads!.title! : 'Loading',
        ),
        backgroundColor: UIColors.primaryDarkColor,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
          child: ads == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    progress < 1.0
                        ? LinearProgressIndicator(value: progress)
                        : Container(),
                    Expanded(
                      child: InAppWebView(
                        key: webViewKey,
                        initialUrlRequest:
                            URLRequest(url: Uri.parse(ads!.url!)),
                        initialUserScripts:
                            UnmodifiableListView<UserScript>([]),
                        initialOptions: options,
                        pullToRefreshController: pullToRefreshController,
                        onWebViewCreated: (controller) {
                          webViewController = controller;
                        },
                        onLoadStart: (controller, url) {
                          setState(() {
                            ads!.url = url.toString();
                          });
                        },
                        androidOnPermissionRequest:
                            (controller, origin, resources) async {
                          return PermissionRequestResponse(
                              resources: resources,
                              action: PermissionRequestResponseAction.GRANT);
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                          var uri = navigationAction.request.url!;

                          if (![
                            "http",
                            "https",
                            "file",
                            "chrome",
                            "data",
                            "javascript",
                            "about"
                          ].contains(uri.scheme)) {
                            if (await canLaunch(ads!.url!)) {
                              // Launch the App
                              await launch(
                                ads!.url!,
                              );
                              // and cancel the request
                              return NavigationActionPolicy.CANCEL;
                            }
                          }

                          return NavigationActionPolicy.ALLOW;
                        },
                        onLoadStop: (controller, url) async {
                          pullToRefreshController.endRefreshing();
                          setState(() {
                            ads!.url = url.toString();
                          });
                        },
                        onLoadError: (controller, url, code, message) {
                          pullToRefreshController.endRefreshing();
                        },
                        onProgressChanged: (controller, progress) {
                          if (progress == 100) {
                            pullToRefreshController.endRefreshing();
                          }
                          setState(() {
                            this.progress = progress / 100;
                            // urlController.text = this.url;
                          });
                        },
                        onUpdateVisitedHistory:
                            (controller, url, androidIsReload) {
                          setState(() {
                            ads!.url = url.toString();
                            // urlController.text = this.url;
                          });
                        },
                        // onConsoleMessage: (controller, consoleMessage) {
                        //   print(consoleMessage);
                        // },
                      ),
                    ),
                  ],
                )),
    );
  }
}
