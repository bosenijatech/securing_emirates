

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../getx_contoller.dart/stauts_contoller.dart';
import '../../model/timesheetmodel/updatetimemodel.dart';
import '../../service/captain_emirates_apiservice.dart';
import '../constant/app_color.dart';
import '../widgets/custom_textfield.dart';
import '../../service/comFuncService.dart';

class Checkoutscreen extends StatefulWidget {
  final String internalId;
  final String timeIn;

  const Checkoutscreen({
    super.key,
    required this.internalId,
    required this.timeIn,
  });

  @override
  State<Checkoutscreen> createState() => _CheckoutscreenState();
}

class _CheckoutscreenState extends State<Checkoutscreen> {
  final StatusController statusController = Get.find();
  TextEditingController? salesnumController;
  TextEditingController remark = TextEditingController();

  bool isLoading = false;
  String workedTimeStr = "0 mins";

  @override
 @override
void initState() {
  super.initState();

  print("✅ Checkoutscreen initState called");
  salesnumController = TextEditingController(text: "❌ Not Found");

  // Try from controller first
  if (statusController.statuslist.isNotEmpty) {
    final latest = statusController.statuslist.last;
    salesnumController!.text = latest.salesOrderId ?? "❌ Not Found";
    print("📌 Loaded from statuslist: ${latest.salesOrderId}");
  } else {
    // Try from SharedPreferences as last fallback
    SharedPreferences.getInstance().then((prefs) {
      final lastSalesOrderId = prefs.getString("LAST_SALES_ORDER_ID") ?? "";
      if (lastSalesOrderId.isNotEmpty) {
        setState(() {
          salesnumController!.text = lastSalesOrderId;
        });
        print("📦 Loaded from SharedPrefs: $lastSalesOrderId");
      } else {
        print("⚠️ No salesOrderId found anywhere!");
      }
    });
  }

  calculateWorkedTime();
}
  
  void calculateWorkedTime() {
    if (statusController.statuslist.isEmpty) {
      print("⚠️ No status entries to calculate worked time");
      return;
    }

    final latest = statusController.statuslist.last;
    final timeInStr = latest.timeIn;
    final timeOutStr = latest.timeOut;

    print("⏱ Calculating worked time -> timeIn: $timeInStr, timeOut: $timeOutStr");

    if (timeInStr == null) return;

    DateTime now = DateTime.now();
    DateTime timeIn = parseTime(timeInStr, now);
    DateTime timeOut = timeOutStr != null ? parseTime(timeOutStr, now) : now;

    if (timeOut.isBefore(timeIn)) timeOut = timeOut.add(const Duration(days: 1));

    Duration diff = timeOut.difference(timeIn);
    setState(() {
      workedTimeStr = formatDuration(diff);
    });

    print("⏱ Worked time calculated: $workedTimeStr (${diff.inMinutes} minutes)");
  }

  String formatDuration(Duration diff) {
    int hours = diff.inHours;
    int minutes = diff.inMinutes % 60;
    if (hours == 0) return "$minutes mins";
    return "$hours hrs $minutes mins";
  }

  DateTime parseTime(String timeStr, DateTime now) {
    try {
      timeStr = timeStr.trim().toLowerCase();
      bool isPM = timeStr.contains('pm');
      bool isAM = timeStr.contains('am');

      timeStr = timeStr.replaceAll(RegExp(r'\s*(am|pm)'), '');
      List<String> parts = timeStr.split(":");
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      if (isPM && hour < 12) hour += 12;
      if (isAM && hour == 12) hour = 0;

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      print("⚠️ Failed to parse time '$timeStr': $e");
      return now;
    }
  }

  Future<void> updatetimesheet() async {
    if (statusController.statuslist.isEmpty &&
        statusController.lastSalesOrderId.value.isEmpty) {
      showInSnackBar(context, "❌ No check-in record found!");
      print("⚠️ Checkout failed -> statusController empty");
      return;
    }

    setState(() => isLoading = true);

    try {
      final latest = statusController.statuslist.isNotEmpty
          ? statusController.statuslist.last
          : null;

      String internalId =
          latest?.internalId?.toString() ?? widget.internalId.toString();
      String timeInStr = latest?.timeIn ?? widget.timeIn;
      String currentTime = DateFormat("HH:mm").format(DateTime.now());
      String salesOrderId = latest?.salesOrderId ??
          statusController.lastSalesOrderId.value;

      print(
          "📌 Checkout details -> internalId: $internalId, timeIn: $timeInStr, currentTime: $currentTime, salesOrderId: $salesOrderId");

      // Calculate hours worked
      DateTime timeIn = parseTime(timeInStr, DateTime.now());
      DateTime timeOut = parseTime(currentTime, DateTime.now());
      if (timeOut.isBefore(timeIn)) timeOut = timeOut.add(const Duration(days: 1));
      Duration diff = timeOut.difference(timeIn);
      double hoursWorked = diff.inMinutes / 60;

      print("⏱ Hours worked: $hoursWorked");

      Map<String, dynamic> postData = {
        "internalId": internalId,
        "timeIn": timeInStr,
        "timeOut": currentTime,
        "hoursWorked": hoursWorked.toStringAsFixed(2),
        "remarks": remark.text.trim(),
      };

      print('📤 Checkout postData: $postData');

      var result = await apiService.updatetimesheet(postData);
      print('📥 API Response: ${result.body}');
      UpdatetimeModel response = updatetimeModelFromJson(result.body);

      if (response.status == true) {
        showInSnackBar(context, "✅ Timesheet checkout successful!");
        print("✅ Checkout success");

        // Update controller states
        statusController.isCheckedIn.value = false;

        // Clear the last status entry (if any)
        if (statusController.statuslist.isNotEmpty) {
          statusController.statuslist.remove(latest);
        }

        // Clear saved internalId
        final prefs = await SharedPreferences.getInstance();
        prefs.remove("LAST_INTERNAL_ID");
        prefs.setBool("isCheckedIn", false);

        // Navigate back to home
        if (mounted) Navigator.pushReplacementNamed(context, "/home");
      } else {
        showInSnackBar(context, "❌ Checkout failed: ${response.message}");
        print("❌ Checkout failed -> API returned false: ${response.message}");
      }
    } catch (e, stack) {
      print("🔥 Exception: $e\n$stack");
      showInSnackBar(context, "❌ Error during checkout: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("📱 Building Checkoutscreen UI -> workedTimeStr: $workedTimeStr");
    return Scaffold(
      appBar: AppBar(title: const Text("Check Out")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomRoundedTextField(
              width: double.infinity,
              type: TextInputType.text,
              labelText: 'Sales Order Number',
              control: salesnumController,
              readOnly: true,
            ),
           
           
            const SizedBox(height: 24),
            CustomRoundedTextField(
              width: double.infinity,
              type: TextInputType.text,
              labelText: 'Note',
              control: remark,
              lines: 5,
              verticalMargin: 16,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isLoading ? null : updatetimesheet,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Check Out",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
       
          ],
        ),
      ),
    );
  }
}
