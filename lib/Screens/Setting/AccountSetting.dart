import 'package:best_browser/Utils/Decoration.dart';
import 'package:best_browser/Utils/UI_Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class AccountSetting extends StatefulWidget {
  @override
  _AccountSettingState createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController cityController = new TextEditingController();
  TextEditingController accountController = new TextEditingController();

  bool termsChecked = false;

  List<String> genders = ['Male', 'Female', 'Others'];
  var _selectedGender;

  List<String> withdrawalMethods = ['bKash', 'Rocket', 'Nogod'];
  var _selectedMethod;

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
        padding: EdgeInsets.all(15),
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
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
                  validator: (value) {
                    if (value!.length == 0) {
                      return "Please enter your email";
                    } else
                      return null;
                  },
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
                  keyboardType: TextInputType.text,
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
                      prefixIcon: Image.asset('assets/images/gender_icon.png'),
                      contentPadding: EdgeInsets.fromLTRB(10, 12, 5, 12)),
                  validator: (value) =>
                      value == null ? 'Please select your Gender' : null,
                  isExpanded: true,
                  value: _selectedGender,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  items: genders.map((category) {
                    return DropdownMenuItem(
                      child: new Text(category),
                      value: category,
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
                child: TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value!.length == 0) {
                      return "Please enter your city";
                    } else
                      return null;
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    prefixIcon: Icon(
                      CupertinoIcons.location_circle,
                      color: Colors.grey.withOpacity(.5),
                    ),
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(.8)),
                    hintText: "City",
                  ),
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
                  value: _selectedMethod,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedMethod = newValue;
                    });
                  },
                  items: withdrawalMethods.map((category) {
                    return DropdownMenuItem(
                      child: new Text(category),
                      value: category,
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
                  keyboardType: TextInputType.text,
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
                        padding: MaterialStateProperty.all(EdgeInsets.all(15)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(200.0),
                        ))),
                    onPressed: () {
                      // Get.toNamed('/auth/login');
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
    );
  }
}
