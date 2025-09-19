// import 'package:flutter/material.dart';

// import '../constant/app_assets.dart';
// import '../constant/app_color.dart';
// import '../widgets/custom_textfield.dart';
// import 'loginscreen.dart';
// import 'otp_verification_page.dart';

// class Signupscreen extends StatefulWidget {
//   const Signupscreen({super.key});

//   @override
//   State<Signupscreen> createState() => _SignupscreenState();
// }

// class _SignupscreenState extends State<Signupscreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController mobileController = TextEditingController();

//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmpasswordController =
//       TextEditingController();
//   bool isPasswordVisible = false;
//   bool isPasswordVisible1 = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.bgLight,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 24,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           "Welcome to",
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: AppColor.mainColor,
//                           ),
//                         ),
//                            SizedBox(width: 16,),
//                    Image.asset(AppAssets.hi,scale: 4,)
//                       ],
//                     ),
//                     Text(
//                       "Attendees",
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: AppColor.primary,
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       "Hello there, Register to continue",
//                       style: TextStyle(fontSize: 14, color: AppColor.litgrey),
//                     ),
//                     SizedBox(height: 20),

//                     CustomRoundedTextField(
//                       width: double.infinity,
//                       type: TextInputType.emailAddress,
//                       labelText: 'Email Address',
//                       control: emailController,
//                     ),
//                     SizedBox(height: 24),
//                     CustomRoundedTextField(
//                       width: double.infinity,
//                       type: TextInputType.number,
//                       labelText: 'Mobile Number',
//                       control: mobileController,
//                     ),

//                     SizedBox(height: 24),

//                     CustomRoundedTextField(
//                       width: double.infinity,
//                       type: TextInputType.text,
//                       labelText: 'Password',
//                       control: passwordController,
//                       obscureText: !isPasswordVisible,
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           isPasswordVisible
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                           color: AppColor.litgrey,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             isPasswordVisible = !isPasswordVisible;
//                           });
//                         },
//                       ),
//                     ),
//                     SizedBox(height: 24),
//                     CustomRoundedTextField(
//                       width: double.infinity,
//                       type: TextInputType.text,
//                       labelText: 'Confirm Password',
//                       control: confirmpasswordController,
//                       obscureText: !isPasswordVisible1,
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           isPasswordVisible1
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                           color: AppColor.litgrey,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             isPasswordVisible1 = !isPasswordVisible1;
//                           });
//                         },
//                       ),
//                     ),

//                     SizedBox(height: 30),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColor.primary,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => OtpVerificationPage(),
//                             ),
//                           );
//                         },
//                         child: Text(
//                           "Register",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: AppColor.white,
//                           ),
//                         ),
//                       ),
//                     ),
              
                  
                  
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 0),
//               child: Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Already have an account?",
//                       style: TextStyle(color: AppColor.grey),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const Loginscreen(),
//                           ),
//                         );
//                       },
//                       child: Text(
//                         "Login",
//                         style: TextStyle(
//                           color: AppColor.primary,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
