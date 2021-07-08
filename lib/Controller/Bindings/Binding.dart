import 'package:best_browser/Controller/Controller.dart';
import 'package:get/get.dart';

class BindingControllers extends Bindings {
  @override
  void dependencies() {
    Get.put<Controller>(Controller(), permanent: true);
  }
}
