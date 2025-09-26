

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:securing_emirates/model/timesheetmodel/updatetimemodel.dart';
import 'package:intl/intl.dart';

import '../../global/global_data.dart';
import '../../model/regularization/getregularizationlistmodel.dart';
import '../../service/captain_emirates_apiservice.dart';
import '../../service/comFuncService.dart';
import '../constant/app_color.dart';
import '../widgets/custom_textfield.dart';

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
   TextEditingController? salesnumController;
  bool isLoading = false;
  String workedTimeStr = "0 mins";
   TextEditingController remark = TextEditingController();
   

  @override
  void initState() {
    super.initState();
    // salesnumController = TextEditingController(text: widget.internalId);
     final record = GlobalData.salesOrderMap[widget.internalId];
if (GlobalData.salesOrderMap.isNotEmpty) {
  final lastKey = GlobalData.salesOrderMap.keys.first;
  final lastRecord = GlobalData.salesOrderMap[lastKey];

  print("Last SalesOrderId: $lastKey");
  print("Record: ${lastRecord?.employee}");

  salesnumController = TextEditingController(
    text: lastRecord?.salesOrderId?.toString() ?? "❌ Not Found",
  );
} else {
  salesnumController = TextEditingController(text: "❌ Not Found");
}
  
    print("✅ Checkoutscreen -> internalId: ${widget.internalId}");
    saveInternalId(widget.internalId);

  }
Future<void> saveInternalId(String id) async {
  final prefs = await SharedPreferences.getInstance();
  const String kLastInternalIdKey = "LAST_INTERNAL_ID";
  if (prefs.getString(kLastInternalIdKey) == null) {
    await prefs.setString(kLastInternalIdKey, id);
    print("💾 Saved internalId to prefs: $id");
  }
}
  /// Format duration for UI display
  String formatDuration(Duration diff) {
    int hours = diff.inHours;
    int minutes = diff.inMinutes % 60;
    if (hours == 0) {
      return "$minutes mins";
    } else {
      return "$hours hrs $minutes mins";
    }
  }

  /// Safely parse time string (handles 24h or 12h formats)
  DateTime parseTime(String timeStr, DateTime now) {
    try {
      timeStr = timeStr.trim().toLowerCase();
      bool isPM = timeStr.contains('pm');
      bool isAM = timeStr.contains('am');

      // Remove AM/PM if present
      timeStr = timeStr.replaceAll(RegExp(r'\s*(am|pm)'), '');

      List<String> parts = timeStr.split(":");
      if (parts.length != 2) throw FormatException("Invalid time format");

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      // Convert 12-hour to 24-hour
      if (isPM && hour < 12) hour += 12;
      if (isAM && hour == 12) hour = 0;

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      print("⚠️ Failed to parse time '$timeStr': $e");
      return now; // fallback to current time
    }
  }

  /// Calculate hours worked (decimal)
  Future<double> calculateHoursWorked() async {
    final prefs = await SharedPreferences.getInstance();
    String? timeInStr = prefs.getString("timeIn");
    String? timeOutStr = prefs.getString("timeOut");

    if (timeInStr == null || timeOutStr == null) return 0.0;

    DateTime now = DateTime.now();
    DateTime timeIn = parseTime(timeInStr, now);
    DateTime timeOut = parseTime(timeOutStr, now);

    // Handle checkout after midnight
    if (timeOut.isBefore(timeIn)) {
      timeOut = timeOut.add(Duration(days: 1));
    }

    Duration difference = timeOut.difference(timeIn);
    setState(() {
      workedTimeStr = formatDuration(difference);
    });

    double hoursWorked = difference.inMinutes / 60;
    return double.parse(hoursWorked.toStringAsFixed(2));
  }

  /// Save checkout time in 24-hour format
  Future<void> saveCheckoutTime() async {
    final prefs = await SharedPreferences.getInstance();
    String nowStr = DateFormat("HH:mm").format(DateTime.now());
    print("💾 Saving checkout time: $nowStr");
    await prefs.setString("timeOut", nowStr);
  }

  /// Update timesheet
  Future<void> updatetimesheet() async {
  final prefs = await SharedPreferences.getInstance();
  bool? isCheckedIn = prefs.getBool("isCheckedIn");
  String? timeInStr = prefs.getString("timeIn");

  // 1️⃣ Check if user is checked in
  if (isCheckedIn != true || timeInStr == null) {
    showInSnackBar(context, "❌ You are not checked in!");
    return;
  }

  setState(() => isLoading = true);

  try {
    // 2️⃣ Save checkout time (assuming this updates prefs "timeOut")
    await saveCheckoutTime();
    String currentTime = prefs.getString("timeOut") ?? "00:00";

    // 3️⃣ Calculate hours worked
    double hoursWorked = await calculateHoursWorked();

    // 4️⃣ Retrieve last internalId (use consistent key)
    const String kLastInternalIdKey = "LAST_INTERNAL_ID";
    String? lastInternalId = prefs.getString(kLastInternalIdKey);

    if (lastInternalId == null) {
      showInSnackBar(context, "❌ No internalId found for checkout!");
      setState(() => isLoading = false);
      return;
    }

    // 5️⃣ Prepare post data
    Map<String, dynamic> postData = {
      "internalId": lastInternalId,
      "timeIn": timeInStr,
      "timeOut": currentTime,
      "hoursWorked": hoursWorked.toStringAsFixed(2),
        "remarks": remark.text.trim(),

    };

    print('📤 Checkout postData: $postData');

    // 6️⃣ Call API
    var result = await apiService.updatetimesheet(postData);
    print('📥 Raw API Response: ${result.body}');

    UpdatetimeModel response = updatetimeModelFromJson(result.body);

    if (response.status == true) {
      // 7️⃣ Successful checkout
      await prefs.remove("timeIn");
      await prefs.remove(kLastInternalIdKey);
      await prefs.setBool("isCheckedIn", false);

      showInSnackBar(context, "✅ Timesheet checkout successful!");

      if (mounted) Navigator.pushReplacementNamed(context, "/home");
    } else {
      // 8️⃣ API returned failure
      showInSnackBar(context, "❌ Checkout failed: ${response.message}");
      await prefs.setBool("isCheckedIn", true);
    }
  } catch (e, stack) {
    // 9️⃣ Handle exceptions
    print("🔥 Exception: $e");
    print("🔥 StackTrace: $stack");
    showInSnackBar(context, "❌ Error during checkout: $e");
    await prefs.setBool("isCheckedIn", true);
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    print("📱 Building Checkoutscreen UI");
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text("Check Out")),
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
              child: 
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
          ],
        ),
      ),
    );
  }
}
