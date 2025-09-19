

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/base_controller.dart';
import '../../model/loginpage/loginmodel.dart';
import '../../service/captain_emirates_apiservice.dart';
import '../constant/app_assets.dart';
import '../constant/app_color.dart';
import '../constant/pref.dart';
import '../screens/homepage.dart';
import '../widgets/app_utils.dart';
import '../widgets/custom_textfield.dart';

import 'auth_validation.dart';
import 'sigupscreen.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  BaseController baseCtrl = Get.put(BaseController());
  AuthValidation authValidation = AuthValidation();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  UserloginModel loginModel = UserloginModel();
  bool loading = false;
  bool isPasswordVisible = false;

  // --------------------------- LOGIN FUNCTION ---------------------------
  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Basic validation
    if (email.isEmpty) {
      AppUtils.showSingleDialogPopup(
        context,
        "Please enter email",
        "Ok",
        () => Navigator.of(context).pop(),
        null,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      AppUtils.showSingleDialogPopup(
        context,
        "Please enter a valid email",
        "Ok",
        () => Navigator.of(context).pop(),
        null,
      );
      return;
    }

    if (password.isEmpty) {
      AppUtils.showSingleDialogPopup(
        context,
        "Please enter password",
        "Ok",
        () => Navigator.of(context).pop(),
        null,
      );
      return;
    }

    // Set loading
    setState(() {
      loading = true;
    });

    var body = {"username": email, "password": password};
    print("➡️ Request Body: $body");

    try {
      final response = await apiService.userLogin(body);

      setState(() {
        loading = false;
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'].toString() == "true") {
          UserloginModel loginModel = UserloginModel.fromJson(jsonResponse);
          await addSharedPref(loginModel);
        } else {
          AppUtils.showSingleDialogPopup(
            context,
            jsonResponse['message'].toString(),
            "Ok",
            onExitPopup,
            null,
          );
        }
      } else {
        throw Exception("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      AppUtils.showSingleDialogPopup(
        context,
        e.toString(),
        "Ok",
        () => Navigator.of(context).pop(),
        null,
      );
    }
  }

  // --------------------------- SAVE TO SHARED PREFERENCES ---------------------------
  Future<void> addSharedPref(UserloginModel model) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("isLoggedIn", true);
    await Prefs.setFullName("Name", model.data!.employeeName.toString());
    await Prefs.setID("EmpId", model.data!.internalId.toString());
    await prefs.setString("SupervisorId", model.data!.supervisorId.toString());
    await prefs.setString("Supervisor", model.data!.supervisor.toString());
    await prefs.setString("UserEmail", model.data!.email.toString());
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => Homepage(
            employeeName: model.data!.employeeName.toString(),
            supervisorId: model.data!.supervisorId.toString(),
            supervisor: model.data!.supervisor.toString(),
          ),
        ),
        (route) => false,
      );
    }
  }

  void onExitPopup() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              child: Row(
                children: [
                  Image.asset(AppAssets.logo1, width: 120, height: 120),
                  SizedBox(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColor.mainColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Image.asset(AppAssets.hi, scale: 4),
                      ],
                    ),
                    Text(
                      "Attendees",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Hello there, login to continue",
                      style: TextStyle(fontSize: 14, color: AppColor.litgrey),
                    ),
                    const SizedBox(height: 20),

                    // ------------------ EMAIL FIELD ------------------
                    CustomRoundedTextField(
                      width: double.infinity,
                      type: TextInputType.emailAddress,
                      labelText: 'Email Address',
                      control: emailController,
                    ),
                    const SizedBox(height: 24),

                    // ------------------ PASSWORD FIELD ------------------
                    CustomRoundedTextField(
                      width: double.infinity,
                      type: TextInputType.text,
                      labelText: 'Password',
                      control: passwordController,
                      obscureText: !isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColor.litgrey,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forgot Password ?",
                          style: TextStyle(color: AppColor.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ------------------ LOGIN BUTTON ------------------
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: loading
                            ? null
                            : () {
                                login();
                              },
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Log In",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

     
          ],
        ),
      ),
    );
  }
}
