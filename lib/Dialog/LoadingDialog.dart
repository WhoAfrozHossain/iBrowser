//
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
//
// class Loading {
//   static late Future dialog;
//
//   void show() async {
//     if (dialog == null) {
//       dialog = viewDialog();
//       await dialog;
//     }
//   }
//
//   void dismiss() {
//     if (dialog != null) {
//       dialog = null;
//       Get.back();
//     }
//   }
//
//   Future viewDialog() {
//     return showCupertinoDialog(
//         context: Get.context,
//         builder: (BuildContext context) => AlertDialog(
//               backgroundColor: Colors.white.withOpacity(.9),
//               insetPadding: EdgeInsets.symmetric(horizontal: 100),
//               content: Container(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     SizedBox(
//                       height: 15,
//                     ),
//                     SpinKitFoldingCube(duration: Duration(milliseconds: 1500),
//                       color: UIColors.primaryColor,
//                       size: 50.0,
//                     ),
//                     SizedBox(
//                       height:30,
//                     ),
//                     SpinKitPouringHourglass(
//                       color: UIColors.primaryColor,
//                       size: 50.0,
//                     ),
//                     // Shimmer.fromColors(
//                     //   child: Text(
//                     //     'GoFast',
//                     //     style: TextStyle(
//                     //       fontSize: ResponsiveFlutter.of(context).fontSize(4),
//                     //       fontWeight: FontWeight.bold
//                     //     ),
//                     //   ),
//                     //   baseColor: UIColors.primaryColor,
//                     //   highlightColor: Colors.white,
//                     // ),
//                     // Opacity(
//                     //   opacity: 0.8,
//                     //   child: Shimmer.fromColors(
//                     //     child: Row(
//                     //       mainAxisSize: MainAxisSize.min,
//                     //       children: <Widget>[
//                     //         Image.asset(
//                     //           'assets/images/icon.png',
//                     //           height: 20.0,
//                     //         ),
//                     //         const Padding(
//                     //           padding: EdgeInsets.symmetric(horizontal: 4.0),
//                     //         ),
//                     //         const Text(
//                     //           'Slide to unlock',
//                     //           style: TextStyle(
//                     //             fontSize: 28.0,
//                     //           ),
//                     //         )
//                     //       ],
//                     //     ),
//                     //     baseColor: Colors.black12,
//                     //     highlightColor: Colors.white,
//                     //     loop: 3,
//                     //   ),
//                     // ),
//                     SizedBox(
//                       height: 15,
//                     ),
//                     // Container(
//                     //   child: Text(
//                     //     "Loading...",
//                     //     style: TextStyle(
//                     //       color: UIColors.primaryColor,
//                     //       fontSize: ResponsiveFlutter.of(context).fontSize(2.5),
//                     //     ),
//                     //     textAlign: TextAlign.center,
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),
//             ));
//   }
// }
