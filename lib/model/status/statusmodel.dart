import 'dart:convert';

// To parse this JSON data
GetstatusModel getstatusModelFromJson(String str) =>
    GetstatusModel.fromJson(json.decode(str));

String getstatusModelToJson(GetstatusModel data) => json.encode(data.toJson());

class GetstatusModel {
  bool status;
  String message;
  List<Statuslist> data;

  GetstatusModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetstatusModel.fromJson(Map<String, dynamic> json) => GetstatusModel(
        status: json["status"],
        message: json["message"],
        data: List<Statuslist>.from(
            json["data"].map((x) => Statuslist.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };

  @override
  String toString() {
    return 'GetstatusModel(status: $status, message: $message, data: $data)';
  }
}

class Statuslist {
  String? id;
  int? internalId;
  String? attendanceDate;
  String? subsidiary;
  String? employeeType;
  String? section;
  String? employee;
  String? designation;
  String? department;
  int? salesOrder;
  String? salesOrderId;
  String? timeIn;
  String? timeOut;
  String? hoursWorked;
  String? otApplicable;
  String? otHours;
  String? attendanceStatus;
  String? shiftMaster;
  String? reqstatus;
  String? remarks;
  String? fromGpsAddress;
  String? toGpsAddress;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Statuslist({
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
    this.salesOrderId,
    this.timeIn,
    this.timeOut,
    this.hoursWorked,
    this.otApplicable,
    this.otHours,
    this.attendanceStatus,
    this.shiftMaster,
    this.reqstatus,
    this.remarks,
    this.fromGpsAddress,
    this.toGpsAddress,
    this.createdAt,
    this.updatedAt,
    required this.v,
  });

  factory Statuslist.fromJson(Map<String, dynamic> json) => Statuslist(
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
        salesOrderId: json["salesOrderId"],
        timeIn: json["timeIn"],
        timeOut: json["timeOut"],
        hoursWorked: json["hoursWorked"],
        otApplicable: json["otApplicable"],
        otHours: json["otHours"],
        attendanceStatus: json["attendanceStatus"],
        shiftMaster: json["shiftMaster"],
        reqstatus: json["reqstatus"],
        remarks: json["remarks"],
        fromGpsAddress: json["fromGpsAddress"],
        toGpsAddress: json["toGpsAddress"],
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"])
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
        "salesOrderId": salesOrderId,
        "timeIn": timeIn,
        "timeOut": timeOut,
        "hoursWorked": hoursWorked,
        "otApplicable": otApplicable,
        "otHours": otHours,
        "attendanceStatus": attendanceStatus,
        "shiftMaster": shiftMaster,
        "reqstatus": reqstatus,
        "remarks": remarks,
        "fromGpsAddress": fromGpsAddress,
        "toGpsAddress": toGpsAddress,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };

  @override
  String toString() {
    return 'Statuslist(id: $id, employee: $employee, attendanceDate: $attendanceDate, shift: $shiftMaster, timeIn: $timeIn, timeOut: $timeOut)';
  }
}
