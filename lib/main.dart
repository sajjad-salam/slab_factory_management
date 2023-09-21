// ignore_for_file: avoid_print

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slab_factory_management/screens/Incoming_page.dart';
import 'package:slab_factory_management/screens/home/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/login_page.dart';
import 'screens/out_page.dart';
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
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertinoDialog,
      initialRoute: "/login",
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
          name: "/homme",
          page: () => const MyHomePage(),
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
          page: () => WorkersPage(),
        ),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadCounter();
    startDataUpdateTimer();
  }

  void startDataUpdateTimer() {
    Timer.periodic(Duration(minutes: 1), (Timer timer) {
      updateDataAndCheckInternet();
    });
  }

  void updateDataAndCheckInternet() async {
    bool hasInternet = await checkInternetConnectivity();
    if (hasInternet) {
      await updateDataInDatabase(_counter.toString());
    } else {
      print('No internet connection available. Data update postponed.');
    }
  }

  Future<void> updateDataInDatabase(String data) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference docRef =
          firestore.collection('counters').doc('myCounter');

      await docRef.set({
        'value': _counter,
      });

      print('Number stored in the database successfully!');
    } catch (e) {
      print('Error storing number in the database: $e');
    }
    print('Data updated successfully!');
    Get.snackbar("نقل", "تم نقل البيانات بنجاح",
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
      print(_counter);
    });
  }

  // التحقق من اتصال الانترنت
  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  TextEditingController numberController = TextEditingController();

  void storeNumberInDatabase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasInternet = await checkInternetConnectivity();

    String number = numberController.text;
    int intval = int.parse(number);
    setState(() {
      _counter = intval;
      prefs.setInt('counter', _counter);
    });

    if (hasInternet) {
      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        DocumentReference docRef =
            firestore.collection('counters').doc('myCounter');

        await docRef.set({
          'value': number,
        });

        Get.snackbar("رسالة ", "تم بنجاح", snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar("خطأ", "$e", snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "ادارة معمل شتايكر بغداد",
          style: TextStyle(fontFamily: "myfont", color: Colors.black),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'تيست',
              style: TextStyle(fontFamily: "myfont", fontSize: 22),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextField(
              controller: numberController,
              onSubmitted: (value) {
                setState(() {
                  int intValue = int.parse(numberController.text);

                  _counter = intValue;
                });
                storeNumberInDatabase();
              },
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: ' ادخل السعر ',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // _incrementCounter();
          Get.toNamed("/home");
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
