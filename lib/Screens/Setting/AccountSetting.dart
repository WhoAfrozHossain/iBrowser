import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iBrowser/PoJo/CityModel.dart';
import 'package:iBrowser/PoJo/CountryModel.dart';
import 'package:iBrowser/PoJo/UserModel.dart';
import 'package:iBrowser/PoJo/WithdrawalMethodModel.dart';
import 'package:iBrowser/Service/Network.dart';
import 'package:iBrowser/Utils/Decoration.dart';
import 'package:iBrowser/Utils/UI_Colors.dart';
import 'package:sizer/sizer.dart';

class AccountSetting extends StatefulWidget {
  @override
  _AccountSettingState createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController nameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController cityController = new TextEditingController();
  TextEditingController accountController = new TextEditingController();

  bool termsChecked = false;

  List<String> genders = ['Male', 'Female', 'Others'];
  String? _selectedGender;

  List<CountryModel> countries = [];
  var _selectedCountry;

  List<CityModel> cityList = [];
  List<CityModel> cities = [];
  var _selectedCity;

  List<WithdrawalMethodModel> withdrawalMethods = [];
  var _selectedWithdrawalMethod;

  UserModel? userData;

  @override
  void initState() {
    Network().getUserData().then((value) {
      setState(() {
        userData = value;
        nameController.text = userData!.name!;
        emailController.text = userData!.email!;
        phoneController.text = userData!.phone!;
        accountController.text = userData!.accountNo!;
        if (userData!.gender! != "") {
          _selectedGender = userData!.gender!;
        }
        if (countries.length > 0) {
          _selectedCountry = userData!.countryId!;
          filterCity();
        }
        if (cityList.length > 0) {
          _selectedCity = userData!.cityId!;
          filterCity();
        }
        if (withdrawalMethods.length > 0 &&
            userData!.withdrawalMethodId! != "") {
          _selectedWithdrawalMethod = userData!.withdrawalMethodId!;
          filterCity();
        }
      });
    });

    Network().getCountries().then((value) {
      if (mounted) {
        setState(() {
          countries = value;
          if (userData != null) {
            _selectedCountry = userData!.countryId!;
            filterCity();
          }
        });
      }
    });

    Network().getCities().then((value) {
      if (mounted) {
        setState(() {
          cityList = value;
          if (userData != null) {
            _selectedCity = userData!.cityId!;
            filterCity();
          }
        });
      }
    });

    Network().getWithdrawalMethods().then((value) {
      if (mounted) {
        setState(() {
          withdrawalMethods = value;
          if (userData != null && userData!.withdrawalMethodId! != "") {
            _selectedWithdrawalMethod = userData!.withdrawalMethodId;
          }
        });
      }
    });

    super.initState();
  }

