import 'package:best_browser/PoJo/InterestModel.dart';
import 'package:best_browser/Service/LocalData.dart';
import 'package:best_browser/Service/Network.dart';
import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class InterestScreen extends StatefulWidget {
  @override
  _InterestScreenState createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  List<InterestModel> interests = [];
  List<bool> switchValue = [];

  @override
  void initState() {
    Network().getInterests().then((value) {
      switchValue.clear();
      for (int i = 0; i < value.length; i++) {
        switchValue.add(false);
      }
      setState(() {
        interests = value;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [
                UIColors.primaryDarkColor,
                UIColors.primaryColor,
              ],
              begin: const FractionalOffset(0.5, -1.0),
              end: const FractionalOffset(-0.5, 1.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
        child: interests.length == 0
            ? Center(
                child: CupertinoActivityIndicator(),
              )
            : SafeArea(
                child: Column(
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            width: Get.width,
                            child: Text(
                              "Interests",
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: interests.length,
                            itemBuilder: (context, index) {
                              return SwitchListTile(
                                value: switchValue[index],
                                onChanged: (_) async {
                                  setState(() {
                                    print(switchValue[index]);
                                    switchValue[index] = !switchValue[index];
                                    print(switchValue[index]);
                                  });
                                  if (switchValue[index]) {
                                    await FirebaseMessaging.instance
                                        .subscribeToTopic(
                                            interests[index].sId!);
                                    print(
                                        "Subscribe " + interests[index].topic!);
                                  } else {
                                    await FirebaseMessaging.instance
                                        .unsubscribeFromTopic(
                                            interests[index].sId!);
                                    print("Unsubscribe " +
                                        interests[index].topic!);
                                  }
                                },
                                activeColor: Colors.white,
                                title: Text(
                                  interests[index].topic!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    )),
                    Row(
                      children: [
                        Container(
                          width: Get.width,
                          padding: EdgeInsets.all(10),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        UIColors.buttonColor),
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.all(10)),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(200.0),
                                    ))),
                                onPressed: () {
                                  LocalData().setInterests();
                                },
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 50,
                                )),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
