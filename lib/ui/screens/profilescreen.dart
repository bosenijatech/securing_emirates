
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/app_color.dart';

class Profilescreen extends StatefulWidget {
  final String employeeName;
  const Profilescreen({super.key, required this.employeeName});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  String employeeName = "Employee";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    
  }

 Future<void> _loadProfile() async {
  // Simulate API or SharedPreferences loading
  await Future.delayed(const Duration(seconds: 2));

  setState(() {
    
    employeeName = widget.employeeName;
    isLoading = false; 
  });
}


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: AppColor.bgLight,
             scrolledUnderElevation: 0,
   excludeHeaderSemantics: true, 
              title: const Text("Profile"),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 60,
                              // backgroundImage: AssetImage("assets/profile.jpg"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          employeeName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text('Team Leader'),
                        const SizedBox(height: 10),
                        const Text('UAE'),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Employee Details',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text('Name',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.primarylight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        employeeName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Mobile Number',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.primarylight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        '+971 - 600555333',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Email ID',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.primarylight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        'Rhonaliza@emiratescaptain.aes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Emirates Number',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal)),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.primarylight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        '091670 03223',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
