import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class CitySelector extends StatefulWidget {
  @override
  _CitySelectorState createState() => _CitySelectorState();
}

class _CitySelectorState extends State<CitySelector> {
  List<String> cities = ['Dhaka', 'Rajshahi', 'Chittagong'];
  var _selectedCity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.primaryColor,
      body: Container(
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Image.asset('assets/images/intro_shape.png'),
                Image.asset('assets/images/image_5.png')
              ],
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Select your city",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 20.sp)),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: Get.width,
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField(
                            hint: Text(
                              'Please select your city',
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey),
                            ), // Not necessary for Option 1
                            decoration: InputDecoration(
                                enabledBorder: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.fromLTRB(-5, 10, -10, 10)),
                            validator: (value) => value == null
                                ? 'Please select your city'
                                : null,
                            isExpanded: true,
                            value: _selectedCity,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedCity = newValue;
                              });
                            },
                            items: cities.map((category) {
                              return DropdownMenuItem(
                                child: new Text(category),
                                value: category,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    )),
                    Row(
                      children: [
                        Expanded(child: Container()),
                        // TextButton(
                        //     onPressed: () {},
                        //     child: Text(
                        //       "SKIP",
                        //       style: TextStyle(color: Colors.white),
                        //     )),
                        TextButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    UIColors.buttonColor),
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(10)),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(200.0),
                                ))),
                            onPressed: () {
                              Get.toNamed('/auth/start');
                            },
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 50,
                            ))
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
