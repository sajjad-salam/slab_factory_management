// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

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
      print('No internet connection available. Data update postponed.');
    }
  }

  Future<void> _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (cement == 0) {
        // Load cement only if it hasn't been initialized
        cement = prefs.getInt('cement') ?? 0;
        print(cement);
      }
      if (sand == 0) {
        // Load sand only if it hasn't been initialized
        sand = prefs.getInt('sand') ?? 0;
        print(sand);
      }
      if (aggregate == 0) {
        // Load aggregate only if it hasn't been initialized
        aggregate = prefs.getInt('aggregate') ?? 0;
        print(aggregate);
      }
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
    _loadCounter();
    startDataUpdateTimer();
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

      print('Data stored in the database successfully!');
    } catch (e) {
      print('Error storing data in the database: $e');
    }

    print('Data updated successfully!');
    Get.snackbar("تحديث", "تم تحديث البيانات ",
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Builder(
          builder: (BuildContext context) {
            final double keyboardHeight =
                MediaQuery.of(context).viewInsets.bottom;
            final double maxHeight = MediaQuery.of(context).size.height - 120;
            final double contentHeight =
                MediaQuery.of(context).size.height - keyboardHeight - 200;
            final bool isKeyboardOpen = keyboardHeight > 0;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: isKeyboardOpen ? maxHeight : contentHeight,
                ),
                child: AlertDialog(
                  title: const Text(
                    'اضافة مواد',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: "myfont",
                      fontSize: 22,
                    ),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        textInputAction: TextInputAction.next,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          int intval = int.tryParse(value) ?? 0;
                          setState(() {
                            cement += intval;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'اسمنت',
                        ),
                      ),
                      TextField(
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          int intval = int.tryParse(value) ?? 0;
                          setState(() {
                            sand += intval;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'رمل',
                        ),
                      ),
                      TextField(
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          int intval = int.tryParse(value) ?? 0;
                          setState(() {
                            aggregate += intval;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'حصو',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        storeNumberInDatabase();
                        Navigator.of(context).pop();
                      },
                      child: const Text('حفض'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          sand = 0;
                          aggregate = 0;
                          cement = 0;
                        });
                      },
                      child: const Text('تصفير الكل'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          "صفحة الـواردات",
          style: TextStyle(fontFamily: "myfont", fontSize: 25),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElementCard(
            elementName: 'الأسمنت',
            elementValue: cement,
          ),
          ElementCard(
            elementName: 'الرمل',
            elementValue: sand,
          ),
          ElementCard(
            elementName: 'الحصو',
            elementValue: aggregate,
          ),
          // Spacer(),
          const SizedBox(
            height: 200,
          ),
          ElevatedButton(
            onPressed: () {
              _showSettingsDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20), // Make the button rounded
              ),
            ),
            child: const Text(
              'اضافة مواد',
              style: TextStyle(
                fontFamily: "myfont",
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ElementCard extends StatefulWidget {
  final String elementName;
  final int elementValue;

  const ElementCard({
    super.key,
    required this.elementName,
    required this.elementValue,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ElementCardState createState() => _ElementCardState();
}

class _ElementCardState extends State<ElementCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  widget.elementValue.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'myfont', // Set the custom font family
                  ),
                ),
                const SizedBox(
                    width: 10), // Adds spacing between the number and the name
                Expanded(
                  child: Text(
                    widget.elementName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'myfont', // Set the custom font family
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(
                height: 10), // Adds spacing between the elements and the button
          ],
        ),
      ),
    );
  }
}
