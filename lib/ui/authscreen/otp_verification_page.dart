// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:pinput/pinput.dart';
// import 'package:securing_emirates/ui/screens/homepage.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../constant/app_color.dart';

// class OtpVerificationPage extends StatefulWidget {
//   final String? phoneNumber;
//   final int? otp;

//   OtpVerificationPage({Key? key, this.phoneNumber, this.otp}) : super(key: key);

//   @override
//   State<OtpVerificationPage> createState() => _OtpVerificationPageState();
// }

// class _OtpVerificationPageState extends State<OtpVerificationPage> {
//   final List<TextEditingController> _otpControllers = List.generate(
//     6,
//     (_) => TextEditingController(),
//   );

//   TextEditingController otpCtrl = TextEditingController();
//   final GlobalKey<FormState> loginForm = GlobalKey<FormState>();
//   final otpFocusNode = FocusNode();

//   Timer? _timer;
//   int _start = 60;
//   bool _isResendButtonEnabled = false;

//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     otpCtrl.dispose();
//     otpFocusNode.dispose();
//     super.dispose();
//   }

//   void startTimer() {
//     const oneSec = Duration(seconds: 1);
//     _timer = Timer.periodic(oneSec, (Timer timer) {
//       if (_start == 0) {
//         if (mounted) {
//           setState(() {
//             timer.cancel();
//             _isResendButtonEnabled = true;
//           });
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _start--;
//           });
//         }
//       }
//     });
//   }

//   void resendOTP() async {
//     if (_isResendButtonEnabled) {
//       setState(() {
//         _start = 60;
//         _isResendButtonEnabled = false;
//         otpCtrl.clear();
//       });

//       startTimer();

//       // Optional: Simulate sending OTP or call API
//       print("OTP resent to ${widget.phoneNumber}");

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("OTP has been resent."),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     const focusedBorderColor = AppColor.primary;
//     const fillColor = Color.fromRGBO(243, 246, 249, 0);
//     const borderColor = AppColor.primary;

