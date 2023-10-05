// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import 'cement_page.dart';
import 'element_card.dart';

// ignore: camel_case_types
class incoming_screen extends StatefulWidget {
  const incoming_screen({super.key});

  @override
  State<incoming_screen> createState() => _incoming_screenState();
}

// ignore: camel_case_types
class _incoming_screenState extends State<incoming_screen> {
  int cement = 0;
  int sand = 0;
  int aggregate = 0;

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void updateDataAndCheckInternet() async {
    bool hasInternet = await checkInternetConnectivity();
    if (hasInternet) {
      await updateDataInDatabase();
    } else {
      // ignore: avoid_print
      print('No internet connection available. Data update postponed.');
    }
  }

  Future<void> _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (cement == 0) {
        // Load cement only if it hasn't been initialized
        cement = prefs.getInt('cement') ?? 0;
        // ignore: avoid_print
        print(cement);
      }
      if (sand == 0) {
        // Load sand only if it hasn't been initialized
        sand = prefs.getInt('sand') ?? 0;
        // ignore: avoid_print
        print(sand);
      }
      if (aggregate == 0) {
        // Load aggregate only if it hasn't been initialized
        aggregate = prefs.getInt('aggregate') ?? 0;
        // ignore: avoid_print
        print(aggregate);
      }
      // ignore: avoid_print
      print('Cement: $cement, Sand: $sand, Aggregate: $aggregate');
    });
  }

  void storeNumberInDatabase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasInternet = await checkInternetConnectivity();

    setState(() {
      prefs.setInt('cement', cement);
      prefs.setInt('sand', sand);
      prefs.setInt('aggregate', aggregate);
    });

    if (hasInternet) {
      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        DocumentReference docRef = firestore.collection('incoming').doc('doc');

        await docRef.set({
          'sand': sand.toString(),
          'cement': cement.toString(),
          'aggregate': aggregate.toString(),
        });

        Get.snackbar("رسالة", "تم ارسال البيانات بنجاح",
            snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar("Error", "$e", snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void startDataUpdateTimer() {
    Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      updateDataAndCheckInternet();
    });
  }

  @override
  void initState() {
    super.initState();
    loadCostsandData();
    loadCostcementdData();
    loadCostaggregateData();
    _loadCounter();
    // startDataUpdateTimer();
  }

  Future<void> updateDataInDatabase() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference docRef = firestore.collection('incoming').doc('doc');

      await docRef.set({
        'sand': sand,
        'cement': cement,
        'aggregate': aggregate,
      });

      // ignore: avoid_print
      print('Data stored in the database successfully!');
    } catch (e) {
      // ignore: avoid_print
      print('Error storing data in the database: $e');
    }

    // ignore: avoid_print
    print('Data updated successfully!');
    Get.snackbar("تحديث", "تم تحديث البيانات ",
        snackPosition: SnackPosition.BOTTOM);
  }

  double totalCementPrice = 0.0;

  bool _isLoading = false;
  Future<void> loadCostcementdData() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot = await firestore
          .collection('total_cement')
          .doc('total_cement_price')
          .get();

      setState(
        () {
          totalCementPrice = snapshot['totalCost'] ?? 0;
        },
      );
      setState(
        () {
          _isLoading = false;
        },
      );
    } catch (e) {
      print('Error loading cost data: $e');
    }
  }

  double totalsandtPrice = 0.0;

  // bool _isLoading = false;
  Future<void> loadCostsandData() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot = await firestore
          .collection('total_sand')
          .doc('total_sand_price')
          .get();

      setState(
        () {
          totalsandtPrice = snapshot['totalCost'] ?? 0;
        },
      );
      setState(
        () {
          _isLoading = false;
        },
      );
    } catch (e) {
      print('Error loading cost data: $e');
    }
  }

  double totalaggregatetPrice = 0.0;

  // bool _isLoading = false;
  Future<void> loadCostaggregateData() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot = await firestore
          .collection('total_aggregate')
          .doc('total_aggregate_price')
          .get();

      setState(
        () {
          totalaggregatetPrice = snapshot['totalCost'] ?? 0;
        },
      );
      setState(
        () {
          _isLoading = false;
        },
      );
    } catch (e) {
      print('Error loading cost data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      resizeToAvoidBottomInset: false,
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.pink[800],
        previousPageTitle: "رجوع",
        middle: Text(
          "صفحة الـواردات",
          style: TextStyle(
              fontFamily: "myfont", fontSize: 25, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const CircularProgressIndicator() // Display the loading indicator
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Get.toNamed("/cement");
                  },
                  child: ElementCard(
                    elementName: 'الأسمنت',
                    elementValue: totalCementPrice.toInt(),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.toNamed("/sand");
                  },
                  child: ElementCard(
                    elementName: 'الرمل',
                    elementValue: totalsandtPrice.toInt(),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.toNamed("/aggregate");
                  },
                  child: ElementCard(
                    elementName: 'الحصو',
                    elementValue: totalaggregatetPrice.toInt(),
                  ),
                ),
                // Spacer(),
                const SizedBox(
                  height: 200,
                ),
              ],
            ),
    );
  }
}
