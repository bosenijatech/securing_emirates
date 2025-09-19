// To parse this JSON data, do
//
//     final getsingleregularizationlistModel = getsingleregularizationlistModelFromJson(jsonString);

import 'dart:convert';

GetsingleregularizationlistModel getsingleregularizationlistModelFromJson(String str) => GetsingleregularizationlistModel.fromJson(json.decode(str));

String getsingleregularizationlistModelToJson(GetsingleregularizationlistModel data) => json.encode(data.toJson());

class GetsingleregularizationlistModel {
    bool status;
    String message;
    List<dynamic> data;

    GetsingleregularizationlistModel({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetsingleregularizationlistModel.fromJson(Map<String, dynamic> json) => GetsingleregularizationlistModel(
        status: json["status"],
        message: json["message"],
        data: List<dynamic>.from(json["data"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x)),
    };
}
