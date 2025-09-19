// // To parse this JSON data, do
// //
// //     final salesordernoModel = salesordernoModelFromJson(jsonString);

// import 'dart:convert';

// SalesordernoModel salesordernoModelFromJson(String str) => SalesordernoModel.fromJson(json.decode(str));

// String salesordernoModelToJson(SalesordernoModel data) => json.encode(data.toJson());

// class SalesordernoModel {
//   bool success;
//   String message;
//   List<SalesorderNumber> payload;

//   SalesordernoModel({
//     required this.success,
//     required this.message,
//     required this.payload,
//   });

//   factory SalesordernoModel.fromJson(Map<String, dynamic> json) {
//     return SalesordernoModel(
//       success: json["success"] ?? false,
//       message: json["message"] ?? '',
//       payload: json["payload"] != null
//           ? List<SalesorderNumber>.from(
//               json["payload"].map((x) => SalesorderNumber.fromJson(x)))
//           : [],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         "success": success,
//         "message": message,
//         "payload": payload.map((x) => x.toJson()).toList(),
//       };
// }


// class SalesorderNumber {
//   String? internalId;
//   String? tranId;

//   SalesorderNumber({
//     this.internalId,
//     this.tranId,
//   });

//   factory SalesorderNumber.fromJson(Map<String, dynamic> json) => SalesorderNumber(
//         internalId: json["internalId"],
//         tranId: json["tranId"],
//       );

//   Map<String, dynamic> toJson() => {
//         "internalId": internalId,
//         "tranId": tranId,
//       };
//   String get displayName {
//     return "${tranId ?? ''} - ${internalId ?? ''}";
//   }
//   @override
//   String toString() {
//     // This makes debug prints more useful
//     return 'SalesorderNumber(internalId: $internalId, tranId: $tranId)';
//   }
// }

// To parse this JSON data, do
//
//     final salesordernoModel = salesordernoModelFromJson(jsonString);

import 'dart:convert';

SalesordernoModel salesordernoModelFromJson(String str) =>
    SalesordernoModel.fromJson(json.decode(str));

String salesordernoModelToJson(SalesordernoModel data) =>
    json.encode(data.toJson());

class SalesordernoModel {
  bool success;
  String message;
  List<SalesorderNumber> payload; // ✅ Success case
  Map<String, dynamic>? error;    // ✅ Error case

  SalesordernoModel({
    required this.success,
    required this.message,
    required this.payload,
    this.error,
  });

  factory SalesordernoModel.fromJson(Map<String, dynamic> json) {
    List<SalesorderNumber> parsedPayload = [];
    Map<String, dynamic>? parsedError;

    // Handle payload as List (success case)
    if (json["payload"] is List) {
      parsedPayload = List<SalesorderNumber>.from(
        json["payload"].map((x) => SalesorderNumber.fromJson(x)),
      );
    }

    // Handle payload as error object (error case)
    if (json["payload"] is Map && json["payload"]["error"] != null) {
      parsedError = json["payload"]["error"];
    }

    return SalesordernoModel(
      success: json["success"] ?? false,
      message: json["message"] ?? '',
      payload: parsedPayload,
      error: parsedError,
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "payload": payload.map((x) => x.toJson()).toList(),
        if (error != null) "error": error,
      };
}

class SalesorderNumber {
  String? internalId;
  String? tranId;

  SalesorderNumber({
    this.internalId,
    this.tranId,
  });

  factory SalesorderNumber.fromJson(Map<String, dynamic> json) =>
      SalesorderNumber(
        internalId: json["internalId"],
        tranId: json["tranId"],
      );

  Map<String, dynamic> toJson() => {
        "internalId": internalId,
        "tranId": tranId,
      };

  String get displayName {
    return "${tranId ?? ''} - ${internalId ?? ''}";
  }

  @override
  String toString() {
    // This makes debug prints more useful
    return 'SalesorderNumber(internalId: $internalId, tranId: $tranId)';
  }
}
