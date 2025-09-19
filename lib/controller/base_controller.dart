import 'package:get/get.dart';

class BaseController extends GetxController {
  RxBool isDarkModeEnabled = false.obs;
  RxInt currentIndex = 0.obs;
  String? fbUserId;

  RxMap<String, dynamic> filterData = <String, dynamic>{}.obs;

  void updateFilterData(Map<String, dynamic> newData) {
    filterData.assignAll(newData);
  }

  Map<String, dynamic> getFilterData() {
    return filterData;
  }
}