//     final defaultPinTheme = PinTheme(
//       width: 56,
//       height: 56,
//       textStyle: const TextStyle(fontSize: 22, color: AppColor.primary),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(19),
//         border: Border.all(color: AppColor.darker),
//       ),
//     );

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: Text("Back"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: loginForm,
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "OTP Have Been Sent!",
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: AppColor.mainColor,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 "We sent you an email. Please check your mail and complete the OTP code.",
//                 style: TextStyle(fontSize: 14, color: AppColor.grey),
//               ),
//               const SizedBox(height: 30.0),
//               Center(
//                 child: Pinput(
//                   length: 6,
//                   controller: otpCtrl,
//                   focusNode: otpFocusNode,
//                   defaultPinTheme: defaultPinTheme,
//                   separatorBuilder: (index) => const SizedBox(width: 8.0),
//                   validator: (value) {
//                     if (value == null || value.isEmpty || value.length != 6) {
//                       return 'Enter valid 6-digit OTP';
//                     }
//                     return null;
//                   },
//                   hapticFeedbackType: HapticFeedbackType.lightImpact,
//                   onCompleted: (pin) {},
//                   onChanged: (value) {},
//                   cursor: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Container(
//                         margin: const EdgeInsets.only(bottom: 9.0),
//                         width: 22.0,
//                         height: 1.0,
//                         color: focusedBorderColor,
//                       ),
//                     ],
//                   ),
//                   focusedPinTheme: defaultPinTheme.copyWith(
//                     decoration: defaultPinTheme.decoration!.copyWith(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: focusedBorderColor),
//                     ),
//                   ),
//                   submittedPinTheme: defaultPinTheme.copyWith(
//                     decoration: defaultPinTheme.decoration!.copyWith(
//                       color: fillColor,
//                       borderRadius: BorderRadius.circular(19),
//                       border: Border.all(color: focusedBorderColor),
//                     ),
//                   ),
//                   errorPinTheme: defaultPinTheme.copyBorderWith(
//                     border: Border.all(color: AppColor.actionColor),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20.0),

//               // 👇 Resend code timer or button
//               Center(
//                 child: _isResendButtonEnabled
//                     ? GestureDetector(
//                         onTap: resendOTP,
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               "Didn’t Receive Code?",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.normal,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             SizedBox(width: 5,),
//                             Text(
//                               "Resend Code",
//                               style: TextStyle(
//                                 color: AppColor.primary,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                                 decoration: TextDecoration.underline,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : Text(
//                         "Resend code in 00:${_start.toString().padLeft(2, '0')}",
//                         style: TextStyle(color: AppColor.grey, fontSize: 14),
//                       ),
//               ),

//               const SizedBox(height: 20.0),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColor.primary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () {
//                     // Validate OTP
//                     // if (loginForm.currentState!.validate()) {
//                     //   Navigator.push(
//                     //     context,
//                     //     MaterialPageRoute(builder: (context) => Homepage()),
//                     //   );
//                     // }
//                      Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => Homepage()),
//                       );
//                   },
//                   child: Text(
//                     "Verify",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: AppColor.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }






























// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:get/get.dart';
// // import 'package:pinput/pinput.dart';
// // import 'package:securing_emirates/ui/screens/homepage.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // import '../constant/app_color.dart';





// // class OtpVerificationPage extends StatefulWidget {
// //   final String? phoneNumber;
// //   final int? otp;

// //   OtpVerificationPage({Key? key, this.phoneNumber, this.otp}) : super(key: key);

// //   @override
// //   State<OtpVerificationPage> createState() => _OtpVerificationPageState();
// // }

// // class _OtpVerificationPageState extends State<OtpVerificationPage> {
// //   // final AsparentsApiService apiService = AsparentsApiService();
// //   final List<TextEditingController> _otpControllers =
// //       List.generate(6, (_) => TextEditingController());

// //   TextEditingController otpCtrl = TextEditingController();
// //   // BaseController baseCtrl = Get.put(BaseController());
// //   final GlobalKey<FormState> loginForm = GlobalKey<FormState>();

// //   final otpFocusNode = FocusNode();
// //   // @override
// //   // void dispose() {
// //   //   _timer?.cancel(); // Cancel the timer when the widget is disposed
// //   //   for (var controller in _otpControllers) {
// //   //     controller.dispose();
// //   //   }
// //   //   super.dispose();
// //   // }

// // @override
// // void dispose() {
// //   _timer?.cancel();
// //   otpCtrl.dispose();
// //   otpFocusNode.dispose();
// //   super.dispose();
// // }


// // @override
// // void initState() {
// //   super.initState();

// //   startTimer();
// // }


// //   Timer? _timer;
// //   int _start = 60;
// //   bool _isResendButtonEnabled = false;

// //   void startTimer() {
// //     const oneSec = Duration(seconds: 1);
// //     _timer = Timer.periodic(
// //       oneSec,
// //       (Timer timer) {
// //         if (_start == 0) {
// //           if (mounted) {
// //             setState(() {
// //               timer.cancel();
// //               _isResendButtonEnabled = true;
// //             });
// //           }
// //         } else {
// //           if (mounted) {
// //             setState(() {
// //               _start--;
// //             });
// //           }
// //         }
// //       },
// //     );
// //   }

// //   // Function to resend the OTP
// //   void resendOTP() {
// //     if (_isResendButtonEnabled) {
// //       setState(() {
// //         _start = 60; // Reset the timer
// //         _isResendButtonEnabled = false;
// //         otpCtrl.text = "";
// //       });

      
// //     }
// //   }
  



// //   @override
// //   Widget build(BuildContext context) {
// //     const focusedBorderColor = AppColor.primary;
// //     const fillColor = Color.fromRGBO(243, 246, 249, 0);
// //     const borderColor = AppColor.primary;

// //     final defaultPinTheme = PinTheme(
// //       width: 56,
// //       height: 56,
// //       textStyle: const TextStyle(
// //         fontSize: 22,
// //         color: AppColor.primary,
// //       ),
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(19),
// //         border: Border.all(color: AppColor.darker),
// //       ),
// //     );
// //     return Scaffold(
// //         appBar: AppBar(
// //           backgroundColor: Colors.transparent,
// //           elevation: 0,
// //           title: Text("Back"),
// //         ),
// //         body: Padding(
// //           padding: const EdgeInsets.all(20.0),
// //           child: Form(
// //             key: loginForm,
// //             autovalidateMode: AutovalidateMode.onUserInteraction,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text("OTP Have Been Send !",
// //                         style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColor.mainColor)),
                  
// //                     SizedBox(height: 10),
// //                     Text("We Send You Email Please Check Your Mail And Complete The OTP Code.... ",
// //                         style: TextStyle(fontSize: 14, color: AppColor.grey)),
// //                 const SizedBox(height: 8.0),
              
// //                 const SizedBox(height: 30.0),
// //               Center(child:  Pinput(
// //                   length: 6,
// //                   controller: otpCtrl,
// //                   focusNode: otpFocusNode,
                
                  
// //                   defaultPinTheme: defaultPinTheme,
// //                   separatorBuilder: (index) => const SizedBox(width: 8.0),
// //                 validator: (value) {
// //   if (value == null || value.isEmpty || value.length != 6) {
// //     return 'Enter valid 6-digit OTP';
// //   }
// //   return null;
// // },

               
// //                   hapticFeedbackType: HapticFeedbackType.lightImpact,
// //                   onCompleted: (pin) {
// //                     // debugPrint('onCompleted: $pin');
// //                   },
// //                   onChanged: (value) {
// //                     // debugPrint('onChanged: $value');
// //                   },
// //                   cursor: Column(
// //                     mainAxisAlignment: MainAxisAlignment.end,
// //                     children: [
// //                       Container(
// //                         margin: const EdgeInsets.only(bottom: 9.0),
// //                         width: 22.0,
// //                         height: 1.0,
// //                         color: focusedBorderColor,
// //                       ),
// //                     ],
// //                   ),
// //                   focusedPinTheme: defaultPinTheme.copyWith(
// //                     decoration: defaultPinTheme.decoration!.copyWith(
// //                       borderRadius: BorderRadius.circular(8),
// //                       border: Border.all(color: focusedBorderColor),
// //                     ),
// //                   ),
// //                   submittedPinTheme: defaultPinTheme.copyWith(
// //                     decoration: defaultPinTheme.decoration!.copyWith(
// //                       color: fillColor,
// //                       borderRadius: BorderRadius.circular(19),
// //                       border: Border.all(color: focusedBorderColor),
// //                     ),
// //                   ),
// //                   errorPinTheme: defaultPinTheme.copyBorderWith(
// //                     border: Border.all(color: AppColor.actionColor),
// //                   ),
// //                 )),
// //                 const SizedBox(height: 20.0),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
             
// //                   ],
// //                 ),
              
// //                 const SizedBox(height: 20.0),
// //                SizedBox(
// //                       width: double.infinity,
// //                       height: 50,
// //                       child: ElevatedButton(
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: AppColor.primary,
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                         ),
// //                         onPressed: () {
// //                              Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             builder: (context) =>  Homepage(),
// //                           ),
// //                         );
// //                         },
// //                         child: Text(
// //                           "Verify",
// //                           style: TextStyle(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                             color: AppColor.white,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                 const SizedBox(height: 20.0),
             
