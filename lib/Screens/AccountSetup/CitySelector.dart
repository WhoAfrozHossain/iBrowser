import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iBrowser/PoJo/CityModel.dart';
import 'package:iBrowser/PoJo/CountryModel.dart';
import 'package:iBrowser/Service/LocalData.dart';
import 'package:iBrowser/Service/Network.dart';
import 'package:iBrowser/Utils/UI_Colors.dart';
import 'package:sizer/sizer.dart';

class CitySelector extends StatefulWidget {
  @override
  _CitySelectorState createState() => _CitySelectorState();
}

class _CitySelectorState extends State<CitySelector> {
  List<CountryModel> countries = [];
  var _selectedCountry;

  List<CityModel> cityList = [];
  List<CityModel> cities = [];
  var _selectedCity;

  @override
  void initState() {
    Network().getCountries().then((value) {
      if (mounted) {
        setState(() {
          countries = value;
        });
      }
    });

    Network().getCities().then((value) {
      if (mounted) {
        setState(() {
          cityList = value;
        });
      }
    });

    super.initState();
  }

  filterCity() {
    cities.clear();
    for (int i = 0; i < cityList.length; i++) {
      print(cityList[i].countryId);
      print(_selectedCountry);
      if (cityList[i].countryId == _selectedCountry) {
        setState(() {
          cities.add(cityList[i]);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColors.primaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Image.asset('assets/images/intro_shape.png'),
                Image.asset('assets/images/image_5.png')
              ],
            ),
            Container(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Select your Country",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 18.sp)),
                      SizedBox(
                        height: 10,
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
                            'Please select your country',
                            style:
                                TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ), // Not necessary for Option 1
                          decoration: InputDecoration(
                              enabledBorder: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.fromLTRB(-5, 10, -10, 10)),
                          validator: (value) => value == null
                              ? 'Please select your country'
                              : null,
                          isExpanded: true,
                          value: _selectedCountry,
                          onChanged: (var country) {
                            setState(() {
                              _selectedCountry = country;
                            });
                            filterCity();
                          },
                          items: countries.map((country) {
                            return DropdownMenuItem(
                              child: new Text(country.name),
                              value: country.sId,
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text("Select your city",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 18.sp)),
                      SizedBox(
                        height: 10,
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
                            style:
                                TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ), // Not necessary for Option 1
                          decoration: InputDecoration(
                              enabledBorder: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.fromLTRB(-5, 10, -10, 10)),
                          validator: (value) =>
                              value == null ? 'Please select your city' : null,
                          isExpanded: true,
                          value: _selectedCity,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCity = newValue;
                            });
                          },
                          items: cities.map((city) {
                            return DropdownMenuItem(
                              child: new Text(city.name),
                              value: city.sId,
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Container()),
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  UIColors.buttonColor),
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.all(10)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(200.0),
                              ))),
                          onPressed: () {
                            if (_selectedCountry == null ||
                                _selectedCity == null) {
                              Get.defaultDialog(
                                  title: "Sorry",
                                  content: Text("Please Select Country & City"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: Text("OK"),
                                    )
                                  ]);
                            } else {
                              LocalData().saveCountryAndCity(
                                  _selectedCountry, _selectedCity);
                            }
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
            )
          ],
        ),
      ),
    );
  }
}
