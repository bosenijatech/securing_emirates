


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/regularization/addregularizationmodel.dart';
import '../../service/captain_emirates_apiservice.dart';
import '../widgets/custom_textfield.dart';
import '../../ui/constant/constant.dart';

class Regularizescreen extends StatefulWidget {
  final String date;
  final String checkIn;
  final String checkOut;
  final String internalId;
  final String employee;
  final String hoursWorked;
  final String salesOrderId;

  const Regularizescreen({
    super.key,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.internalId,
    required this.employee,
    required this.hoursWorked,
    required this.salesOrderId,
  });

  @override
  State<Regularizescreen> createState() => _RegularizescreenState();
}

class _RegularizescreenState extends State<Regularizescreen> {
  final TextEditingController noteController = TextEditingController();
  late DateTime apiDate;
  late TimeOfDay checkInTime;
  late TimeOfDay checkOutTime;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    apiDate = _parseDate(widget.date);
    checkInTime = _stringToTimeOfDay(widget.checkIn);
    checkOutTime = _stringToTimeOfDay(widget.checkOut);
  }

  DateTime _parseDate(String date) {
    try {
      final cleanedDate = date.trim();
      if (cleanedDate.contains("-")) {
        // Try dd-MM-yyyy first
        try {
          return DateFormat("dd-MM-yyyy").parse(cleanedDate);
        } catch (_) {
          // Try yyyy-MM-dd
          return DateFormat("yyyy-MM-dd").parse(cleanedDate);
        }
      } else if (cleanedDate.contains("/")) {
        return DateFormat("dd/MM/yyyy").parse(cleanedDate);
      }
      return DateTime.now();
    } catch (_) {
      return DateTime.now();
    }
  }

  TimeOfDay _stringToTimeOfDay(String time) {
    if (time.isEmpty || time == "-" || time.toLowerCase() == "null") {
      return const TimeOfDay(hour: 0, minute: 0);
    }
    try {
      final cleaned = time.trim();
      if (cleaned.contains(":")) {
        final parts = cleaned.split(RegExp(r'[:\s]'));
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        if (parts.length > 2) {
          String period = parts[2].toUpperCase();
          if (period == "PM" && hour != 12) hour += 12;
          if (period == "AM" && hour == 12) hour = 0;
        }
        return TimeOfDay(hour: hour, minute: minute);
      }
      int hour = int.tryParse(cleaned) ?? 0;
      return TimeOfDay(hour: hour, minute: 0);
    } catch (_) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  // 24-hour format for API
  String formatTimeOfDay24(TimeOfDay time) {
    return time.hour.toString().padLeft(2, '0') +
        ":" +
        time.minute.toString().padLeft(2, '0');
  }

  // 12-hour format for UI
  String formatTimeOfDay12(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  Future<void> addRegularization() async {
    if (noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("⚠️ Note cannot be empty")));
      return;
    }

    setState(() => isLoading = true);

    try {
      // Format times for API
      String timeIn = formatTimeOfDay24(checkInTime);
      String timeOut = formatTimeOfDay24(checkOutTime);

      // Build DateTime objects
      DateTime inDateTime = DateTime(
        apiDate.year,
        apiDate.month,
        apiDate.day,
        checkInTime.hour,
        checkInTime.minute,
      );
      DateTime outDateTime = DateTime(
        apiDate.year,
        apiDate.month,
        apiDate.day,
        checkOutTime.hour,
        checkOutTime.minute,
      );

      // Adjust if outDateTime is before inDateTime (next day)
      if (outDateTime.isBefore(inDateTime)) {
        outDateTime = outDateTime.add(const Duration(days: 1));
      }

      // Calculate hours worked in decimal
      Duration difference = outDateTime.difference(inDateTime);
      double hoursWorkedDecimal = difference.inMinutes / 60;

      // Format date for API
      String formattedDate = DateFormat("dd-MM-yyyy").format(apiDate);

      // Get shift ID safely
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? shiftString = prefs.getString("shiftId");
      int shiftMasterId = int.tryParse(shiftString ?? '') ?? 1;

      // Prepare POST data
      Map<String, dynamic> postData = {
        "timesheetRef": widget.internalId,
        "attendanceDate": formattedDate,
        "employee": widget.employee,
        "salesOrderId": widget.salesOrderId,
        "timeIn": timeIn,
        "timeOut": timeOut,
        "hoursWorked": hoursWorkedDecimal,
        "note": noteController.text.trim(),
        "shiftMaster": shiftMasterId.toString(),
      };

      // Call API
      var result = await apiService.addregularization(postData);

      // Decode response safely
      AddRegularizationModel response;
      try {
        final decoded = json.decode(result.body);
        response = AddRegularizationModel.fromJson(decoded);
      } catch (_) {
        response = AddRegularizationModel(status: false, message: result.body);
      }

      // Handle response
      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Added successfully"),
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) Get.back(result: true);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: ${response.message}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("🔥 Error: $e")));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _pickCheckInTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: checkInTime,
    );
    if (picked != null) setState(() => checkInTime = picked);
  }

  Future<void> _pickCheckOutTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: checkOutTime,
    );
    if (picked != null) setState(() => checkOutTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Regularize")),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.primarylight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "${DateFormat("dd-MM-yyyy").format(apiDate)}, ${DateFormat('EEEE').format(apiDate)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _timePickerColumn(
                        "Check In",
                        checkInTime,
                        _pickCheckInTime,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _timePickerColumn(
                        "Check Out",
                        checkOutTime,
                        _pickCheckOutTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomRoundedTextField(
                  width: double.infinity,
                  type: TextInputType.text,
                  labelText: 'Note',
                  control: noteController,
                  lines: 5,
                  verticalMargin: 16,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.sec_red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading ? null : addRegularization,
                          child: const Text(
                            "Request",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _timePickerColumn(String label, TimeOfDay time, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.primarylight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                formatTimeOfDay12(time), // 12-hour format
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