// //               ],
// //             ),
// //           ),
// //         ),
 

// //         );
// //   }
// // }




















// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:get/get.dart';
// // import 'package:pinput/pinput.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../constants/app_assets.dart';
// // import '../../constants/app_colors.dart';
// // import '../../controllers/base_controller.dart';
// // import '../../services/asparents_api_service.dart';
// // import '../../services/comFuncService.dart';
// // import '../../widgets/sub_heading_widget.dart';
// // import '../maincontainer.dart';
// // import '../plan/plandetails_model.dart';
// // import '../plan/planlist_screen.dart';
// // import 'login_model.dart';


// // class OtpVerificationPage extends StatefulWidget {
// //   final String? phoneNumber;
// //   final int? otp;

// //   OtpVerificationPage({Key? key, this.phoneNumber, this.otp}) : super(key: key);

// //   @override
// //   State<OtpVerificationPage> createState() => _OtpVerificationPageState();
// // }

// // class _OtpVerificationPageState extends State<OtpVerificationPage> {
// //   final AsparentsApiService apiService = AsparentsApiService();
// //   final List<TextEditingController> _otpControllers =
// //       List.generate(6, (_) => TextEditingController());

// //   TextEditingController otpCtrl = TextEditingController();
// //   BaseController baseCtrl = Get.put(BaseController());
// //   final GlobalKey<FormState> loginForm = GlobalKey<FormState>();

// //   final otpFocusNode = FocusNode();
// //   // @override
// //   // void dispose() {
// //   //   _timer?.cancel(); // Cancel the timer when the widget is disposed
// //   //   for (var controller in _otpControllers) {
// //   //     controller.dispose();
// //   //   }
// //   //   super.dispose();
// //   // }