  filterCity() {
    cities.clear();
    for (int i = 0; i < cityList.length; i++) {
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        titleSpacing: 0,
        title: Text(
          'Account Setting',
        ),
        backgroundColor: UIColors.primaryDarkColor,
        elevation: 0,
      ),
      backgroundColor: UIColors.backgroundColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(15),
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Full Name",
                    style: TextStyle(
                        color: UIColors.primaryDarkColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 12.sp)),
                SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: CustomDecoration().textFieldDecoration(),
                  child: TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if (value!.length == 0) {
                        return "Please enter your name";
                      } else
                        return null;
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      prefixIcon: Icon(
                        CupertinoIcons.person_circle,
                        color: Colors.grey.withOpacity(.5),
                      ),
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(.8)),
                      hintText: "Full Name",
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Email Address",
                    style: TextStyle(
                        color: UIColors.primaryDarkColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 12.sp)),
                SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: CustomDecoration().textFieldDecoration(),
                  child: TextFormField(
                    controller: emailController,
                    enabled: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      prefixIcon: Icon(
                        CupertinoIcons.mail,
                        color: Colors.grey.withOpacity(.5),
                      ),
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(.8)),
                      hintText: "Email Address",
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Phone Number",
                    style: TextStyle(
                        color: UIColors.primaryDarkColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 12.sp)),
                SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: CustomDecoration().textFieldDecoration(),
                  child: TextFormField(
                    controller: phoneController,
                    validator: (value) {
                      if (value!.length == 0) {
                        return "Please enter your phone number";
                      } else
                        return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      prefixIcon: Icon(
                        CupertinoIcons.phone_circle,
                        color: Colors.grey.withOpacity(.5),
                      ),
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(.8)),
                      hintText: "Phone Number",
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Gender",
                    style: TextStyle(
                        color: UIColors.primaryDarkColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 12.sp)),
                SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: CustomDecoration().textFieldDecoration(),
                  child: DropdownButtonFormField(
                    hint: Text(
                      'Gender',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                    ), // Not necessary for Option 1
                    decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        prefixIcon:
                            Image.asset('assets/images/gender_icon.png'),
                        contentPadding: EdgeInsets.fromLTRB(10, 12, 5, 12)),
                    validator: (value) =>
                        value == null ? 'Please select your Gender' : null,
                    isExpanded: true,
                    value: _selectedGender,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                    items: genders.map((gender) {
                      return DropdownMenuItem(
                        child: new Text(gender),
                        value: gender,
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Country",
                    style: TextStyle(
                        color: UIColors.primaryDarkColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 12.sp)),
                SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: CustomDecoration().textFieldDecoration(),
                  child: DropdownButtonFormField(
                    hint: Text(
                      'Please select your country',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ), // Not necessary for Option 1
                    decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(10, 12, 5, 12),
                      prefixIcon: Icon(
                        CupertinoIcons.location_solid,
                        color: Colors.grey.withOpacity(.5),
                      ),
                    ),
                    validator: (value) =>
                        value == null ? 'Please select your country' : null,
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
                  height: 10,
                ),
                Text("City",
                    style: TextStyle(
                        color: UIColors.primaryDarkColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 12.sp)),
                SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: CustomDecoration().textFieldDecoration(),
                  child: DropdownButtonFormField(
                    hint: Text(
                      'Please select your city',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ), // Not necessary for Option 1
                    decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(10, 12, 5, 12),
                      prefixIcon: Icon(
                        Icons.my_location,
                        color: Colors.grey.withOpacity(.5),
                      ),
                    ),
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
                  height: 10,
                ),
                Text("Withdrawal Method",
                    style: TextStyle(
                        color: UIColors.primaryDarkColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 12.sp)),
                SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: CustomDecoration().textFieldDecoration(),
                  child: DropdownButtonFormField(
                    hint: Text(
                      'Withdrawal Method',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ), // Not necessary for Option 1
                    decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        prefixIcon: Icon(
                          CupertinoIcons.money_dollar_circle,
                          color: Colors.grey.withOpacity(.5),
                        ),
                        contentPadding: EdgeInsets.fromLTRB(10, 12, 5, 12)),
                    validator: (value) => value == null
                        ? 'Please select your withdrawal method'
                        : null,
                    isExpanded: true,
                    value: _selectedWithdrawalMethod,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedWithdrawalMethod = newValue;
                      });
                    },
                    items: withdrawalMethods.map((value) {
                      return DropdownMenuItem(
                        child: new Text(value.title),
                        value: value.sId,
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Account No",
                    style: TextStyle(
                        color: UIColors.primaryDarkColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 12.sp)),
                SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: CustomDecoration().textFieldDecoration(),
                  child: TextFormField(
                    controller: accountController,
                    validator: (value) {
                      if (value!.length == 0) {
                        return "Please enter your account no";
                      } else
                        return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      prefixIcon: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.grey.withOpacity(.5),
                      ),
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(.8)),
                      hintText: "Account No",
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: Get.width,
                  child: TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(UIColors.buttonColor),
                          padding:
                              MaterialStateProperty.all(EdgeInsets.all(15)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(200.0),
                          ))),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Network().userUpdate(
                              nameController.text,
                              phoneController.text,
                              _selectedGender.toString(),
                              _selectedCountry,
                              _selectedCity,
                              _selectedWithdrawalMethod,
                              accountController.text);
                        }
                      },
                      child: Text(
                        "Submit",
                        style: TextStyle(color: Colors.white, fontSize: 15.sp),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
