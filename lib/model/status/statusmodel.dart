// To parse this JSON data, use:
//
//     final getstatusModel = getstatusModelFromJson(jsonString);

import 'dart:convert';

GetstatusModel getstatusModelFromJson(String str) =>
    GetstatusModel.fromJson(json.decode(str));

String getstatusModelToJson(GetstatusModel data) => json.encode(data.toJson());

class GetstatusModel {
  bool status;
  dynamic message; // can be String or Map
  List<Statuslist> data;

  GetstatusModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetstatusModel.fromJson(Map<String, dynamic> json) => GetstatusModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] != null
            ? List<Statuslist>.from(
                json["data"].map((x) => Statuslist.fromJson(x)))
            : [],
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
  int? internalId;
  String? timeIn;
  String? timeOut;

  Statuslist({
    this.internalId,
    this.timeIn,
    this.timeOut,
  });

  factory Statuslist.fromJson(Map<String, dynamic> json) => Statuslist(
        internalId: json["internalId"],
        timeIn: json["timeIn"],
        timeOut: json["timeOut"],
      );

  Map<String, dynamic> toJson() => {
        "internalId": internalId,
        "timeIn": timeIn,
        "timeOut": timeOut,
      };

  @override
  String toString() {
    return 'Statuslist(internalId: $internalId, timeIn: $timeIn, timeOut: $timeOut)';
  }
}
