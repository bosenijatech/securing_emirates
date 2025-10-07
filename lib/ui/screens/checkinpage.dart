


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/src/response.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

import '../../controller/base_controller.dart';
import '../../getx_contoller.dart/stauts_contoller.dart';
import '../../model/salesordermomodel/salesordernomodel.dart';
import '../../service/captain_emirates_apiservice.dart';
import '../../service/comFuncService.dart';
import '../widgets/app_utils.dart';
import '../widgets/checkinmap_page.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_textfield.dart';
import '../constant/constant.dart';

class Checkinpage extends StatefulWidget {
  const Checkinpage({super.key});

  @override
  State<Checkinpage> createState() => _CheckinpageState();
}

class _CheckinpageState extends State<Checkinpage> {
  final BaseController baseCtrl = Get.put(BaseController());
  final GlobalKey<CheckInMapState> _mapKey = GlobalKey();
  final TextEditingController remark = TextEditingController();

  LatLng? _currentLatLng;
  String _status = "Fetching location...";

  Map<String, int> shiftMap = {
    "GENERAL SHIFT": 2,
    "NIGHT SHIFT": 4,
  };
  List<String> shiftlist = ['GENERAL SHIFT', 'NIGHT SHIFT'];
  String? usershift;

  List<SalesorderNumber> salesorderlist = [];
  SalesorderNumber? selectedUser;
  bool isLoading = false;

  XFile? imageFile;
  File? imageSrc;
  String? liveimgSrc;

  Set<int> disabledShiftIds = {}; // Already checked-in shift IDs

  @override
  void initState() {
    super.initState();
    debugPrint("🔹 CheckinPage Initialized");
    _getLocation();
    getsalesorderNo();
    getDisabledShifts();
  }

String _today() {
  final now = DateTime.now();
  final day = now.day.toString().padLeft(2, '0');
  final month = now.month.toString().padLeft(2, '0');
  final year = now.year.toString();
  final today = "$day/$month/$year";
  debugPrint("📅 Today’s Date (padded): $today");
  return today;
}


  String getGoogleMapsUrl(LatLng? location) {
    if (location == null) return "";
    return "https://www.google.com/maps/@${location.latitude},${location.longitude},15z";
  }

bool isShiftAvailable(String shiftName) {
  final now = DateTime.now();
  String timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  debugPrint("🕐 Checking availability for shift: $shiftName at $timeStr");

  if (shiftName == "GENERAL SHIFT") {
    final start = DateTime(now.year, now.month, now.day, 6, 0);
    final end = DateTime(now.year, now.month, now.day, 17, 30);
    return now.isAfter(start) && now.isBefore(end);
 } else if (shiftName == "NIGHT SHIFT") {
  final start = DateTime(now.year, now.month, now.day, 17, 30);       // today 17:30
  final end = DateTime(now.year, now.month, now.day + 1, 5, 30);      // tomorrow 05:30

  // NIGHT SHIFT is available if now is after start (today evening) OR before end (tomorrow morning)
  if (now.isAfter(start) || now.isBefore(DateTime(now.year, now.month, now.day, 5, 30))) {
    return true;
  } else {
    return false;
  }
}

  return false;
}


