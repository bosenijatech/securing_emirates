

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../controller/base_controller.dart';
import '../../model/regularization/getregularizationlistmodel.dart';
import '../../model/regularization/getsingleregularizationlistmodel.dart';
import '../../service/captain_emirates_apiservice.dart';
import '../../service/comFuncService.dart';
import '../authscreen/auth_validation.dart';
import '../constant/pref.dart';
import 'regularizescreen.dart';

// ✅ Route observer to detect back navigation
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class Employeereportspage extends StatefulWidget {
  final String? timesheetId;
  const Employeereportspage({super.key, this.timesheetId});

  @override
  State<Employeereportspage> createState() => _EmployeereportspageState();
}

class _EmployeereportspageState extends State<Employeereportspage>
    with RouteAware {
  BaseController baseCtrl = Get.put(BaseController());
  AuthValidation authValidation = AuthValidation();

  bool isLoading = false;

  List<RegularizationList> regularizationList = [];
  List<RegularizationList> allData = [];

  DateTime? fromDate;
  DateTime? toDate;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    getregularization();
    if (widget.timesheetId != null && widget.timesheetId!.isNotEmpty) {
      getsingleregularizationlist(widget.timesheetId!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // ✅ Reload when back from another page
  @override
  void didPopNext() {
    getregularization();
  }

  Future<void> getregularization() async {
    String? empId = Prefs.getID("EmpId");
    if (empId == null || empId.isEmpty) {
      showInSnackBar(context, "❌ Employee ID not found!");
      return;
    }

    Map<String, dynamic> postData = {"employeeId": empId};
    setState(() => isLoading = true);

    try {
      var result = await apiService.getregularizationlist(postData);
      dynamic decoded = json.decode(result.body);

      if (decoded is! Map<String, dynamic>) {
        setState(() => isLoading = false);
        return;
      }

      GetregularizationlistModel response =
          GetregularizationlistModel.fromJson(decoded);

      setState(() {
        allData = response.data;
        regularizationList = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showInSnackBar(context, "Error: $e");
    }
  }

  // get single regularization
  Future<Map<String, dynamic>?> getsingleregularizationlist(
      String timesheetId) async {
    if (timesheetId.isEmpty) {
      showInSnackBar(context, "❌ timesheetId not found!");
      return null;
    }

    Map<String, dynamic> postData = {"timesheetId": timesheetId};
    setState(() => isLoading = true);

    try {
      var result = await apiService.singleregularizationlist(postData);
      dynamic decoded = json.decode(result.body);

      setState(() => isLoading = false);

      if (decoded is! Map<String, dynamic>) return null;

      GetsingleregularizationlistModel response =
          GetsingleregularizationlistModel.fromJson(decoded);

      if (response.data.isNotEmpty) {
        return response.data[0];
      }
      return null;
    } catch (e) {
      setState(() => isLoading = false);
      showInSnackBar(context, "Error: $e");
      return null;
    }
  }

  // ---------------- FILTER + SEARCH ----------------
  void _applyDateFilter() {
  if (allData.isEmpty) return;

  setState(() {
    if (fromDate == null && toDate == null && searchQuery.isEmpty) {
      regularizationList = List.from(allData);
      return;
    }

    regularizationList = allData.where((e) {
      bool dateMatch = true;

      if (e.attendanceDate != null && e.attendanceDate!.isNotEmpty) {
        try {
          // Parse dd/MM/yyyy
          final parts = e.attendanceDate!.split("/");
          final date = DateTime(
            int.parse(parts[2]), // yyyy
            int.parse(parts[1]), // MM
            int.parse(parts[0]), // dd
          );

          if (fromDate != null && toDate != null) {
            dateMatch = (date.isAtSameMomentAs(fromDate!) ||
                    date.isAfter(fromDate!)) &&
                (date.isAtSameMomentAs(toDate!) || date.isBefore(toDate!));
          } else if (fromDate != null) {
            dateMatch =
                date.isAtSameMomentAs(fromDate!) || date.isAfter(fromDate!);
          } else if (toDate != null) {
            dateMatch =
                date.isAtSameMomentAs(toDate!) || date.isBefore(toDate!);
          }
        } catch (err) {
          debugPrint("Date parse error: $err");
          dateMatch = false;
        }
      }

      bool searchMatch = searchQuery.isEmpty ||
          e.internalId.toString().toLowerCase().contains(searchQuery) ||
          (e.employee ?? "").toLowerCase().contains(searchQuery) ||
          (e.attendanceDate ?? "").toLowerCase().contains(searchQuery);

      return dateMatch && searchMatch;
    }).toList();
  });
}

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
    });
    _applyDateFilter();
  }

  // ---------------- DATE PICKERS ----------------
  String formatFromDate(DateTime? date) {
    if (date == null) return "From Date";
    return DateFormat("dd MMM yyyy").format(date);
  }

  String formatToDate(DateTime? date) {
    if (date == null) return "To Date";
    return DateFormat("dd MMM yyyy").format(date);
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        fromDate = picked;
        toDate = null;
      });
      _applyDateFilter();
    }
  }

  Future<void> _pickToDate() async {
    if (fromDate == null) {
      showInSnackBar(context, "Please select From Date first");
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? fromDate!,
      firstDate: fromDate!,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        toDate = picked;
      });
      _applyDateFilter();
    }
  }

  // ---------------- TIME FORMAT ----------------
  String formatWorkingTimeSmart(dynamic hoursWorked) {
    double h = 0;
    if (hoursWorked is String) {
      h = double.tryParse(hoursWorked) ?? 0;
    } else if (hoursWorked is num) {
      h = hoursWorked.toDouble();
    }

    final totalMinutes = (h * 60).round();

    if (totalMinutes < 60) {
      return "$totalMinutes mins";
    } else {
      final hoursPart = totalMinutes ~/ 60;
      final minutesPart = totalMinutes % 60;
      return "$hoursPart:${minutesPart.toString().padLeft(2, '0')} hrs";
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed('/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Employee Reports"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.offAllNamed('/home'),
          ),
        ),
        body: Column(
          children: [
            // 🔎 SEARCH BAR
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            //   child: TextField(
            //     decoration: InputDecoration(
            //       hintText: "Search by ID, Employee, or Date...",
            //       prefixIcon: const Icon(Icons.search),
            //       filled: true,
            //       fillColor: Colors.blue.shade50,
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(8),
            //         borderSide: BorderSide.none,
            //       ),
            //     ),
            //     onChanged: _onSearchChanged,
            //   ),
            // ),

            // ===== Date Pickers =====
            Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickFromDate,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            formatFromDate(fromDate),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickToDate,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            formatToDate(toDate),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== Data List =====
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : regularizationList.isEmpty
                      ? const Center(
                          child: Text(
                            "No Records Available",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: regularizationList.length,
                          itemBuilder: (context, index) {
                            final e = regularizationList[index];
                            return _buildRecordCard(e);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CARD DESIGN ----------------
  Widget _buildRecordCard(RegularizationList e) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0.1,
            blurRadius: 0.1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("No of Working Time"),
                    Text(
                      formatWorkingTimeSmart(e.hoursWorked),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        e.internalId.toString(),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    e.reqstatus == "C"
                        ? IconButton(
                            icon: const Icon(Icons.access_time,
                                size: 28, color: Colors.black),
                            onPressed: () async {
                              final safeContext = context;
                              var singleData =
                                  await getsingleregularizationlist(
                                      e.internalId.toString());
                              if (!mounted) return;
                              if (singleData == null) {
                                showInSnackBar(
                                    safeContext, "⚠️ No details found!");
                                return;
                              }
                              Get.dialog(
                                AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  title: const Text("Regularization Details"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "📅 Date: ${singleData['attendanceDate'] ?? '-'}"),
                                      const SizedBox(height: 8),
                                      Text(
                                          "🕒 Time In: ${singleData['timeIn'] ?? '-'}"),
                                      const SizedBox(height: 8),
                                      Text(
                                          "🕔 Time Out: ${singleData['timeOut'] ?? '-'}"),
                                      const SizedBox(height: 8),
                                      Text(
                                          "⏱ Hours Worked: ${formatWorkingTimeSmart(singleData['hoursWorked'])}"),
                                      const SizedBox(height: 8),
                                      Text(
                                          "👤 Employee: ${singleData['employee'] ?? '-'}"),
                                 
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text("Close"),
                                    ),
                                  ],
                                ),
                                barrierDismissible: true,
                              );
                            },
                          )
                        : PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert,
                                size: 28, color: Colors.black),
                            onSelected: (value) {
                              if (value == 'Regularize') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Regularizescreen(
                                      date: e.attendanceDate.toString(),
                                      checkIn: e.timeIn.toString(),
                                      checkOut: e.timeOut.toString(),
                                      internalId: e.internalId.toString(),
                                      employee: e.employee.toString(),
                                      hoursWorked: e.hoursWorked.toString(),
                                      salesOrder: e.salesOrder.toString(),
                                    ),
                                  ),
                                ).then((regularized) {
                                  if (regularized == true) {
                                    setState(() {
                                      e.reqstatus = "C";
                                    });
                                  }
                                });
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'Regularize',
                                child: Text("Regularize"),
                              ),
                            ],
                          ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Date"),
                    Text(e.attendanceDate.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Check In"),
                    Text(e.timeIn.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Check Out"),
                    Text(e.timeOut.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Work OT"),
                    Text(formatWorkingTimeSmart(e.otHours),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12,),
            // Row(children: [
            //   Text('Remark', e.)
            // ],)
          ],
        ),
      ),
    );
  }
}
