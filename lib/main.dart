import 'dart:io';

import 'package:best_browser/Controller/Bindings/Binding.dart';
import 'package:best_browser/Screens/AccountSetup/CitySelector.dart';
import 'package:best_browser/Screens/Ads/AdsBrowsing.dart';
import 'package:best_browser/Screens/Ads/AdsVisit.dart';
import 'package:best_browser/Screens/Auth/GettingStarted.dart';
import 'package:best_browser/Screens/Auth/Login.dart';
import 'package:best_browser/Screens/Auth/RecoverAccount.dart';
import 'package:best_browser/Screens/Auth/Register.dart';
import 'package:best_browser/Screens/Auth/SetPassword.dart';
import 'package:best_browser/Screens/Browser/browser.dart';
import 'package:best_browser/Screens/Browser/models/browser_model.dart';
import 'package:best_browser/Screens/Browser/models/webview_model.dart';
import 'package:best_browser/Screens/Earning/EarningDashboard.dart';
import 'package:best_browser/Screens/History/BrowsingHistory.dart';
import 'package:best_browser/Screens/History/DownloadsHistory.dart';
import 'package:best_browser/Screens/Interests/Interests.dart';
import 'package:best_browser/Screens/Intro/intro1.dart';
import 'package:best_browser/Screens/Intro/intro2.dart';
import 'package:best_browser/Screens/Intro/intro3.dart';
import 'package:best_browser/Screens/Setting/AccountSetting.dart';
import 'package:best_browser/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

late final WEB_ARCHIVE_DIR;

late final TAB_VIEWER_BOTTOM_OFFSET_1;
late final TAB_VIEWER_BOTTOM_OFFSET_2;
late final TAB_VIEWER_BOTTOM_OFFSET_3;

const TAB_VIEWER_TOP_OFFSET_1 = 0.0;
const TAB_VIEWER_TOP_OFFSET_2 = 10.0;
const TAB_VIEWER_TOP_OFFSET_3 = 20.0;

const TAB_VIEWER_TOP_SCALE_TOP_OFFSET = 250.0;
const TAB_VIEWER_TOP_SCALE_BOTTOM_OFFSET = 230.0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  WEB_ARCHIVE_DIR = (await getApplicationSupportDirectory()).path;

  if (Platform.isIOS) {
    TAB_VIEWER_BOTTOM_OFFSET_1 = 130.0;
    TAB_VIEWER_BOTTOM_OFFSET_2 = 140.0;
    TAB_VIEWER_BOTTOM_OFFSET_3 = 150.0;
  } else {
    TAB_VIEWER_BOTTOM_OFFSET_1 = 110.0;
    TAB_VIEWER_BOTTOM_OFFSET_2 = 120.0;
    TAB_VIEWER_BOTTOM_OFFSET_3 = 130.0;
  }

  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );

  await Permission.camera.request();
  await Permission.microphone.request();
  await Permission.storage.request();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.subscribeToTopic('iBrowser');

  FirebaseMessaging.instance.getInitialMessage();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              styleInformation: BigTextStyleInformation(''),
              icon: '@mipmap/launcher_icon',
            ),
          ));
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    Get.toNamed('/');
  });

  await GetStorage.init();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  HttpOverrides.global = new MyHttpOverrides();

  runApp(Sizer(builder: (context, orientation, deviceType) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => WebViewModel(),
        ),
        ChangeNotifierProxyProvider<WebViewModel, BrowserModel>(
          update: (context, webViewModel, browserModel) {
            browserModel!.setCurrentWebViewModel(webViewModel);
            return browserModel;
          },
          create: (BuildContext context) => BrowserModel(null),
        ),
      ],
      child: GetMaterialApp(
        theme: ThemeData(fontFamily: 'Ubuntu'),
        initialBinding: BindingControllers(),
        initialRoute: '/',
        defaultTransition: Transition.noTransition,
        getPages: [
          GetPage(name: '/', page: () => SplashScreen()),
          GetPage(name: '/browser', page: () => Browser()),
          GetPage(
              name: '/intro/1',
              page: () => IntroPageFirst(),
              transition: Transition.rightToLeft),
          GetPage(
              name: '/intro/2',
              page: () => IntroPageSecond(),
              transition: Transition.rightToLeft),
          GetPage(
              name: '/intro/3',
              page: () => IntroPageThird(),
              transition: Transition.rightToLeft),
          GetPage(
              name: '/interest',
              page: () => InterestScreen(),
              transition: Transition.rightToLeft),
          GetPage(
              name: '/setup/city',
              page: () => CitySelector(),
              transition: Transition.rightToLeft),
          GetPage(
              name: '/auth/start',
              page: () => GettingStarted(),
              transition: Transition.rightToLeft),
          GetPage(
              name: '/auth/login',
              page: () => Login(),
              transition: Transition.rightToLeft),
          GetPage(
              name: '/auth/recover',
              page: () => RecoverAccount(),
              transition: Transition.rightToLeft),
          GetPage(
              name: '/auth/setPassword',
              page: () => SetPassword(),
              transition: Transition.rightToLeft),
          GetPage(
              name: '/auth/register',
              page: () => Register(),
              transition: Transition.rightToLeft),
          GetPage(
            name: '/earning/dashboard',
            page: () => EarningDashboard(),
          ),
          GetPage(
            name: '/history/download',
            page: () => DownloadsHistory(),
          ),
          GetPage(
            name: '/history/browsing',
            page: () => BrowsingHistory(),
          ),
          GetPage(
            name: '/setting/account',
            page: () => AccountSetting(),
          ),
          GetPage(
            name: '/ads/browse',
            page: () => AdsBrowsing(),
          ),
          GetPage(
            name: '/ads/visit/:id',
            page: () => AdsVisit(),
          ),
        ],
      ),
    );
  }));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