  Future<void> getsalesorderNo() async {
    debugPrint("📦 Fetching sales order numbers...");
    setState(() => isLoading = true);
    try {
      Response result = await apiService.getsalesorderNo();
      var response = salesordernoModelFromJson(result.body);
      debugPrint("✅ Sales order API response: ${result.body}");

      if (response.success == true) {
        setState(() {
          salesorderlist = response.payload ?? [];
        });
        debugPrint("✅ Sales Orders Loaded: ${salesorderlist.length}");
      } else {
        setState(() => salesorderlist = []);
        debugPrint("❌ No sales orders found.");
      }
    } catch (e) {
      debugPrint("🚨 Error fetching sales orders: $e");
      setState(() => salesorderlist = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<bool> addtimesheet(StatusController statusController) async {
    debugPrint("🟩 Adding timesheet...");
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? empId = prefs.getString("EmpId");

      if (empId == null) {
        debugPrint("❌ Employee ID not found in prefs");
        showInSnackBar(context, "❌ Employee ID not found locally.");
        return false;
      }

      int? shiftId = shiftMap[usershift];
      if (shiftId == null) {
        debugPrint("❌ Shift not selected");
        showInSnackBar(context, "❌ Shift not found.");
        return false;
      }

    String currentDate =
           "${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}";
      String timeInStr =
          "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";


      await prefs.setString("timeIn", timeInStr);

      if (_currentLatLng == null) {
        debugPrint("❌ Location not available");
        showInSnackBar(context, "❌ Location not available.");
        return false;
      }

    String gpsAddress;
try {
  List<Placemark> placemarks = await placemarkFromCoordinates(
      _currentLatLng!.latitude, _currentLatLng!.longitude);
  if (placemarks.isNotEmpty) {
    final place = placemarks.first;
    gpsAddress =
        "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
  } else {
    gpsAddress =
        "https://www.google.com/maps?q=${_currentLatLng!.latitude},${_currentLatLng!.longitude}";
  }
} catch (e) {
  gpsAddress =
      "https://www.google.com/maps?q=${_currentLatLng!.latitude},${_currentLatLng!.longitude}";
}

      debugPrint("📍 GPS Address: $gpsAddress");

      String? base64Image;
      if (imageSrc != null) {
        base64Image = base64Encode(imageSrc!.readAsBytesSync());
        debugPrint("📸 Image converted to Base64, length=${base64Image.length}");
      } else {
        debugPrint("⚠️ No image uploaded");
      }

      Map<String, dynamic> postData = {
        "attendanceDate": currentDate,
        "employee": empId,
        "salesOrder": selectedUser?.internalId,
        "timeIn": timeInStr,
        "shiftMaster": shiftId.toString(),
        "fromGpsAddress": getGoogleMapsUrl(_currentLatLng),
        "remarks": remark.text.trim(),
        "image": base64Image,
      };

      debugPrint("📤 Sending timesheet data: $postData");

      var result = await apiService.addTimesheet(postData);
      Map<String, dynamic> data = json.decode(result.body);
      debugPrint("🟩 API Response: $data");

      if (data['status'] == true) {
        showInSnackBar(context, "✅ ${data['message'] ?? 'Timesheet added'}");
        await statusController.getStatus();
        await getDisabledShifts();
        debugPrint("✅ Timesheet successfully added");
        return true;
      } else {
        showInSnackBar(context, "❌ Failed: ${data['message'] ?? 'Unknown error'}");
        return false;
      }
    } catch (e) {
      debugPrint("🚨 Error in addtimesheet: $e");
      showInSnackBar(context, "❌ Error: $e");
      return false;
    }
  }

  Future<void> getDisabledShifts() async {
    debugPrint("📋 Fetching disabled shifts...");
    try {
      final statusController = Get.find<StatusController>();
      await statusController.getStatus();

      final todayDate = _today();
      disabledShiftIds.clear();

      for (var record in statusController.statuslist) {
        if (record.attendanceDate == todayDate) {
          int? shiftId = shiftMap[record.shiftMaster?.toUpperCase() ?? ""];
          if (shiftId != null) {
            disabledShiftIds.add(shiftId);
          }
        }
      }
      debugPrint("🚫 Disabled shift IDs for today: $disabledShiftIds");
      setState(() {});
    } catch (e) {
      debugPrint("🚨 Failed to get disabled shifts: $e");
    }
  }

  Future<void> _getLocation() async {
    debugPrint("📍 Fetching current location...");
    try {
      setState(() => _status = "Fetching location...");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("⚠️ Location service disabled");
        setState(() => _status = "Location service is disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          setState(() => _status = "Location permission denied.");
          debugPrint("🚫 Location permission denied");
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _status = "Location fetched successfully.";
        _currentLatLng = latLng;
      });

      debugPrint("✅ Location: lat=${latLng.latitude}, long=${latLng.longitude}");
      _mapKey.currentState?.updateLocation(latLng);
    } catch (e) {
      setState(() => _status = "Error: $e");
      debugPrint("🚨 Location Error: $e");
    }
  }

  Future<void> getImage(ImageSource source) async {
    try {
      debugPrint("🖼️ Opening image picker: $source");
      Navigator.pop(context);
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        imageFile = pickedImage;
        imageSrc = File(pickedImage.path);
        liveimgSrc = pickedImage.path;
        debugPrint("✅ Image selected: ${pickedImage.path}");
        setState(() {});
      } else {
        debugPrint("⚠️ No image selected");
      }
    } catch (e) {
      debugPrint("🚨 Image picking failed: $e");
    }
  }

