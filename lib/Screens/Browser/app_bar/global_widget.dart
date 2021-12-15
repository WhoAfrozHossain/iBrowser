import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iBrowser/Screens/Browser/custom_popup_dialog.dart';
import 'package:iBrowser/Screens/Browser/models/browser_model.dart';
import 'package:iBrowser/Screens/Browser/models/search_engine_model.dart';
import 'package:iBrowser/Screens/Browser/models/webview_model.dart';
import 'package:iBrowser/Screens/Browser/webview_tab.dart';
import 'package:provider/provider.dart';

CustomPopupDialogPageRoute? route;

void addNewTab(BuildContext context, {Uri? url}) {
  var browserModel = Provider.of<BrowserModel>(context, listen: false);
  var settings = browserModel.getSettings();

  // if (url == null) {
  //   url = settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
  //       ? Uri.parse(settings.customUrlHomePage)
  //       : Uri.parse(settings.searchEngine.url);
  // }

  browserModel.addTab(WebViewTab(
    key: GlobalKey(),
    webViewModel: WebViewModel(url: url),
  ));
}

void showSearchEngineDialog(
    /*var webViewModel,*/ var browserModel, BuildContext context) {
  var settings = browserModel.getSettings();
  //
  // var url = webViewModel.url;
  // if (url == null || url.toString().isEmpty) {
  //   return;
  // }

  route = CustomPopupDialog.show(
    context: context,
    transitionDuration: Duration(milliseconds: 300),
    builder: (context) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: SearchEngines.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
                width: 30,
                child:
                    Center(child: Image.asset(SearchEngines[index].assetIcon))),
            horizontalTitleGap: 10,
            title: Text(SearchEngines[index].name),
            subtitle: Text(SearchEngines[index].url),
            onTap: () {
              settings.searchEngine = SearchEngines[index];

              browserModel.updateSettings(settings);
              Get.back();
            },
          );
        },
      );
    },
  );
}
