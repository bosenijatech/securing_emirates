import 'dart:convert';

// ==================== MODEL ====================

GetregularizationlistModel getregularizationlistModelFromJson(String str) =>
    GetregularizationlistModel.fromJson(json.decode(str));

String getregularizationlistModelToJson(GetregularizationlistModel data) =>
    json.encode(data.toJson());

class GetregularizationlistModel {
  bool status;
  Message? messageObject; // when message is object
  String? messageString;  // when message is plain string
  List<RegularizationList> data;

  GetregularizationlistModel({
    required this.status,
    this.messageObject,
    this.messageString,
    required this.data,
  });

  factory GetregularizationlistModel.fromJson(Map<String, dynamic> json) {
    // check if "message" is Map or String
    final msg = json["message"];

    return GetregularizationlistModel(
      status: json["status"] ?? false,
      messageObject:
          msg is Map<String, dynamic> ? Message.fromJson(msg) : null,
      messageString: msg is String ? msg : null,
      data: json["data"] == null
          ? []
          : List<RegularizationList>.from(
              json["data"].map((x) => RegularizationList.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": messageObject != null
            ? messageObject!.toJson()
            : messageString ?? "",
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Message {
  bool success;
  String? recordId;

  Message({
    required this.success,
    this.recordId,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        success: json["success"] ?? false,
        recordId: json["recordId"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "recordId": recordId,
      };
}

class RegularizationList {
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
  dynamic? timeOut;
  String? hoursWorked;
  String? otApplicable;
  String? otHours;
  String? attendanceStatus;
  String? shiftMaster;
  String? reqstatus;
  DateTime? createdAt;
   String? salesOrderId;
  DateTime? updatedAt;
  int? v;

  RegularizationList({
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
    this.reqstatus,
    this.createdAt,
    this.salesOrderId,
    this.updatedAt,
    this.v,
  });

  factory RegularizationList.fromJson(Map<String, dynamic> json) =>
      RegularizationList(
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
        reqstatus: json["reqstatus"],
        salesOrderId: json["salesOrderId"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
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
        "reqstatus": reqstatus,
        "salesOrderId": salesOrderId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}