// //   @override
// //   void dispose() {
// //     _timer?.cancel(); // Cancel the timer when the widget is disposed
// //     otpCtrl.dispose(); // Dispose the controller as well
// //     super.dispose();
// //   }

// //   @override
// //   void initState() {
// //     //  setState(() {
// //     //    otpCtrl.text = widget.otp.toString();
// //     //  });

// //     super.initState();
// //     startTimer();
// //   }

// //   Timer? _timer;
// //   int _start = 60;
// //   bool _isResendButtonEnabled = false;

// //   void startTimer() {
// //     const oneSec = Duration(seconds: 1);
// //     _timer = Timer.periodic(
// //       oneSec,
// //       (Timer timer) {
// //         if (_start == 0) {
// //           if (mounted) {
// //             setState(() {
// //               timer.cancel();
// //               _isResendButtonEnabled = true;
// //             });
// //           }
// //         } else {
// //           if (mounted) {
// //             setState(() {
// //               _start--;
// //             });
// //           }
// //         }
// //       },
// //     );
// //   }

// //   // Function to resend the OTP
// //   void resendOTP() {
// //     if (_isResendButtonEnabled) {
// //       setState(() {
// //         _start = 60; // Reset the timer
// //         _isResendButtonEnabled = false;
// //         otpCtrl.text = "";
// //       });

// //       login();
// //     }
// //   }

// //   // myprofile
// //   // List<AddressList> myprofilepage = [];
// //   // List<AddressList> myprofilepageAll = [];
// //   // bool isLoading = false;

// //   // String? auth;

// //   // Future getalladdressList() async {
// //   //   await apiService.getBearerToken();
// //   //   setState(() {
// //   //     isLoading = true;
// //   //   });

// //   //   try {
// //   //     var result = await apiService.getloginalladdressList(auth);
// //   //     var response = addressListmodelFromJson(result);
// //   //     if (response.status.toString() == 'SUCCESS') {
// //   //       setState(() {
// //   //         myprofilepage = response.list;
// //   //         myprofilepageAll = myprofilepage;
// //   //         isLoading = false;
// //   //       });
// //   //       // if (loginStatus == true) {
// //   //       Navigator.pushNamedAndRemoveUntil(
// //   //           context, '/home', ModalRoute.withName('/home'));
// //   //       // } else {
// //   //       //   Navigator.pushNamedAndRemoveUntil(
// //   //       //       context, '/login', ModalRoute.withName('/login'));
// //   //       // }
// //   //     } else {
// //   //       setState(() {
// //   //         myprofilepage = [];
// //   //         myprofilepageAll = [];
// //   //         isLoading = false;
// //   //       });
// //   //       Navigator.push(
// //   //         context,
// //   //         MaterialPageRoute(
// //   //           builder: (context) => FillyourAddresspage(),
// //   //         ),
// //   //       );
// //   //       // showInSnackBar(context, response.message.toString());
// //   //       print(response.message.toString());
// //   //     }
// //   //   } catch (e) {
// //   //     setState(() {
// //   //       myprofilepage = [];
// //   //       myprofilepageAll = [];
// //   //       isLoading = false;
// //   //       Navigator.push(
// //   //         context,
// //   //         MaterialPageRoute(
// //   //           builder: (context) => FillyourAddresspage(),
// //   //         ),
// //   //       );
// //   //     });
// //   //     // showInSnackBar(context, 'Error occurred: $e');
// //   //     print('Error occurred: $e');
// //   //   }
// //   // }

// //   Future login() async {
// //     print("token ${baseCtrl.fbUserId}");
// //     try {
// //       //  showInSnackBar(context, 'Processing...');
// //       showSnackBar(context: context, showClose: false);
// //       startTimer();
// //       if (loginForm.currentState!.validate()) {
// //         Map<String, dynamic> postData = {
// //           'mobile': widget.phoneNumber,
// //           'otp': otpCtrl.text,
// //           'mobile_push_id': ""
// //         };
// //         var result = await apiService.userLoginWithOtp(postData);
// //         LoginOtpModel response = loginOtpModelFromJson(result);
// //         print("postdata $postData");
// //         closeSnackBar(context: context);

