import 'dart:convert';

GetMonthlyAttendanceModel getMonthlyAttendanceModelFromJson(String str) =>
    GetMonthlyAttendanceModel.fromJson(json.decode(str));

String getMonthlyAttendanceModelToJson(GetMonthlyAttendanceModel data) =>
    json.encode(data.toJson());

class GetMonthlyAttendanceModel {
  bool status;
  String message;
  List<Attendance> data;

  GetMonthlyAttendanceModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetMonthlyAttendanceModel.fromJson(Map<String, dynamic> json) =>
      GetMonthlyAttendanceModel(
        status: json["status"] ?? false,
        message: json["message"] ?? "",
        data: List<Attendance>.from(
          (json["data"] ?? []).map((x) => Attendance.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };

  @override
  String toString() {
    return 'GetMonthlyAttendanceModel(status: $status, message: $message, data: $data)';
  }
}

class Attendance {
  String? id;
  int? internalId;
  String? attendanceDate;
  String? subsidiary;
  dynamic employeeType;
  String? section;
  String? employee;
  String? designation;
  String? department;
  int? salesOrder;
  String? timeIn;
  String? timeOut;
  dynamic hoursWorked;
  String? otApplicable;
  String? otHours;
  String? attendanceStatus;
  String? shiftMaster;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Attendance({
    this.id,
    this.internalId,
    this.attendanceDate,
    this.subsidiary,
    this.employeeType,
    this.section,
    this.employee,
    this.designation,
    this.department,
    this.salesOrder,
    this.timeIn,
    this.timeOut,
    this.hoursWorked,
    this.otApplicable,
    this.otHours,
    this.attendanceStatus,
    this.shiftMaster,
    this.createdAt,
    this.updatedAt,
    this.v,
    required,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
    id: json["_id"],
    internalId: json["internalId"],
    attendanceDate: json["attendanceDate"],
    subsidiary: json["subsidiary"],
    employeeType: json["employeeType"],
    section: json["section"],
    employee: json["employee"],
    designation: json["designation"],
    department: json["department"],
    salesOrder: json["salesOrder"],
    timeIn: json["timeIn"],
    timeOut: json["timeOut"],
    hoursWorked: json["hoursWorked"],
    otApplicable: json["otApplicable"],
    otHours: json["otHours"],
    attendanceStatus: json["attendanceStatus"],
    shiftMaster: json["shiftMaster"],
    createdAt: json["createdAt"] != null
        ? DateTime.tryParse(json["createdAt"])
        : null,
    updatedAt: json["updatedAt"] != null
        ? DateTime.tryParse(json["updatedAt"])
        : null,
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "internalId": internalId,
    "attendanceDate": attendanceDate,
    "subsidiary": subsidiary,
    "employeeType": employeeType,
    "section": section,
    "employee": employee,
    "designation": designation,
    "department": department,
    "salesOrder": salesOrder,
    "timeIn": timeIn,
    "timeOut": timeOut,
    "hoursWorked": hoursWorked,
    "otApplicable": otApplicable,
    "otHours": otHours,
    "attendanceStatus": attendanceStatus,
    "shiftMaster": shiftMaster,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };

  @override
  String toString() {
    return 'Attendance('
      'id: $id, '
      'internalId: $internalId, '
      'attendanceDate: $attendanceDate, '
      'subsidiary: $subsidiary, '
      'employeeType: $employeeType, '
      'section: $section, '
      'employee: $employee, '
      'designation: $designation, '
      'department: $department, '
      'salesOrder: $salesOrder, '
      'timeIn: $timeIn, '
      'timeOut: $timeOut, '
      'hoursWorked: $hoursWorked, '
      'otApplicable: $otApplicable, '
      'otHours: $otHours, '
      'attendanceStatus: $attendanceStatus, '
      'shiftMaster: $shiftMaster, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'v: $v'
      ')';
  }
}
