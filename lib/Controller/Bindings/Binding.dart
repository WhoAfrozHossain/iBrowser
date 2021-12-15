import 'package:get/get.dart';
import 'package:iBrowser/Controller/Controller.dart';

class BindingControllers extends Bindings {
  @override
  void dependencies() {
    Get.put<Controller>(Controller(), permanent: true);
  }
}
