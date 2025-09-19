import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ui/constant/app_color.dart';


// Custom snack bar
void showInSnackBar(context, String message) {
  ScaffoldMessenger.of(context)
      .removeCurrentSnackBar(); // Close previous Snackbar
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

void showInSnackBarTop(context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
    content: Text(message),
    backgroundColor: AppColor.success,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 100, right: 20, left: 75),
  ));
}

// loading
Future<void> loadingDialog(BuildContext context) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SpinKitFadingCircle(
                color: Colors.blue,
                size: 80.0,
              ),
            ],
            // ),
          ),
        );
      });
}

// Custom alertbox

Future<void> showAlertDialog(
    BuildContext context, String title, String msg, String status) async {
  var result;
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        var color;
        switch (status) {
          case 'primary':
            color = Colors.blue;
            break;
          case 'warning':
            color = Colors.orange;
            break;
          case 'danger':
            color = Colors.red;
            break;

          default:
        }

        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: color),
          ),
          content: SingleChildScrollView(child: Text(msg)),
          actions: [
            ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Ok',
                  style: TextStyle(color: AppColor.light),
                ))
          ],
        );
      });
}

Future showAlertDialogInfo(
    {required BuildContext context,
    String? title,
    String? status,
    required String msg,
    okBtn = true}) async {
  String response = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        var color;
        switch (status) {
          case 'primary':
            color = Colors.blue;
            break;
          case 'warning':
            color = Colors.orange;
            break;
          case 'danger':
            color = Colors.red;
            break;

          default:
        }

        return AlertDialog(
          title: Text(
            title!,
            style: TextStyle(color: color),
          ),
          content: SingleChildScrollView(child: Text(msg)),
          actions: [
            ElevatedButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.of(context).pop('OK');
                },
                child: Text(okBtn ? 'OK' : 'YES')),
            if (!okBtn)
              ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop('NO');
                  },
                  child: const Text('NO'))
          ],
        );
      });
  return response;
}

Future<void> showAlertDialogInput({
  required BuildContext context,
  required String title,
  required String label,
  String status = 'primary',
}) async {
  var baseUrlCtrl = TextEditingController();

  var response = await showDialog(
      context: context,
      builder: (BuildContext context) {
        var color;
        switch (status) {
          case 'primary':
            color = Color(0xff3599cb);
            break;
          case 'warning':
            color = Colors.orange;
            break;
          case 'danger':
            color = Colors.red;
            break;

          default:
            color = Color(0xff3599cb);
            break;
        }

        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(color: color),
            // color: status == 'primary' ? Colors.blue : Colors.red),
          ),
          content: SingleChildScrollView(
            child: TextFormField(
              controller: baseUrlCtrl,
              decoration: InputDecoration(
                labelText: label,
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xffededed), width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xffededed), width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
                onPressed: () async {
                  // print(baseUrlCtrl.text);

                  final prefs = await SharedPreferences.getInstance();
                  if (baseUrlCtrl.text != null && baseUrlCtrl.text != '')
                    await prefs.setString(
                        'baseUrl', baseUrlCtrl.text.toString());

                  Navigator.of(context).pop(baseUrlCtrl.text);
                },
                child: const Text('Save'))
          ],
        );
      });
}

Future<void> showLogoutAlertDialog(
    BuildContext context, String title, String msg) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text(title),
          content: SingleChildScrollView(child: Text(msg)),
          actions: [
            ElevatedButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  final pref = await SharedPreferences.getInstance();
                  await pref.clear();
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => LoginPage()),
                  //   (Route<dynamic> route) => false,
                  // );
                },
                child: const Text('Yes')),
            ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('No')),
          ],
        );
      });
}

// split date from dateTime
formatDate(date) {
  return date != null
      ? date.toString().substring(0, 10).replaceAll('-', '/')
      : '';
}

// formatStringToDate(date) {
//   final val = date.toString().contains('/') == true ? '/' : '-';
//   final result = DateForma("yyyy${val}MM${val}dd").parse(date);
//   return DateTime(result.year, result.month, result.day);
// }

formatDateMDYtoDMY(date) {
  var data = date
      .toString()
      .trim()
      .substring(0, 10)
      .replaceAll('-', '/')
      .split('/')
      .reversed
      .toList();
  return [data[0], data[2], data[1]].join('/');
}

formatDateYMDtoDMY(date) {
  // print('formatDateYMDtoDMY');
  // print(date);
  return date != null
      ? date
          .toString()
          .trim()
          .substring(0, 10)
          .replaceAll('-', '/')
          .split('/')
          .reversed
          .join('/')
          .trim()
      : '';
}

formatDateDMYtoYMD(date) {
  var datelength = date.length;
  if (datelength < 10)
    datelength = 8;
  else
    datelength = 10;

  return date
      .toString()
      .trim()
      .substring(0, datelength)
      .replaceAll('-', '/')
      .split('/')
      .reversed
      .join('/');
}

