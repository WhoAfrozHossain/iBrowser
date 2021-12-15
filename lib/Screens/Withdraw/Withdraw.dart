import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iBrowser/PoJo/UserModel.dart';
import 'package:iBrowser/PoJo/WithdrawalMethodModel.dart';
import 'package:iBrowser/PoJo/WithdrawalRequestModel.dart';
import 'package:iBrowser/Service/Network.dart';
import 'package:iBrowser/Utils/Decoration.dart';
import 'package:iBrowser/Utils/UI_Colors.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class Withdraw extends StatefulWidget {
  @override
  _WithdrawState createState() => _WithdrawState();
}

class _WithdrawState extends State<Withdraw> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // TextEditingController nameController = new TextEditingController();
  // TextEditingController emailController = new TextEditingController();
  // TextEditingController phoneController = new TextEditingController();
  // TextEditingController cityController = new TextEditingController();
  TextEditingController accountController = new TextEditingController();
  TextEditingController amountController = new TextEditingController();

  List<WithdrawalRequestModel> withdrawalRequests = [];

  List<WithdrawalMethodModel> withdrawalMethods = [];
  var _selectedWithdrawalMethod;

  UserModel? userData;

  @override
  void initState() {
    getUserInfo();

    super.initState();
  }

  getUserInfo() {
    Network().getUserData().then((value) {
      setState(() {
        userData = value;
        accountController.text = userData!.accountNo!;
        getWithdrawMethod();
        getWithdrawalRequests();
      });
    });
  }

  getWithdrawMethod() {
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
  }

  getWithdrawalRequests() {
    Network().getWithdrawalRequests().then((value) {
      setState(() {
        withdrawalRequests = value;
      });
    });
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
          'Withdraw',
        ),
        backgroundColor: UIColors.primaryDarkColor,
        elevation: 0,
      ),
      backgroundColor: UIColors.backgroundColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            if (userData != null)
              Container(
                width: Get.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  gradient: new LinearGradient(
                      colors: [
                        UIColors.primaryColor,
                        UIColors.primaryDarkColor,
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/dashboard_icon_01.png',
                      width: 50,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Present Balance",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12.sp),
                          ),
                          Text(
                            userData!.walletAmount.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30.sp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.white),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          prefixIcon: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.grey.withOpacity(.5),
                          ),
                          border: InputBorder.none,
                          hintStyle:
                              TextStyle(color: Colors.grey.withOpacity(.8)),
                          hintText: "Account No",
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Amount",
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
                        controller: amountController,
                        validator: (value) {
                          if (value!.length == 0) {
                            return "Please enter withdrawal amount";
                          } else if (int.parse(value) >
                              userData!.walletAmount!) {
                            return "Invalid withdrawal amount";
                          } else
                            return null;
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: Colors.grey.withOpacity(.5),
                          ),
                          border: InputBorder.none,
                          hintStyle:
                              TextStyle(color: Colors.grey.withOpacity(.8)),
                          hintText: "Amount",
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
                              backgroundColor: MaterialStateProperty.all(
                                  UIColors.buttonColor),
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.all(15)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(200.0),
                              ))),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Network()
                                  .createWithdrawRequest(
                                      _selectedWithdrawalMethod,
                                      accountController.text,
                                      amountController.text)
                                  .then((value) => getUserInfo());
                            }
                          },
                          child: Text(
                            "Send Request",
                            style:
                                TextStyle(color: Colors.white, fontSize: 15.sp),
                          )),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            if (withdrawalRequests.length > 0)
              Container(
                  width: Get.width,
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: withdrawalRequests.length,
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return withdrawItem(withdrawalRequests[index]);
                    },
                  )),
          ],
        ),
      ),
    );
  }

  withdrawItem(WithdrawalRequestModel item) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(item.accountNo!), Text(item.amount!.toString())],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.status!),
            Text(DateFormat.yMMMd().format(DateTime.parse(item.createdAt!)))
          ],
        ),
        if (item.note != "")
          Container(
            width: Get.width,
            child: Text(
              item.note!,
              textAlign: TextAlign.justify,
            ),
          )
      ],
    );
  }
}
