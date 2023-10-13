// ignore_for_file: file_names, avoid_print

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

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

  @override
  void initState() {
    super.initState();
    loadCostsandData();
    loadCostcementdData();
    loadCostaggregateData();
    // startDataUpdateTimer();
  }

  int totalCementPrice = 0;

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
      print('Error loading cost data aa: $e');
    }
  }

  int totalsandtPrice = 0;

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

  int totalaggregatetPrice = 0;

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
      print('Error loading cost data ff: $e');
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
        middle: const Text(
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
