

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/app_color.dart';
import '../constant/pref.dart';

class Profilescreen extends StatefulWidget {
  final String employeeName;
  final String supervisorId;
  final String supervisor;
  const Profilescreen({super.key, required this.employeeName, required this.supervisorId, required this.supervisor});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  String employeeName = "Employee";
  String supervisorId = "123";
  String supervisor = "Team Lead";
  String email = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }



Future<void> _loadProfile() async {
  await Future.delayed(const Duration(seconds: 2)); 

  final prefs = await SharedPreferences.getInstance();
  final savedEmail = prefs.getString("UserEmail");
  print("Saved Email: $savedEmail");

  setState(() {
    employeeName = widget.employeeName;
    supervisorId = widget.supervisorId;
     supervisor = (widget.supervisor.isEmpty) ? "Team Lead" : widget.supervisor;
    email = savedEmail ?? "No email found"; 
    isLoading = false;
  });
}


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.black,
                              ),
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
                         Text(supervisor),
                        const SizedBox(height: 10),
                         Text('UAE'),
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
                      child: Text(
                        email.toString(),
                        style: const TextStyle(
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
