import 'package:flutter/material.dart';

import '../constant/app_color.dart';


class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.onPressed,
      required this.name,
      required this.circularvalue,
      this.fontSize,
      this.height,
      this.minWidth,
      this.isEnabled = true});
  final GestureTapCallback onPressed;
  final String? name;
  final double? circularvalue;
  final double? fontSize;
  final double? height;
  final double? minWidth;
  final bool? isEnabled;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      disabledColor: const Color.fromRGBO(158, 158, 158, 1),
      onPressed: isEnabled == true ? onPressed : null,
      color: AppColor.primarycolor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(circularvalue ?? 5),
      ),
      padding: const EdgeInsets.all(16),
      textColor: Colors.white,
      height: height ?? 50,
      // width:width ??
      minWidth: minWidth ?? MediaQuery.of(context).size.width,
      child: Text(
        name!.toString(),
        style: TextStyle(
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
      ),
    );
  }
}
