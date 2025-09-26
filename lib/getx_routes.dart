import 'package:get/get.dart';
import 'package:securing_emirates/ui/screens/checkinpage.dart';
import 'package:securing_emirates/ui/screens/homepage.dart';
import 'ui/authscreen/landingscreen.dart';
import 'ui/authscreen/loginscreen.dart';
import 'ui/screens/checkoutscreen.dart';
import 'ui/screens/employeereportspage.dart';
import 'ui/screens/regularizescreen.dart';


final List<GetPage> getPages = [
  GetPage(name: '/', page: () => const LandingScreen()),
  GetPage(name: '/login', page: () => const Loginscreen()),
  GetPage(name: '/home', page: () =>  Homepage(employeeName: '', supervisorId: '', supervisor: '',)),
  GetPage(name: '/checkin', page: () => const Checkinpage()),
  GetPage(name: '/employeereports', page: () => const Employeereportspage()),
    GetPage(name: '/regularize', page: () => const Regularizescreen(date: '', checkIn: '', checkOut: '', internalId: '', employee: '', hoursWorked: '', salesOrderId: '',)),
      GetPage(name: '/checkout', page: () =>  Checkoutscreen(internalId: '', timeIn: '',)),
];