  void showImagePickerOptions() {
    debugPrint("🖼️ Showing image picker options");
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a photo"),
                onTap: () => getImage(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Choose from gallery"),
                onTap: () => getImage(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLoadingAll = _currentLatLng == null || isLoading;

    if (isLoadingAll) {
      return Scaffold(
        backgroundColor: AppColor.bgLight,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.bgLight,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColor.bgLight,
        elevation: 0,
        title: const Text("Check In"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: CheckInMap(key: _mapKey, initialLocation: _currentLatLng!),
            ),
            const SizedBox(height: 24),
            CustomDropdownWidget(
              valArr: isLoading ? [] : salesorderlist,
              labelText: "Sales Order Number",
              selectedItem: selectedUser,
              onChanged: (value) {
                debugPrint("🟩 Selected Sales Order: ${value.tranId}");
                setState(() => selectedUser = value);
              },
              labelField: (item) => "SO #${item.tranId ?? ''}",
            ),
            const SizedBox(height: 16),
            CustomDropdownWidget(
              valArr: shiftlist,
              labelText: "Shift Type",
              selectedItem: usershift,
              onChanged: (value) {
                debugPrint("🟨 Shift dropdown tapped: $value");
                if (!isShiftAvailable(value) ||
                    disabledShiftIds.contains(shiftMap[value])) {
                  debugPrint("🚫 Shift not available or already checked in");
                  return;
                }
                setState(() => usershift = value);
                debugPrint("✅ Selected Shift: $usershift");
              },
              labelField: (item) {
                bool disabledByTime = !isShiftAvailable(item);
                bool disabledByCheckIn = disabledShiftIds.contains(shiftMap[item]);
                return (disabledByTime || disabledByCheckIn)
                    ? "$item (Not Available Now)"
                    : item;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: showImagePickerOptions,
                icon: Icon(Icons.upload_file, color: AppColor.primary),
                label: Text(
                  "Upload Image",
                  style: TextStyle(color: AppColor.primary),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColor.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            if (imageSrc != null)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    imageSrc!,
                    fit: BoxFit.cover,
                    height: 250,
                    width: double.infinity,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            CustomRoundedTextField(
              width: double.infinity,
              type: TextInputType.text,
              labelText: 'Note',
              control: remark,
              lines: 3,
              verticalMargin: 16,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: usershift == null ||
                        !isShiftAvailable(usershift!) ||
                        disabledShiftIds.contains(shiftMap[usershift])
                    ? null
                    : () async {
                        debugPrint("🟢 Check-In button pressed");
                        if (selectedUser == null) {
                          debugPrint("⚠️ No Sales Order selected");
                          showInSnackBar(context, "Please select a Sales Order");
                          return;
                        }
                        if (usershift == null) {
                          debugPrint("⚠️ No Shift selected");
                          showInSnackBar(context, "Please select a Shift");
                          return;
                        }

                        final statusController = Get.find<StatusController>();
                        final success = await addtimesheet(statusController);

                        if (success) {
                          final prefs = await SharedPreferences.getInstance();
                          debugPrint("✅ Check-in success, navigating back...");
                          Navigator.pop(context, {
                            "checkedIn": true,
                            "salesOrderId": selectedUser?.internalId.toString(),
                            "timeIn": prefs.getString("timeIn"),
                            "shiftMaster": usershift,
                            "fromGpsAddress": getGoogleMapsUrl(_currentLatLng),
                            "remarks": remark.text.trim(),
                          });
                        } else {
                          debugPrint("❌ Check-in failed");
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Check In",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primary,
        onPressed: () {
          debugPrint("🔄 Refresh Location button pressed");
          _getLocation();
        },
        tooltip: 'Refresh Location',
        child: Icon(Icons.refresh, color: AppColor.white),
      ),
    );
  }
}

