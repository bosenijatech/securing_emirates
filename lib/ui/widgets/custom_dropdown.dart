
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../constant/app_color.dart';

class CustomDropdownWidget extends StatelessWidget {
  final List<dynamic> valArr;
  final Function(dynamic) onChanged;
  final String? labelText;
  final dynamic selectedItem;
  final double? height;
  final double? width;
  final double? labelStyleFs;
  final Color? labelColor;
  final String? Function(dynamic)? validator;
  final String Function(dynamic)? itemAsString;
  final String Function(dynamic)? labelField;
  

  const CustomDropdownWidget({
    super.key,
    required this.valArr,
    required this.onChanged,
    this.labelText,
    this.validator,
    this.labelField,
    this.height,
    this.selectedItem,
    this.width,
    this.labelColor,
    this.labelStyleFs,
    this.itemAsString, Padding? extraWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 55.0,
      margin: const EdgeInsets.symmetric(vertical: 0),
      width: width ?? MediaQuery.of(context).size.width,
      child: DropdownSearch<dynamic>(
        popupProps: PopupProps.menu(
          showSearchBox: true,
          fit: FlexFit.loose,
          constraints: BoxConstraints(maxHeight: 250),
          searchFieldProps: TextFieldProps(
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 🔽 Reduced height
      hintText: 'Search...',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    style: const TextStyle(fontSize: 14),
  ),
          menuProps: MenuProps(
            backgroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        items: valArr,
        itemAsString: itemAsString ?? (item) => labelField != null ? labelField!(item) : item.toString(),
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
             floatingLabelStyle: TextStyle(fontSize: 16, color: AppColor.primary),
            labelStyle: TextStyle(
              fontSize: labelStyleFs ?? 14.0,
              color: labelColor ?? AppColor.darker,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: AppColor.grey, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
            ),
          ),
        ),
        dropdownButtonProps: const DropdownButtonProps(
          icon: Icon(Icons.arrow_drop_down, color: AppColor.primary, size: 26),
          alignment: Alignment.centerRight,
        ),
        validator: validator,
        onChanged: onChanged,
        selectedItem: selectedItem,
      ),
    );
  }
}