// //         if (response.status.toString() == 'SUCCESS') {
// //           final prefs = await SharedPreferences.getInstance();

// //           if (response.authToken != null) {
// //             //Navigator.pushNamed(context, '/');
// //             prefs.setString('auth_token', response.authToken ?? '');
// //             prefs.setBool('isLoggedin', true);
// //               prefs.setBool('admin', false);
// //             // auth = response.authToken ?? '';
// //            getplandetails();
            
           
// //           }
// //         } else  if (response.code.toString() == '211'){
// //           showInSnackBar(context, "Please Enter valid OTP");
// //         }else {
// //           showInSnackBar(context, response.message.toString());
// //         }
// //       } else {
// //         showInSnackBar(context, "Please fill required fields");
// //       }
// //     } catch (error) {
// //       showInSnackBar(context, error.toString());
// //     }
// //   }




// //     PlandetailsModel? plandetailsList;
// //    bool isLoading = false;


// //  Future<void> getplandetails() async {
// //   await apiService.getBearerToken();
// //   setState(() {
// //     isLoading = true;
// //   });

// //   try {
// //     var result = await apiService.getplandetails();
// //     print("Response body: $result");  

// //     var response = plandetailsModelFromJson(result);


// //     if (response.status == 'SUCCESS') {
// //         final prefs = await SharedPreferences.getInstance();

// //             //Navigator.pushNamed(context, '/');
// //           //  prefs.setString('planstatus', response.status ?? '');
// //             prefs.setBool('planstatus', true);
// //       setState(() {
// //         print("test1");
// //         plandetailsList = response;
       
// //   Navigator.push(
// //                 context,
// //                 MaterialPageRoute(
// //                   builder: (context) => MainContainer(),
// //                 ),
// //               );
// //         isLoading = false;

// //       });
// //     } else {
// //        final prefs = await SharedPreferences.getInstance();
// //         prefs.setBool('planstatus', false);
// //       setState(() {
// //         plandetailsList = null;
// //          Navigator.push(
// //                 context,
// //                 MaterialPageRoute(
// //                   builder: (context) => PlanListScreen(),
// //                 ),
// //               );
// //         isLoading = false;
// //       });
// //     }
// //   } catch (e) {
// //      final prefs = await SharedPreferences.getInstance();
// //         prefs.setBool('planstatus', false);
// //     setState(() {
// //       plandetailsList = null;
// //      Navigator.push(
// //                 context,
// //                 MaterialPageRoute(
// //                   builder: (context) => PlanListScreen(),
// //                 ),
// //               );
// //       isLoading = false;
// //     });
// //     print('dError occurred: $e');
// //   }
// // }

// //   @override
// //   Widget build(BuildContext context) {
// //     const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
// //     const fillColor = Color.fromRGBO(243, 246, 249, 0);
// //     const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

// //     final defaultPinTheme = PinTheme(
// //       width: 56,
// //       height: 56,
// //       textStyle: const TextStyle(
// //         fontSize: 22,
// //         color: Color.fromRGBO(30, 60, 87, 1),
// //       ),
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(19),
// //         border: Border.all(color: borderColor),
// //       ),
// //     );
// //     return Scaffold(
// //         appBar: AppBar(
// //           backgroundColor: Colors.transparent,
// //           elevation: 0,
// //           title: Text("Back"),
// //         ),
// //         body: Padding(
// //           padding: const EdgeInsets.all(20.0),
// //           child: Form(
// //             key: loginForm,
// //             autovalidateMode: AutovalidateMode.onUserInteraction,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Text(
// //                   'Verify with OTP sent to',
// //                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
// //                 ),
// //                 const SizedBox(height: 8.0),
// //                 Row(
// //                   children: [
// //                     Text(
// //                       "+91 ",
// //                       style: const TextStyle(fontSize: 16, color: Colors.grey),
// //                     ),
// //                     Text(
// //                       widget.phoneNumber.toString(),
// //                       style: const TextStyle(fontSize: 16, color: Colors.grey),
// //                     )
// //                   ],
// //                 ),
// //                 const SizedBox(height: 30.0),
// //               Center(child:  Pinput(
// //                   length: 6,
// //                   controller: otpCtrl,
// //                   focusNode: otpFocusNode,
// //                   androidSmsAutofillMethod:
// //                       AndroidSmsAutofillMethod.smsUserConsentApi,
// //                   listenForMultipleSmsOnAndroid: true,
                  
