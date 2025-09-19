import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:securing_emirates/ui/constant/app_color.dart';
import 'package:securing_emirates/ui/constant/pref.dart';
import 'getx_routes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  await Hive.initFlutter();

 
  await Hive.openBox('shiftBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      
      debugShowCheckedModeBanner: false,
      
      initialRoute: '/          ',
      getPages: getPages,
      theme: ThemeData(
      scaffoldBackgroundColor:AppColor.bgLight,
    ),
    );
  
  }
}
