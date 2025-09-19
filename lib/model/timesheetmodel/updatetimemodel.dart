// // To parse this JSON data, do
// //
// //     final updatetimeModel = updatetimeModelFromJson(jsonString);

// import 'dart:convert';

// UpdatetimeModel updatetimeModelFromJson(String str) =>
//     UpdatetimeModel.fromJson(json.decode(str));

// String updatetimeModelToJson(UpdatetimeModel data) =>
//     json.encode(data.toJson());

// class UpdatetimeModel {
//   final bool status;
//   final dynamic message; 
//   final int? recordId;

//   UpdatetimeModel({
//     required this.status,
//     required this.message,
//     this.recordId,
//   });

//   factory UpdatetimeModel.fromJson(Map<String, dynamic> json) => UpdatetimeModel(
//         status: json["status"] ?? false,
//         message: json["message"], // keep it dynamic
//         recordId: json["recordId"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "recordId": recordId,
//       };
// }

// import 'dart:convert';

// UpdatetimeModel updatetimeModelFromJson(String str) =>
//     UpdatetimeModel.fromJson(json.decode(str));

// String updatetimeModelToJson(UpdatetimeModel data) =>
//     json.encode(data.toJson());

// class UpdatetimeModel {
//   final bool status;
//   final dynamic message; 
//   final int? recordId;

//   UpdatetimeModel({
//     required this.status,
//     required this.message,
//     this.recordId,
//   });

//   factory UpdatetimeModel.fromJson(Map<String, dynamic> json) {
//     dynamic msg = json["message"];

//     int? recordId;
//     if (msg != null && msg is Map<String, dynamic>) {
//       recordId = msg["recordId"];
//     }

//     return UpdatetimeModel(
//       status: json["status"] ?? false,
//       message: msg,
//       recordId: recordId,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "recordId": recordId,
//       };
// }


// import 'dart:convert';

// UpdatetimeModel updatetimeModelFromJson(String str) =>
//     UpdatetimeModel.fromJson(json.decode(str));

// String updatetimeModelToJson(UpdatetimeModel data) =>
//     json.encode(data.toJson());

// class UpdatetimeModel {
//   final bool status;
//   final dynamic message; 
//   final int? recordId;

//   UpdatetimeModel({
//     required this.status,
//     required this.message,
//     this.recordId,
//   });

//   factory UpdatetimeModel.fromJson(Map<String, dynamic> json) {
//     return UpdatetimeModel(
//       status: json["status"] ?? false,
//       message: json["message"],
//       recordId: json["recordId"], // 👈 directly map from root
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "recordId": recordId,
//       };
// }



import 'dart:convert';

UpdatetimeModel updatetimeModelFromJson(String str) =>
    UpdatetimeModel.fromJson(json.decode(str));

String updatetimeModelToJson(UpdatetimeModel data) =>
    json.encode(data.toJson());

class UpdatetimeModel {
  final bool status;
  final dynamic message; // can be String OR Map
  final int? recordId;

  UpdatetimeModel({
    required this.status,
    required this.message,
    this.recordId,
  });

  factory UpdatetimeModel.fromJson(Map<String, dynamic> json) {
    return UpdatetimeModel(
      status: json["status"] ?? false,
      message: json["message"],
      recordId: json["recordId"],
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "recordId": recordId,
      };

  /// ✅ Safe getter for message
  String getMessage() {
    if (message is String) {
      return message;
    } else if (message is Map && message["message"] != null) {
      return message["message"].toString();
    } else {
      return "Unknown error";
    }
  }
}
