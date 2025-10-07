import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/status/statusmodel.dart';
import '../service/captain_emirates_apiservice.dart';
import '../ui/constant/pref.dart';

class StatusController extends GetxController {
  var statuslist = <Statuslist>[].obs;
  var isCheckedIn = false.obs;
  var buttonAction = "checkin".obs;
  var lastCheckedInTime = "".obs;
  var lastSalesOrderId = "".obs;

  final apiService api;

  StatusController({required this.api});

  /// Fetch the current check-in status
  Future<void> getStatus() async {
    print("🔹 getStatus called");

    String? empId = Prefs.getID("EmpId");
    print("📌 Retrieved empId: $empId");

    if (empId == null || empId.isEmpty) {
      print("⚠️ empId is null or empty → defaulting to 'checkin'");
      buttonAction.value = "checkin";
      isCheckedIn.value = false;
      await refreshAll();
      return;
    }

    Map<String, dynamic> postData = {"employeeId": empId};
    print("📤 Sending postData to API: $postData");

    try {
      var result = await apiService.getstatus(postData);
      print("📩 Raw API Response: ${result.body}");

      GetstatusModel response = getstatusModelFromJson(result.body);
      print("✅ Parsed API Response: $response");

      final prefs = await SharedPreferences.getInstance();

      if (response.status && response.data.isNotEmpty) {
        statuslist.value = response.data;
        print("📊 statuslist updated with ${statuslist.length} records");

        Statuslist latest = statuslist.last;
        if (latest.timeOut == null) {
          isCheckedIn.value = true;
          buttonAction.value = "checkout";
          lastCheckedInTime.value = latest.timeIn.toString();
          lastSalesOrderId.value = latest.internalId?.toString() ?? "";

          await prefs.setBool("isCheckedIn", true);
          await prefs.setString("timeIn", lastCheckedInTime.value);
          await prefs.setString("LAST_INTERNAL_ID", lastSalesOrderId.value);

          print(
            "✅ User is checked in → internalId: ${latest.internalId}, timeIn: ${latest.timeIn}",
          );
        } else {
          isCheckedIn.value = false;
          buttonAction.value = "checkin";

          await prefs.setBool("isCheckedIn", false);
          await prefs.remove("timeIn");
          await prefs.remove("LAST_INTERNAL_ID");

          print("ℹ️ User already checked out → ready for next check-in");
        }
      } else {
        statuslist.clear();
        isCheckedIn.value = false;
        buttonAction.value = "checkin";

        await prefs.setBool("isCheckedIn", false);
        await prefs.remove("timeIn");
        await prefs.remove("LAST_INTERNAL_ID");

        print("⚠️ No check-in records found → state cleared");
      }

      await refreshAll();

    } catch (e, stackTrace) {
      isCheckedIn.value = false;
      buttonAction.value = "checkin";
      print("❌ Exception in getStatus: $e");
      print("📝 StackTrace: $stackTrace");

      await refreshAll();
    }
  }

  /// Refresh reactive UI
  Future<void> refreshAll() async {
    print("🔄 refreshAll called");
    print("🔹 Current reactive values:");
    print("   isCheckedIn: ${isCheckedIn.value}");
    print("   buttonAction: ${buttonAction.value}");
    print("   lastCheckedInTime: ${lastCheckedInTime.value}");
    print("   lastSalesOrderId: ${lastSalesOrderId.value}");
    print("   statuslist length: ${statuslist.length}");

    statuslist.refresh();

    print("✅ refreshAll completed");
  }
}
