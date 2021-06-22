import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';

class MerchantNetwork {
  String rootUrl = 'https://i-browser-api.herokuapp.com/api/';

  var http = Client();

  final pref = GetStorage();

  // Future<MerchantDashboardModel> getMerchantDashboardData() async {
  //   var jsonData;
  //   var response = await http.get(
  //       Uri.parse(rootUrl + "api/merchant/dashboard/report"),
  //       headers: {'id': json.encode(pref.read("userId"))});
  //   jsonData = json.decode(response.body);
  //
  //   return MerchantDashboardModel.fromJson(jsonData);
  // }

  // Future<List<NearestZoneModel>> getNearestZones() async {
  //   var jsonData;
  //   var response = await http.get(Uri.parse(rootUrl + "api/nearestZone"));
  //   jsonData = json.decode(response.body);
  //
  //   List<NearestZoneModel> zones = jsonData.map<NearestZoneModel>((json) {
  //     return NearestZoneModel.fromJson(json);
  //   }).toList();
  //
  //   return zones;
  // }

  // createParcel(
  //     String name,
  //     String phoneNumber,
  //     String address,
  //     String invoiceNo,
  //     String weight,
  //     int parcelType,
  //     String cod,
  //     String productPrice,
  //     int receiveZone,
  //     String note,
  //     int deliveryCharge,
  //     int extraDeliveryCharge,
  //     int codCharge,
  //     int orderType,
  //     int codType) async {
  //   Loading().show();
  //
  //   Map<String, dynamic> data = {
  //     'name': name,
  //     'phoneNumber': phoneNumber,
  //     'address': address,
  //     'invoiceNo': invoiceNo,
  //     'weight': weight,
  //     'percelType': json.encode(parcelType),
  //     'cod': cod,
  //     'productPrice': productPrice,
  //     'reciveZone': json.encode(receiveZone),
  //     'note': note,
  //     'deliveryCharge': json.encode(deliveryCharge),
  //     'extraDeliveryCharge': json.encode(extraDeliveryCharge),
  //     'codCharge': json.encode(codCharge),
  //     'orderType': json.encode(orderType),
  //     'codType': json.encode(codType)
  //   };
  //   var jsonData;
  //   var response = await http.post(
  //       Uri.parse(rootUrl + "api/merchant/parcel/create"),
  //       headers: {
  //         'id': json.encode(pref.read("userId")),
  //         'Accept': 'application/json'
  //       },
  //       body: data,
  //       encoding: Encoding.getByName("utf-8"));
  //
  //   jsonData = json.decode(response.body);
  //
  //   Loading().dismiss();
  //
  //   CustomDialog(Get.context,
  //       title: 'Message',
  //       body: jsonData['message'],
  //       isOkButton: true,
  //       okButtonText: "OK", okButtonClick: () {
  //     Get.back();
  //     Get.back();
  //   }).show();
  // }

}