// //                   defaultPinTheme: defaultPinTheme,
// //                   separatorBuilder: (index) => const SizedBox(width: 8.0),
// //                   validator: (value) {
// //                     // return value.toString() == orgOtp.toString()
// //                     //     ? null
// //                     //     : 'OTP is incorrect';
// //                   },
// //                   // onClipboardFound: (value) {
// //                   //   debugPrint('onClipboardFound: $value');
// //                   //   pinController.setText(value);
// //                   // },
// //                   hapticFeedbackType: HapticFeedbackType.lightImpact,
// //                   onCompleted: (pin) {
// //                     // debugPrint('onCompleted: $pin');
// //                   },
// //                   onChanged: (value) {
// //                     // debugPrint('onChanged: $value');
// //                   },
// //                   cursor: Column(
// //                     mainAxisAlignment: MainAxisAlignment.end,
// //                     children: [
// //                       Container(
// //                         margin: const EdgeInsets.only(bottom: 9.0),
// //                         width: 22.0,
// //                         height: 1.0,
// //                         color: focusedBorderColor,
// //                       ),
// //                     ],
// //                   ),
// //                   focusedPinTheme: defaultPinTheme.copyWith(
// //                     decoration: defaultPinTheme.decoration!.copyWith(
// //                       borderRadius: BorderRadius.circular(8),
// //                       border: Border.all(color: focusedBorderColor),
// //                     ),
// //                   ),
// //                   submittedPinTheme: defaultPinTheme.copyWith(
// //                     decoration: defaultPinTheme.decoration!.copyWith(
// //                       color: fillColor,
// //                       borderRadius: BorderRadius.circular(19),
// //                       border: Border.all(color: focusedBorderColor),
// //                     ),
// //                   ),
// //                   errorPinTheme: defaultPinTheme.copyBorderWith(
// //                     border: Border.all(color: AppColors.danger),
// //                   ),
// //                 )),
// //                 const SizedBox(height: 20.0),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     if (_start == 0)
// //                       GestureDetector(
// //                         onTap: _isResendButtonEnabled ? resendOTP : null,
// //                         child: SubHeadingWidget(
// //                             title: 'Resend OTP',
// //                             color: AppColors.primary,
// //                             vMargin: 2.0),
// //                       ),
// //                     if (_start == 0)
// //                       Align(
// //                         alignment: Alignment.centerRight,
// //                         child: SubHeadingWidget(
// //                             title: 'Please wait $_start seconds',
// //                             color: AppColors.danger,
// //                             vMargin: 2.0),
// //                       ),
// //                   ],
// //                 ),
// //                 if (_start != 0)
// //                   Align(
// //                     alignment: Alignment.centerRight,
// //                     child: SubHeadingWidget(
// //                         title: 'Please wait $_start seconds',
// //                         color: AppColors.danger,
// //                         vMargin: 2.0),
// //                   ),
// //                 const SizedBox(height: 20.0),
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: ElevatedButton(
// //                     onPressed: () {
// //                       // Navigator.push(
// //                       //   context,
// //                       //   MaterialPageRoute(
// //                       //     builder: (context) => MainContainer(),
// //                       //   ),
// //                       // );

// //                      login();
// //                       print(
// //                           'OTP entered: ${_otpControllers.map((c) => c.text).join()}');
// //                     },
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: AppColors.ablue,
// //                       padding: const EdgeInsets.symmetric(vertical: 14.0),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(8.0),
// //                       ),
// //                     ),
// //                     child: const Text(
// //                       'Continue',
// //                       style: TextStyle(fontSize: 16.0, color: Colors.white),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 20.0),
// //                 // const Center(
// //                 //   child: Text(
// //                 //     'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod',
// //                 //     textAlign: TextAlign.center,
// //                 //     style: TextStyle(fontSize: 14, color: Colors.grey),
// //                 //   ),
// //                 // ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       bottomNavigationBar: Padding(
// //   padding: const EdgeInsets.only(bottom: 10.0),
// //   child: Image.asset(
// //     AppAssets.otpscreenlogo,
// //     width: 60,  // Decreased size from 100 to 60
// //     height: 40, // Explicitly setting height for better control
// //     fit: BoxFit.contain, // Ensures the image maintains its aspect ratio
// //   ),
// // ),

// //         );
// //   }
// // }