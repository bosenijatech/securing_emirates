

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/src/response.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/base_controller.dart';
import '../../model/salesordermomodel/salesordernomodel.dart';
import '../../service/captain_emirates_apiservice.dart';
import '../../service/comFuncService.dart';
import '../authscreen/auth_validation.dart';
import '../widgets/app_utils.dart';
import '../widgets/checkinmap_page.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_textfield.dart';
import '../constant/constant.dart';
import 'package:geocoding/geocoding.dart';

class Checkinpage extends StatefulWidget {
  const Checkinpage({super.key});

  @override
  State<Checkinpage> createState() => _CheckinpageState();
}

class _CheckinpageState extends State<Checkinpage> {
  final BaseController baseCtrl = Get.put(BaseController());
  final AuthValidation authValidation = AuthValidation();
  final GlobalKey<CheckInMapState> _mapKey = GlobalKey();
  TextEditingController remark = TextEditingController();

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

  Set<int> disabledShiftIds = {};

  @override
  void initState() {
    super.initState();
    _getLocation();
    getsalesorderNo();
    _loadDisabledShifts();
  }

  /// Load shifts already checked in today
  Future<void> _loadDisabledShifts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today =
        "${DateTime.now().day.toString().padLeft(2,'0')}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().year}";

    String? checkedShiftsJson = prefs.getString("checkedShifts");
    Map<String, String> checkedShifts = {};
    if (checkedShiftsJson != null) {
      checkedShifts = Map<String, String>.from(json.decode(checkedShiftsJson));
    }

