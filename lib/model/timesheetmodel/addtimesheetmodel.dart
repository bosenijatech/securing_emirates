// // To parse this JSON data, do
// //
// //     final addtimeModel = addtimeModelFromJson(jsonString);

// import 'dart:convert';

// AddtimeModel addtimeModelFromJson(String str) => AddtimeModel.fromJson(json.decode(str));

// String addtimeModelToJson(AddtimeModel data) => json.encode(data.toJson());

// class AddtimeModel {
//     bool? status;
//     addtimesheet message;

//     AddtimeModel({
//          this.status,
//         required this.message,
//     });

//     factory AddtimeModel.fromJson(Map<String, dynamic> json) => AddtimeModel(
//         status: json["status"],
//         message: addtimesheet.fromJson(json["message"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message.toJson(),
//     };
// }

// class addtimesheet {
//     bool? success;
//     int? recordId;

//     addtimesheet({
//          this.success,
//          this.recordId,
//     });

//     factory addtimesheet.fromJson(Map<String, dynamic> json) => addtimesheet(
//         success: json["success"],
//         recordId: json["recordId"],
//     );

//     Map<String, dynamic> toJson() => {
//         "success": success,
//         "recordId": recordId,
//     };
// }



import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// ------------------- MODEL -------------------

AddtimeModel addtimeModelFromJson(String str) =>
    AddtimeModel.fromJson(json.decode(str));

String addtimeModelToJson(AddtimeModel data) =>
    json.encode(data.toJson());

class AddtimeModel {
  bool? status;
  Addtimesheet? message;

  AddtimeModel({
    this.status,
    this.message,
  });

  factory AddtimeModel.fromJson(Map<String, dynamic> json) =>
      AddtimeModel(
        status: json["status"],
        message: json["message"] != null
            ? Addtimesheet.fromJson(json["message"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message?.toJson(),
      };
}

class Addtimesheet {
  bool? success;
  int? recordId;

  Addtimesheet({
    this.success,
    this.recordId,
  });

  factory Addtimesheet.fromJson(Map<String, dynamic> json) =>
      Addtimesheet(
        success: json["success"],
        recordId: json["recordId"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "recordId": recordId,
      };
}