formatDateWithSymbol({date, symbol = '/', monthFormat}) {
  return date != null
      ? DateFormat("dd${symbol}${monthFormat ?? 'MM'}${symbol}yyyy")
          .format(DateTime.parse(date.toString()))
      : '';
}

// Transform number to decimal
transformToDecimal(format, num) {
  return (double.parse(num.toString()).toStringAsFixed(int.parse(format)));
}

getPercentage(percent, total) {
  return ((percent / 100) * total);
}

emptyToZero(value) {
  value = value.toString().trim();
  if (value == 'null' ||
      value == '' ||
      value == 'undefined' ||
      value == 'NaN') {
    return 0.00;
  } else {
    return double.parse(value);
  }
}

stringToBoolean(string) {
  string != null && string != ''
      ? string.toString().toLowerCase() == 'false'
          ? false
          : true
      : false;
}

randomNumber6() {
  // Create a new instance of the Random class
  var random = Random();
  // Generate a random number between 100000 and 999999
  var randomNumber = random.nextInt(900000) + 100000;
  return randomNumber;
}

convertDateWithTimeZero(dateString) {
  if (dateString.toString().isNotEmpty &&
      dateString != null &&
      dateString.toString() != 'null') {
    var dateTime =
        '${formatDateDMYtoYMD(dateString).toString().replaceAll('/', '-')}T00:00:00.000Z';
    return dateTime;
  } else {
    return '';
  }
}

convertDateToDMYWithTimeZero(dateString) {
  var dateTime =
      '${formatDateYMDtoDMY(dateString).toString().replaceAll('/', '-')}';
  return dateTime;
}

formatStringToDMY(date) {
  if (date != null) {
    final val = date.toString().contains('/') == true ? '/' : '-';
    final result = DateFormat("dd${val}MM${val}yyyy").parse(date.toString());
    return DateTime(result.day, result.month, result.year);
  } else {
    // return null;
    // return '1900-01-01T00:00:00';
  }
}

convertDateToMDY(input) {
  // String input = ;
  input = input.toString();
  if (input != '' && input != 'null') {
    DateTime dateTime = DateTime.parse(input.trim());
    String output = DateFormat('MM/dd/yyyy').format(dateTime);
    return output;
  } else {
    return '';
  }
}

randomNumber({int digits = 10}) {
  //  var random = Random.secure();
  // var randomNumber = random.nextInt(9000000000 - 1000000000 + 1) + 1000000000;
  // var dateTimeSuffix = DateTime.now().millisecondsSinceEpoch.toString();
  // var uniqueNumber = '$randomNumber$dateTimeSuffix';
  // print('uniqueNumber.substring(0, 10) ${uniqueNumber.substring(0, 10)}');
  // return uniqueNumber.substring(0, 10);
  return List.generate(digits, (_) => Random().nextInt(10).toString()).join();
}

formatDateTime(dateTime) {
  return dateTime != null
      ? DateFormat("d/M/y h:mm a").format(DateTime.parse(dateTime.toString()))
      : '';
}

calculateAmount(String amount) {
  final calculatedAmout = (int.parse(amount)) * 100;
  return calculatedAmout.toString();
}

Future<void> comLaunchUrl({url, context}) async {
  if (url != '' && url != null) {
    url = Uri.parse(url);
    if (!await launchUrl(url)) {
      // throw Exception('Could not launch $_url');
      print('Could not launch $url');
    }
  } else {
    showInSnackBar(context, "Invalid URL");
  }
}

defaultBorder() {
  return OutlineInputBorder(
      borderSide: BorderSide(width: 1.5, color: AppColor.primary),
      borderRadius: BorderRadius.circular(
          30)); // borderSide: BorderSide(width: 1.5, color: AppColors.secondary.withOpacity(0.3)));
}

idleBorder() {
  return OutlineInputBorder(
      borderSide: BorderSide(width: 1.5, color: AppColor.grey),
      borderRadius: BorderRadius.circular(30));
}

// Custom snack bar
void showSnackBar(
    {required context,
    String? message = 'Processing...',
    bool? showClose = true,
    String? closeLabel = 'Close'}) {
  ScaffoldMessenger.of(context)
      .removeCurrentSnackBar(); // Close previous Snackbar
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message.toString()),
    action: showClose == true
        ? SnackBarAction(
            label: closeLabel!,
            // backgroundColor: AppColors.light,
            textColor: AppColor.light,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          )
        : null,
  ));
}

closeSnackBar({required context}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
}

curFormatWithDecimal({locale, symbol, decimalDigits, required value}) {
  return NumberFormat.currency(
          locale: locale ?? "en_IN", //en_US
          symbol: symbol ?? '₹',
          decimalDigits: decimalDigits ?? 2)
      .format(value);
}

Future<void> makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launchUrl(launchUri);
}
