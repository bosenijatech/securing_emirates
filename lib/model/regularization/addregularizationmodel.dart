// import 'dart:convert';

// AddregularizationModel addregularizationModelFromJson(String str) =>
//     AddregularizationModel.fromJson(json.decode(str));

// String addregularizationModelToJson(AddregularizationModel data) =>
//     json.encode(data.toJson());

// class AddregularizationModel {
//   bool status;
//   Addregularization message;

//   AddregularizationModel({
//     required this.status,
//     required this.message,
//   });

//   factory AddregularizationModel.fromJson(Map<String, dynamic> json) =>
//       AddregularizationModel(
//         status: json["status"],
//         message: Addregularization.fromJson(json["message"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message.toJson(),
//       };
// }

// class Addregularization {
//   bool? success;
//   int? recordId;
//   String? message; // ✅ Add this to capture API error message

//   Addregularization({
//     this.success,
//     this.recordId,
//     this.message,
//   });

//   factory Addregularization.fromJson(Map<String, dynamic> json) =>
//       Addregularization(
//         success: json["success"],
//         recordId: json["recordId"],
//         message: json["message"], // ✅ read error message if exists
//       );

//   Map<String, dynamic> toJson() => {
//         "success": success,
//         "recordId": recordId,
//         "message": message,
//       };
// }

import 'dart:convert';

AddRegularizationModel addRegularizationModelFromJson(String str) =>
    AddRegularizationModel.fromJson(json.decode(str));

String addRegularizationModelToJson(AddRegularizationModel data) =>
    json.encode(data.toJson());

class AddRegularizationModel {
  bool status;
  String message;

  AddRegularizationModel({
    required this.status,
    required this.message,
  });

  factory AddRegularizationModel.fromJson(Map<String, dynamic> json) =>
      AddRegularizationModel(
        status: json["status"] ?? false,
        message: json["message"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
