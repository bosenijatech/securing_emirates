import 'package:get/get.dart';

//estimate
class TaxController extends GetxController {
  var taxtype = ''.obs;
}


class EstimateController extends GetxController {
  RxBool isAvailableEstimate = false.obs;

  void toggleEstimate(bool value) {
    isAvailableEstimate.value = value;
  }
}