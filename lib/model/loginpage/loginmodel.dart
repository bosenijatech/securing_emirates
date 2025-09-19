import 'dart:convert';

UserloginModel userloginModelFromJson(String str) =>
    UserloginModel.fromJson(json.decode(str));

String userloginModelToJson(UserloginModel data) =>
    json.encode(data.toJson());

class UserloginModel {
  bool? status;
  String? message;
  Login? data;

  UserloginModel({
     this.status,
     this.message,
    this.data,
  });

  factory UserloginModel.fromJson(Map<String, dynamic> json) => UserloginModel(
        status: json["status"],
        message: json["message"],
        data: (json["data"] is Map<String, dynamic> && json["data"].isNotEmpty)
            ? Login.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Login {
  String? isactive;
  String? id;
  String? internalId;
  String? employeeId;
  String? employeeName;
  String? email;
  String? supervisorId;
  String? supervisor;
  String? password;
  int? v;

  Login({
    this.isactive,
    this.id,
    this.internalId,
    this.employeeId,
    this.employeeName,
    this.email,
    this.supervisorId,
    this.supervisor,
    this.password,
    this.v,
  });

  factory Login.fromJson(Map<String, dynamic> json) => Login(
        isactive: json["isactive"],
        id: json["_id"],
        internalId: json["internalId"],
        employeeId: json["employeeId"],
        employeeName: json["employeeName"],
        email: json["email"],
        supervisorId: json["supervisorId"],
        supervisor: json["supervisor"],
        password: json["password"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "isactive": isactive,
        "_id": id,
        "internalId": internalId,
        "employeeId": employeeId,
        "employeeName": employeeName,
        "email": email,
        "supervisorId": supervisorId,
        "supervisor": supervisor,
        "password": password,
        "__v": v,
      };
}
