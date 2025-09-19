import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/constant/app_constants.dart';

class apiService {
  static String liveApiPath = AppConstants.apiBaseUrl;
  // static String liveImgPath = AppConstants.imgBaseUrl;

  final http.Client client = http.Client();

  Map<String, String>? headerData;

  apiService();

  /// Get headers with Bearer Token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getInt('user_id');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Appplatform': 'Android',
      'App-type': '$userId',
      'Authorization': 'Bearer $token',
    };
  }

  handleError({message}) {
    throw Exception(message ?? 'Network Error');
  }

//login
  static const int timeOutDuration = 35;
 static Future<http.Response> userLogin(dynamic json) async {
    final url = Uri.parse('${liveApiPath}mobileapp/login');
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    var response =
        await http.post(url, body: jsonEncode(json), headers: headers).timeout(
              const Duration(seconds: timeOutDuration),
            );
    return response;
  }



static Future<http.Response> getsalesorderNo() async {
  final url = Uri.parse('${liveApiPath}mobileapp/getsalesorderNo');
  Map<String, String> headers = {
    "Content-Type": "application/json",
  };
  var response = await http.get(
    url,
    headers: headers,
  );
  return response;
}


//addtimesheet
  static Future<http.Response> addTimesheet(dynamic json) async {
  final url = Uri.parse('${liveApiPath}mobileapp/addtimesheet');
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    var response =
        await http.post(url, body: jsonEncode(json), headers: headers).timeout(
              const Duration(seconds: timeOutDuration),
            );
    return response;
  }

//getstatus
  static Future<http.Response> getstatus(dynamic json) async {
  final url = Uri.parse('${liveApiPath}mobileapp/getstatus');
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    var response =
        await http.post(url, body: jsonEncode(json), headers: headers).timeout(
              const Duration(seconds: timeOutDuration),
            );
    return response;
  }
//updatetime
    static Future<http.Response> updatetimesheet(dynamic json) async {
  final url = Uri.parse('${liveApiPath}mobileapp/updatetimesheet');
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    var response =
        await http.post(url, body: jsonEncode(json), headers: headers).timeout(
              const Duration(seconds: timeOutDuration),
            );
    return response;
  }

  //getregularizationlist
  static Future<http.Response> getregularizationlist(dynamic json) async {
  final url = Uri.parse('${liveApiPath}mobileapp/getregularizationlist');
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    var response =
        await http.post(url, body: jsonEncode(json), headers: headers).timeout(
              const Duration(seconds: timeOutDuration),
            );
    return response;
  }

//addregularization

    static Future<http.Response> addregularization(dynamic json) async {
  final url = Uri.parse('${liveApiPath}mobileapp/addregularization');
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    var response =
        await http.post(url, body: jsonEncode(json), headers: headers).timeout(
              const Duration(seconds: timeOutDuration),
            );
    return response;
  }

  //getmonthlyattendance

    static Future<http.Response> getmonthlyattendance(dynamic json) async {
  final url = Uri.parse('${liveApiPath}mobileapp/getmonthlyattendance');
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    var response =
        await http.post(url, body: jsonEncode(json), headers: headers).timeout(
              const Duration(seconds: timeOutDuration),
            );
    return response;
  }



//getsingleregularizationlist

    static Future<http.Response> singleregularizationlist(dynamic json) async {
  final url = Uri.parse('${liveApiPath}mobileapp/getsingleregularizationlist');
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    var response =
        await http.post(url, body: jsonEncode(json), headers: headers).timeout(
              const Duration(seconds: timeOutDuration),
            );
    return response;
  }


}

