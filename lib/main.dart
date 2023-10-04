// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slab_factory_management/screens/incoming/Incoming_page.dart';
import 'package:slab_factory_management/screens/home/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:slab_factory_management/screens/production/production_page.dart';
import 'screens/login/login_page.dart';
import 'screens/notes/notes_page.dart';
import 'screens/outputing/out_page.dart';
import 'screens/report/report_page.dart';
import 'screens/worker_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertinoDialog,
      initialRoute: "/Production",
      getPages: [
        GetPage(
          name: "/home",
          page: () => const home_screen(),
        ),
        GetPage(
          name: "/login",
          page: () => const login_page(),
        ),
        GetPage(
          name: "/incoming",
          page: () => const incoming_screen(),
        ),
        GetPage(
          name: "/out",
          page: () => const out_screen(),
        ),
        GetPage(
          name: "/worker",
          page: () => const WorkersPage(),
        ),
        GetPage(
          name: "/Production",
          page: () => const ProductionPage(),
        ),
        GetPage(
          name: "/notes",
          page: () => const NotesPage(),
        ),
        GetPage(
          name: "/report",
          page: () => const report(),
        ),
     
      ],
    );
  }
}
