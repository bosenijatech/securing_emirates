

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/src/response.dart';
import 'package:securing_emirates/model/loginpage/loginmodel.dart';
import 'package:securing_emirates/ui/constant/app_color.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:securing_emirates/ui/constant/pref.dart';
import 'package:securing_emirates/ui/screens/checkoutscreen.dart';
import 'package:securing_emirates/ui/screens/employeereportspage.dart';
import 'package:securing_emirates/ui/screens/profilescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../controller/base_controller.dart';
import '../../getx_contoller.dart/stauts_contoller.dart';
import '../../model/getmonthlyattendance/getmonthlyattendancemodel.dart';
import '../../model/status/statusmodel.dart';
import '../../model/timesheetmodel/addtimesheetmodel.dart';
import '../../service/captain_emirates_apiservice.dart';
import '../../service/comFuncService.dart';
import '../authscreen/auth_validation.dart';
import '../authscreen/landingscreen.dart';
import '../authscreen/loginscreen.dart';
import '../constant/app_assets.dart';
import '../widgets/app_utils.dart';
import 'checkinpage.dart';

class Homepage extends StatefulWidget {
  final String employeeName;
  final String supervisorId;
  final String supervisor;

  const Homepage({
    super.key,
    required this.employeeName,
    required this.supervisorId,
    required this.supervisor,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  BaseController baseCtrl = Get.put(BaseController());
  AuthValidation authValidation = AuthValidation();
  String employeeName = "";
  String supervisorId = "";
  String supervisor = "";
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, dynamic>? _selectedData;
  bool isCheckedIn = false;
  bool isLoading = false;
  String lastCheckedInTime = "";
  String? lastSalesOrderId;
  List<Attendance> monthlyattendance = [];
  String lastCheckoutTime = "";
  final StatusController statusController = Get.put(StatusController(api: apiService()));
  @override
  void initState() {
    super.initState();
    CheckinState();
    getMonthlyAttendanceForMonth(_focusedDay);
    loadEmployeeName();
    getstatus();
 statusController.getStatus();
    // Initialize selected day to today
    _selectedDay = DateTime.now();
  }

  Future<void> loadEmployeeName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeName = widget.employeeName.isNotEmpty
          ? widget.employeeName
          : prefs.getString("Name") ?? "Employee";
    });
  }

  List<Statuslist> statuslist = []; // Global or inside State

  Future<String> getstatus() async {
    print("🔹 getstatus called");

    String? empId = Prefs.getID("EmpId");
    print("📌 Retrieved empId: $empId");

    if (empId == null || empId.isEmpty) {
      print("⚠️ empId is null or empty → returning 'checkin'");
      return "checkin";
    }

    Map<String, dynamic> postData = {"employeeId": empId};
    print("📤 Sending postData: $postData");

    try {
      var result = await apiService.getstatus(postData);
      print("📩 Raw API Response: ${result.body}");

      GetstatusModel response = getstatusModelFromJson(result.body);
      print("✅ Parsed API Response: $response");

      if (!mounted) {
        print("⚠️ Widget not mounted → returning 'checkin'");
        return "checkin";
      }

      bool checkInState = false;
      String buttonAction = "checkin";
      statuslist = response.data;
      print("📊 Status list: $statuslist");

      final prefs = await SharedPreferences.getInstance();
      print("💾 SharedPreferences instance acquired");

      if (response.status && statuslist.isNotEmpty) {
        print("✅ API status true & statuslist not empty");

        // ✅ Take only the latest record
        Statuslist latest = statuslist.last;
        print("📌 Latest record: $latest");

        if (latest.timeOut == null) {
          // 👉 User is still checked in
          checkInState = true;
          buttonAction = "checkout";

          lastCheckedInTime = latest.timeIn.toString();
          lastSalesOrderId = latest.internalId?.toString() ?? "";

          // 🔥 Save only the latest check-in state
          await prefs.setBool("isCheckedIn", true);
          await prefs.setString("timeIn", lastCheckedInTime!);
          await prefs.setString("LAST_INTERNAL_ID", lastSalesOrderId!);

          print(
            "✅ Checked in → internalId: ${latest.internalId}, timeIn: ${latest.timeIn}",
          );
          await refreshAll();
        } else {
          // 👉 Already checked out
          checkInState = false;
          buttonAction = "checkin";

          await prefs.setBool("isCheckedIn", false);
          await prefs.remove("timeIn");
          await prefs.remove("LAST_INTERNAL_ID");

          print("ℹ️ Already checked out → waiting for new check-in");
          await refreshAll();
        }
      } else {
        // 👉 No records
        statuslist = [];
        await prefs.setBool("isCheckedIn", false);
        await prefs.remove("timeIn");
        await prefs.remove("LAST_INTERNAL_ID");

        print("⚠️ No check-in data found → cleared saved state");
        await refreshAll();
      }

      setState(() => isCheckedIn = checkInState);
      print(
        "🎯 Final checkInState: $checkInState, buttonAction: $buttonAction",
      );

      return buttonAction;
    } catch (e, stackTrace) {
      if (mounted) setState(() => isCheckedIn = false);
      print("❌ Error in getstatus: $e");
      print("📝 StackTrace: $stackTrace");
      return "checkin";
    }
  }

  Future<void> CheckinState() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isCheckedIn = prefs.getBool("isCheckedIn") ?? false;
      lastCheckedInTime = prefs.getString("lastCheckedInTime") ?? "";
      lastSalesOrderId = prefs.getString("lastSalesOrderId") ?? "";
      lastCheckoutTime = prefs.getString("timeOut") ?? "";
      lastSalesOrderId = prefs.getString("LAST_INTERNAL_ID") ?? "";
    });

    await refreshAll();
  }

  DateTime parseCustomDate(String input) {
    try {
      final parts = input.split("/");
      if (parts.length == 3) {
        int day = int.tryParse(parts[0]) ?? 1;
        int month = int.tryParse(parts[1]) ?? 1;
        int year = int.tryParse(parts[2]) ?? 2000;
        return DateTime(year, month, day);
      }
      return DateTime(2000);
    } catch (e) {
      return DateTime(2000);
    }
  }

  List<Map<String, dynamic>> monthlyData = [];

  Future<void> getMonthlyAttendanceForMonth(DateTime month) async {
    String? empId = Prefs.getID("EmpId");
    if (empId == null) return;

    String monthYear =
        "${month.month.toString().padLeft(2, '0')}/${month.year}";
    Map<String, dynamic> postData = {
      "employeeId": empId,
      "monthYear": monthYear,
    };

    setState(() => isLoading = true);

    try {
      var result = await apiService.getmonthlyattendance(postData);
      final decoded = json.decode(result.body);
      GetMonthlyAttendanceModel response = GetMonthlyAttendanceModel.fromJson(
        decoded,
      );

      setState(() {
        monthlyattendance = response.data;
        monthlyData = buildMonthlyAttendanceWithDefaults();
        _selectedData = getAttendanceForDate(_selectedDay ?? DateTime.now());
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching monthly attendance: $e");
    }
  }

  Map<String, dynamic> getAttendanceForDate(DateTime date) {
    return monthlyData.firstWhere(
      (d) =>
          d['date'].day == date.day &&
          d['date'].month == date.month &&
          d['date'].year == date.year,
      orElse: () {
        // Default to a dummy absent record
        return {
          'date': date,
          'status': 'Absent',
          'clockIn': '-',
          'clockOut': '-',
          'workedHours': '0:00',
          'otHours': '0:00',
        };
      },
    );
  }

  

  List<Map<String, dynamic>> buildMonthlyAttendanceWithDefaults() {
    List<DateTime> allDays = getAllDaysInMonth(_focusedDay);
    DateTime today = DateTime.now();
    List<Map<String, dynamic>> monthData = [];

    bool isSameDay(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    for (var day in allDays) {
      var att = monthlyattendance.firstWhere(
        (a) {
          if (a.attendanceDate == null || a.attendanceDate!.isEmpty)
            return false;
          DateTime d = parseCustomDate(a.attendanceDate!);
          return d.year == day.year && d.month == day.month && d.day == day.day;
        },
        orElse: () => Attendance(
          employeeType: "",
          timeIn: null,
          timeOut: null,
          hoursWorked: "0:00",
          otHours: "0:00",
          attendanceStatus: null,
          shiftMaster:
              null, // add shiftMaster field in your model if not already
        ),
      );

      String clockIn = att.timeIn ?? '-';
      String clockOut = att.timeOut ?? '-';
      String workedHours = att.hoursWorked?.toString() ?? "0:00";
      String otHours = att.otHours?.toString() ?? "0:00";

      String status;

      // Default timings
      DateTime shiftStart;
      DateTime shiftEnd;

      // Apply shift logic
      if (att.shiftMaster?.toString() == "2") {
        // GENERAL SHIFT
        shiftStart = DateTime(day.year, day.month, day.day, 9, 0);
        shiftEnd = DateTime(day.year, day.month, day.day, 17, 0); // 5 PM
      } else if (att.shiftMaster?.toString() == "4") {
        // NIGHT SHIFT
        shiftStart = DateTime(day.year, day.month, day.day, 20, 0); // 8 PM
        shiftEnd = DateTime(
          day.year,
          day.month,
          day.day + 1,
          5,
          0,
        ); // next day 5 AM
      } else {
        // fallback general shift
        shiftStart = DateTime(day.year, day.month, day.day, 9, 0);
        shiftEnd = DateTime(day.year, day.month, day.day, 17, 0);
      }

      DateTime now = DateTime.now();

      // Parse actual clock-in time
      DateTime? actualIn = clockIn != '-' ? parseTime(clockIn, day) : null;

      // Attendance logic
      if (day.isAfter(today)) {
        status = "Future"; // Future dates
      } else if (isSameDay(day, today) &&
          actualIn == null &&
          now.isBefore(shiftStart)) {
        status = "Future"; // Today before shift start
      } else if (att.attendanceStatus?.toLowerCase() == "leave") {
        status = "Leave";
      } else if (day.weekday == DateTime.sunday) {
        status = "Weekend";
      } else if (isSameDay(day, today) &&
          actualIn == null &&
          now.isAfter(shiftStart) &&
          now.isBefore(shiftEnd)) {
        status = "Late"; // shift started, not yet checked in
      } else if (actualIn != null && actualIn.isAfter(shiftEnd)) {
        status = "Absent"; // Checked in after shift end
      } else if (actualIn != null && actualIn.isAfter(shiftStart)) {
        status = "Late"; // Checked in after shift start but before shift end
      } else if (actualIn != null) {
        status = "Present"; // Checked in on time
      } else {
        status = "Absent";
      }

      monthData.add({
        'date': day,
        'status': status,
        'clockIn': clockIn,
        'clockOut': clockOut,
        'workedHours': workedHours,
        'otHours': otHours,
      });
    }

    return monthData;
  }

  List<DateTime> getAllDaysInMonth(DateTime month) {
    final lastDay = DateTime(month.year, month.month + 1, 0);
    return List.generate(
      lastDay.day,
      (i) => DateTime(month.year, month.month, i + 1),
    );
  }

  DateTime parseTime(String timeStr, DateTime day) {
    if (timeStr.isEmpty || timeStr == '-')
      return DateTime(day.year, day.month, day.day, 0, 0);
    final parts = timeStr.split(':');
    if (parts.length < 2) return DateTime(day.year, day.month, day.day, 0, 0);

    int hour = int.tryParse(parts[0]) ?? 0;
    int minute = ((parts[1].split(" ")[0]).isNotEmpty)
        ? int.tryParse(parts[1].split(" ")[0]) ?? 0
        : 0;

    if (timeStr.toLowerCase().contains("pm") && hour != 12) hour += 12;
    if (timeStr.toLowerCase().contains("am") && hour == 12) hour = 0;

    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  void _showBottomTab(BuildContext context, DateTime selectedDay) {
    final attData = monthlyData.firstWhere(
      (d) =>
          d['date'].day == selectedDay.day &&
          d['date'].month == selectedDay.month &&
          d['date'].year == selectedDay.year,
      orElse: () => {
        'employee': employeeName,
        'attendanceDate': DateFormat('dd/MM/yyyy').format(selectedDay),
        'status': 'Absent',
        'clockIn': '-',
        'clockOut': '-',
        'workedHours': '0:00',
        'otHours': '0:00',
      },
    );

    Map<String, dynamic> _data = {
      'employee': attData['employee'] ?? employeeName,
      'attendanceDate': DateFormat('dd/MM/yyyy').format(selectedDay),
      'status': attData['status'] ?? 'Absent',
      'clockIn': attData['clockIn'] ?? '-',
      'clockOut': attData['clockOut'] ?? '-',
      'worked': attData['workedHours'] ?? '0:00',
      'ot': attData['otHours'] ?? '0:00',
    };

    String hourscal(String hoursWorkedStr) {
      double hoursWorked = double.tryParse(hoursWorkedStr) ?? 0.0;
      int hours = hoursWorked.floor();
      int minutes = ((hoursWorked - hours) * 60).round();
      return "$hours:${minutes.toString().padLeft(2, '0')}";
    }

    String sumHours(String workedStr, String otStr) {
      double worked = double.tryParse(workedStr) ?? 0.0;
      double ot = double.tryParse(otStr) ?? 0.0;
      double total = worked + ot;
      int hours = total.floor();
      int minutes = ((total - hours) * 60).round();
      return "$hours:${minutes.toString().padLeft(2, '0')}";
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    "Attendance Result",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "Staff ${_data['employee']}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        // color:
                        // (_data['status'] == 'Absent'
                        //         ? Colors.red.shade300
                        //         : _data['status'] == 'Future'
                        //         ? Colors.grey.shade400
                        //         : Colors.green.shade200)
                        //     .withOpacity(0.5),
                        color: getStatusColor(_data['status']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _data['status'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _data['attendanceDate'],
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Clock In Time",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      _data['clockIn'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Clock Out Time",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      _data['clockOut'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Worked Hours",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      hourscal(_data['worked']),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Overtime Duration",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      hourscal(_data['ot']),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Duration",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      sumHours(_data['worked'], _data['ot']),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color getDayColor(DateTime day) {
    final att = monthlyData.firstWhere(
      (d) =>
          d['date'].day == day.day &&
          d['date'].month == day.month &&
          d['date'].year == day.year,
      orElse: () => {'status': 'Future'},
    );

    switch (att['status']) {
      case 'Absent':
        return const Color(0xFFCF0027).withOpacity(0.1); // red
      case 'Present':
        return const Color(0xFF009227).withOpacity(0.1); // green
      case 'Late':
        return Colors.orange.withOpacity(0.2); // orange for late
      case 'Leave':
        return Colors.purple.withOpacity(0.2); // purple for leave
      case 'Future':
        return const Color.fromARGB(
          255,
          208,
          220,
          214,
        ).withOpacity(0.1); // grey
      case 'Weekend':
        return Colors.blue.shade100.withOpacity(0.5);
      default:
        return Colors.grey.shade200;
    }
  }

  int getPresentDays() {
    return monthlyData.where((d) => d['status'] == 'Present').length;
  }

  int getAbsentDays() {
    return monthlyData.where((d) => d['status'] == 'Absent').length;
  }

  int getFutureDays() {
    return monthlyData.where((d) => d['status'] == 'Future').length;
  }

  int getLateDays() {
    return monthlyData.where((d) => d['status'] == 'Late').length;
  }

  int getLeaveDays() {
    return monthlyData.where((d) => d['status'] == 'Leave').length;
  }

  String getDisplayStatus(Map<String, dynamic>? data) {
    if (data == null) return "Not Scheduled";

    final status = data['status']?.toString() ?? "";

    switch (status) {
      case "":
      case "Future":
        return "Not Scheduled";
      case "Present":
        return "Present";
      case "Absent":
        return "Absent";
      case "Late":
        return "Late";
      case "Leave":
        return "Leave";
      default:
        return status; // in case of other unexpected values
    }
  }

  // Get text color
  // Color getStatusColor(String status) {
  //   switch (status) {
  //     case "Absent":
  //       return Colors.red;
  //     case "Present":
  //       return Colors.green;
  //     case "Late":
  //       return Colors.orange;
  //     case "Leave":
  //       return Colors.purple;
  //     case "Weekend":
  //       return Colors.blueGrey;
  //     default:
  //       return Colors.grey; // Not Scheduled
  //   }
  // }
  Color getStatusColor(String status) {
    switch (status) {
      case 'Absent':
        return Colors.red.shade100; // light red
      case 'Present':
        return Colors.green.shade100; // light green
      case 'Late':
        return Colors.orange.shade100; // light orange
      case 'Leave':
        return Colors.purple.shade100; // light purple
      case 'Future':
        return Colors.grey.shade300; // light grey
      case 'Weekend':
        return Colors.blue.shade100; // light blue
      default:
        return Colors.grey.shade200; // default light grey
    }
  }

  Color getStatusTextColor(String status) {
    switch (status) {
      case 'Absent':
        return AppColor.sec_red;
      case 'Present':
        return AppColor.sec_green;
      case 'Late':
        return AppColor.sec_yellow;
      case 'Leave':
        return AppColor.sec_blue;
      case 'Future':
        return Colors.grey.shade800;
      case 'Weekend':
        return Colors.grey;
      default:
        return Colors.black87;
    }
  }

  Future<void> refreshAll() async {
    // await loadEmployeeName(); // refresh employee name
    // await getMonthlyAttendanceForMonth(_focusedDay); // refresh attendance
    // await getstatus(); // refresh status + internalId
    // setState(() {
    //   // Preserve selected date's data if it exists
    //   if (_selectedDay != null) {
    //     _selectedData = getAttendanceForDate(_selectedDay!);
    //   } else {
    //     _selectedData = getAttendanceForDate(DateTime.now());
    //     _selectedDay = DateTime.now();
    //   }
    // }); // rebuild full page
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMM yyyy').format(_focusedDay);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            () => Profilescreen(
                              employeeName: employeeName,
                              supervisorId: supervisorId.toString(),
                              supervisor: supervisor.toString(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: AppColor.primary,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ),

                      SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Emirates Captain',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColor.litgrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            employeeName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                    

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      // 1️⃣ Save the keys you want to preserve
                      String? checkedShifts = prefs.getString("checkedShifts");
                      String? timeIn = prefs.getString("timeIn");
                      String? empId = prefs.getString(
                        "EmpId",
                      ); // if you want to keep

                      // // 2️⃣ Clear all preferences
                      // await prefs.clear();

                      // 3️⃣ Restore the keys you want to keep
                      if (checkedShifts != null)
                        await prefs.setString("checkedShifts", checkedShifts);
                      if (timeIn != null)
                        await prefs.setString("timeIn", timeIn);
                      if (empId != null) await prefs.setString("EmpId", empId);

                      // 4️⃣ Navigate to login screen
                      Get.offAllNamed("/login");
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF359CC1), Color(0xFF005675)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: 
                    GestureDetector(
                 
                      onTap: () async {
  await statusController.getStatus();  

  final prefs = await SharedPreferences.getInstance();
  bool checkedIn = prefs.getBool("isCheckedIn") ?? false;

  final id = statusController.lastSalesOrderId.value;
  final timeIn = statusController.lastCheckedInTime.value;

  if (checkedIn) {
    final storedSalesOrderId = prefs.getString("LAST_SALES_ORDER_ID") ?? id;
    final storedTimeIn = prefs.getString("lastCheckedInTime") ?? timeIn;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Checkoutscreen(
          internalId: storedSalesOrderId,
          timeIn: storedTimeIn,
        ),
      ),
    );
  } else {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Checkinpage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      await prefs.setBool("isCheckedIn", result['checkedIn'] ?? false);
      await prefs.setString("lastCheckedInTime", result['timeIn'] ?? "");
      await prefs.setString("LAST_SALES_ORDER_ID",
          result['salesOrderId']?.toString() ?? "");

      setState(() {
        isCheckedIn = result['checkedIn'] ?? false;
        lastCheckedInTime = result['timeIn'] ?? "";
        lastSalesOrderId = result['salesOrderId']?.toString() ?? "";
      });
    } else {
      await statusController.getStatus();
    }
  }
},

                      child: Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0x0D3085FE),
                          border: Border.all(
                            color: isCheckedIn ? Colors.red : AppColor.sec_blue,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(14),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCheckedIn ? "Check \nOut" : "Check \nIn",
                                style: TextStyle(
                                  color: isCheckedIn
                                      ? AppColor.sec_red
                                      : AppColor.darker,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SvgPicture.asset(
                                isCheckedIn
                                    ? AppAssets.out
                                    : AppAssets.check, // use different icons
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ), // spacing between the two containers
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Employeereportspage(
                              timesheetId: lastSalesOrderId,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 110,

                        decoration: BoxDecoration(
                          color: const Color(0x0D30BEB6),
                          border: Border.all(color: AppColor.sec_green),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(14),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Employee\nReports",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 12),
                              SvgPicture.asset(AppAssets.report),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.access_time_filled_rounded,
                      color: AppColor.sec_blue,
                    ),
                    Text(DateFormat('dd/MM/yyyy').format(DateTime.now())),
                    Text(DateFormat('hh:mm:ss a').format(DateTime.now())),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.darker),
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // 👈 set radius here
                      ),
                      child: Text(
                        'My Schedule',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                   
                  ],
                ),

                TableCalendar(
                  availableGestures: AvailableGestures.horizontalSwipe,

                  headerStyle: HeaderStyle(formatButtonVisible: false),
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _selectedData = getAttendanceForDate(selectedDay);
                    });

                    // Show bottom sheet when a day is selected
                    // if (_selectedData != null &&
                    //     _selectedData!['status'] != "Future" &&
                    //     _selectedData!['status'] != "Weekend") {
                    //   _showBottomTab(context, selectedDay);
                    // }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                    getMonthlyAttendanceForMonth(focusedDay).then((_) {
                      setState(() {
                        // Select today if it's in the new month, else first day of month
                        DateTime defaultSelectedDay = DateTime.now();
                        if (defaultSelectedDay.month != focusedDay.month ||
                            defaultSelectedDay.year != focusedDay.year) {
                          defaultSelectedDay = DateTime(
                            focusedDay.year,
                            focusedDay.month,
                            1,
                          );
                        }

                        _selectedDay = defaultSelectedDay;
                        _selectedData = getAttendanceForDate(_selectedDay!);
                      });
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: getDayColor(day),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSameDay(day, _selectedDay)
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: isSameDay(day, _selectedDay)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Present
                      Expanded(
                        child: Container(
                          height: 85,
                          decoration: BoxDecoration(
                            color: Color(0xFF009227).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 10,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColor.sec_green,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Present',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      getPresentDays().toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Absent
                      Expanded(
                        child: Container(
                          height: 85,
                          decoration: BoxDecoration(
                            color: Color(0xFFCF0027).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 10,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColor.sec_red,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: AppColor.sec_red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Absent',
                                          style: TextStyle(
                                            color: AppColor.sec_red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      getAbsentDays().toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Late
                      Expanded(
                        child: Container(
                          height: 85,
                          decoration: BoxDecoration(
                            color: Color(0xFFE7AC00).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 10,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColor.sec_yellow,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: AppColor.sec_yellow,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Late',
                                          style: TextStyle(
                                            color: AppColor.sec_yellow,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      getLateDays().toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Leave
                      Expanded(
                        child: Container(
                          height: 85,
                          decoration: BoxDecoration(
                            color: Color(0xFF359CC1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 10,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColor.sec_blue1,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: AppColor.sec_blue1,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Leave',
                                          style: TextStyle(
                                            color: AppColor.sec_blue1,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      getLeaveDays().toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                if (_selectedData != null &&
                    _selectedData!['status'] != null &&
                    _selectedData!['status'] != "Future" &&
                    _selectedData!['status'] != "Weekend") {
                  _showBottomTab(context, _selectedData!['date']);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Cannot open details for this day"),
                    ),
                  );
                }
              },
              child: Container(
                height: 50,
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          getDisplayStatus(_selectedData),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: getStatusTextColor(
                              getDisplayStatus(_selectedData),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Icon(CupertinoIcons.chevron_up, size: 20),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