    setState(() {
      disabledShiftIds = checkedShifts.entries
          .where((e) => e.value == today)
          .map((e) => int.tryParse(e.key) ?? 0)
          .toSet();
    });
  }

  /// Helper function to generate Google Maps URL from LatLng
  String getGoogleMapsUrl(LatLng? location) {
    if (location == null) return "";
    return "https://www.google.com/maps/@${location.latitude},${location.longitude},15z";
  }

  Future<void> getsalesorderNo() async {
    setState(() => isLoading = true);
    try {
      Response result = await apiService.getsalesorderNo();
      var response = salesordernoModelFromJson(result.body);

      if (response.success == true) {
        setState(() {
          salesorderlist = response.payload ?? [];
        });
      } else {
        setState(() => salesorderlist = []);
      }
    } catch (e) {
      setState(() => salesorderlist = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Check if shift already checked in today
  Future<bool> hasCheckedInToday(int shiftId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today =
        "${DateTime.now().day.toString().padLeft(2,'0')}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().year}";

    String? checkedShiftsJson = prefs.getString("checkedShifts");
    Map<String, String> checkedShifts = {};
    if (checkedShiftsJson != null) {
      checkedShifts = Map<String, String>.from(json.decode(checkedShiftsJson));
    }

    return checkedShifts[shiftId.toString()] == today;
  }

  /// Mark shift as checked in
  Future<void> markCheckedIn(int shiftId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today =
        "${DateTime.now().day.toString().padLeft(2,'0')}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().year}";

    String? checkedShiftsJson = prefs.getString("checkedShifts");
    Map<String, String> checkedShifts = {};
    if (checkedShiftsJson != null) {
      checkedShifts = Map<String, String>.from(json.decode(checkedShiftsJson));
    }

    checkedShifts[shiftId.toString()] = today;
    await prefs.setString("checkedShifts", json.encode(checkedShifts));
    // update local state to disable shift
    setState(() {
      disabledShiftIds.add(shiftId);
      if (shiftMap[usershift] == shiftId) usershift = null; // reset dropdown
    });
  }

  

Future<String> buildGoogleMapsUrl(double lat, double lng) async {
  print("🟢 buildGoogleMapsUrl called with lat: $lat, lng: $lng");

  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    print("📍 Placemark list received: $placemarks");

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      print("📌 Using first placemark: $place");

      String address =
          "${place.locality}, ${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
      print("🏷 Full address: $address");

      String encodedAddress = Uri.encodeComponent(address);
      print("🔗 Encoded address: $encodedAddress");

      String googleMapsUrl = "https://www.google.com/maps?q=$lat,$lng($encodedAddress)";
      print("🌐 Google Maps URL: $googleMapsUrl");
      return googleMapsUrl;
    } else {
      print("⚠️ No placemarks found, returning only coordinates");
    }
  } catch (e) {
    print("❌ Reverse geocoding failed: $e");
  }

  String fallbackUrl = "https://www.google.com/maps?q=$lat,$lng";
  print("🌐 Fallback Google Maps URL: $fallbackUrl");
  return fallbackUrl;
}


Future<bool> addtimesheet() async {
  print("🟢 addtimesheet called");

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? empId = prefs.getString("EmpId");
    print("👤 Employee ID from prefs: $empId");

    if (empId == null) {
      showInSnackBar(context, "❌ Employee ID not found locally.");
      print("❌ Employee ID missing, returning false");
      return false;
    }

    int? shiftId = shiftMap[usershift];
    print("⏱ Shift ID for $usershift: $shiftId");

    if (shiftId == null) {
      showInSnackBar(context, "❌ Shift not found for selected user.");
      print("❌ Shift ID missing, returning false");
      return false;
    }

    bool alreadyCheckedIn = await hasCheckedInToday(shiftId);
    print("✅ Already checked in today? $alreadyCheckedIn");

    if (alreadyCheckedIn) {
      showInSnackBar(context, "❌ You have already checked in for $usershift today.");
      print("❌ Already checked in, returning false");
      return false;
    }

    String currentDate =
        "${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}";
    print("📅 Current date: $currentDate");

    String timeInStr =
        "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";
    print("⏰ Time In: $timeInStr");

    await prefs.setString("timeIn", timeInStr);
    print("💾 Saved timeIn to prefs");

    if (_currentLatLng == null) {
      showInSnackBar(context, "❌ Location not available.");
      print("❌ _currentLatLng is null, returning false");
      return false;
    }

    String gpsAddress =
        "https://www.google.com/maps?q=${_currentLatLng!.latitude},${_currentLatLng!.longitude}";
    print("🌐 GPS Address: $gpsAddress");

    Map<String, dynamic> postData = {
      "attendanceDate": currentDate,
      "employee": empId,
      "salesOrder": selectedUser?.internalId,
      "timeIn": timeInStr,
      "shiftMaster": shiftId.toString(),
      "fromGpsAddress": gpsAddress,
      // "latitude": _currentLatLng!.latitude.toString(),
      // "longitude": _currentLatLng!.longitude.toString(),
      "remarks": remark.text.trim(),
    };
    print("📤 Post data: $postData");

    var result = await apiService.addTimesheet(postData);
    print("📥 API response: ${result.body}");

    Map<String, dynamic> data = json.decode(result.body);
    print("🗂 Decoded response data: $data");

    if (data['status'] == true) {
      await markCheckedIn(shiftId);
      print("✅ Marked checked in locally");

      showInSnackBar(context, "✅ ${data['message'] ?? 'Timesheet added'}");
      print("✅ Timesheet added successfully, returning true");
      return true;
    } else {
      showInSnackBar(context, "❌ Failed: ${data['message'] ?? 'Unknown error'}");
      print("❌ Timesheet add failed, returning false");
      return false;
    }
  } catch (e) {
    showInSnackBar(context, "❌ Error: $e");
    print("❌ Exception caught in addtimesheet: $e");
    return false;
  }
}



  Future<void> _getLocation() async {
    try {
      setState(() => _status = "Fetching location...");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _status = "Location service is disabled.");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Location Disabled"),
            content: const Text("Please enable location services to proceed."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Geolocator.openLocationSettings();
                },
                child: const Text("Open Settings"),
              ),
            ],
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          setState(() => _status = "Location permission denied.");
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

      _mapKey.currentState?.updateLocation(latLng);
    } catch (e) {
      setState(() => _status = "Error: $e");
    }
  }

  Future<void> getImage(ImageSource source) async {
    try {
      Navigator.pop(context);
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        imageFile = pickedImage;
        imageSrc = File(pickedImage.path);
        liveimgSrc = pickedImage.path;
        setState(() {});
      }
    } catch (e) {
      debugPrint("Image picking failed: $e");
    }
  }

  void showImagePickerOptions() {
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
                int? shiftId = shiftMap[value];
                if (shiftId != null && disabledShiftIds.contains(shiftId)) {
                  showInSnackBar(context, "❌ Already checked in for this shift today.");
                  return;
                }
                setState(() => usershift = value);
              },
              labelField: (item) {
                int? shiftId = shiftMap[item];
                bool disabled = shiftId != null && disabledShiftIds.contains(shiftId);
                return disabled ? "$item (Already Checked In)" : item.toString();
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
                onPressed: () async {
                  if (selectedUser == null) {
                    showInSnackBar(context, "Please select a Sales Order");
                    return;
                  }
                  if (usershift == null) {
                    showInSnackBar(context, "Please select a Shift");
                    return;
                  }

                  final success = await addtimesheet();

                  if (success) {
                    Navigator.pop(context, {
                      "checkedIn": true,
                      "salesOrderId": selectedUser?.internalId.toString(),
                      "timeIn": await SharedPreferences.getInstance()
                          .then((prefs) => prefs.getString("timeIn")),
                      "shiftMaster": usershift,
                      "fromGpsAddress": getGoogleMapsUrl(_currentLatLng),
                      "remarks": remark.text.trim(),
                    });
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
        onPressed: _getLocation,
        tooltip: 'Refresh Location',
        child: Icon(Icons.refresh, color: AppColor.white),
      ),
    );
  }
}
