// ignore_for_file: avoid_print, prefer_const_constructors, use_build_context_synchronously, non_constant_identifier_names

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'day_page.dart';

class ProductionModel {
  String day;
  int productionQuantity;

  ProductionModel({
    required this.day,
    this.productionQuantity = 0,
  });
}

//  بيانات العمال

class ProductionPage extends StatefulWidget {
  const ProductionPage({super.key, required this.number_factory});
  final int number_factory;

  @override
  // ignore: library_private_types_in_public_api
  _ProductionPageState createState() =>
      _ProductionPageState(number_factory: number_factory);
}

class _ProductionPageState extends State<ProductionPage> {
  _ProductionPageState({required this.number_factory});
  final int number_factory;
  int totalWeeklyProduction = 0;
  bool _isLoading = false;
  String production = '';
  String inventory = '';
  int productionQuantity = 0;
  ProductionModel productionData = ProductionModel(day: 'Monday');
  TextEditingController productionController = TextEditingController();
  int total_in = 0;
  int weeklyProductionTotal = 0;
  int totalProduction = 0;
  String productionNumber = '';

  List<String> weeklySchedule = [
    'الأحد: 0',
    'الأثنين: 0',
    'الثلاثاء: 0',
    'الأربعاء: 0',
    'الخميس: 0',
    'الجمعة: 0',
    'السبت: 0',
  ];

  @override
  void dispose() {
    productionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadWeeklyDataFromStorage();
    getUnaffectedProductionTotal();
    gettotal_in();
  }

  void updateDataAndCheckInternet() async {
    bool hasInternet = await checkInternetConnectivity();
    if (hasInternet) {
      await saveWeeklyProductionToDatabase();
    } else {
      Get.snackbar("خطأ", "لا يوجد اتصال في الأنترنت ");
      print('No internet connection available. Data update postponed.');
    }
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void updateWeeklyProduction() {
    for (String scheduleEntry in weeklySchedule) {
      int productionNumber = int.tryParse(scheduleEntry.split(': ')[1]) ?? 0;
      totalProduction += productionNumber;
    }
    setState(() {
      totalWeeklyProduction = totalProduction;
      production = totalWeeklyProduction.toString();
    });
  }

  void openDayPage(String day) {
    for (String scheduleEntry in weeklySchedule) {
      if (scheduleEntry.startsWith(day)) {
        productionNumber = scheduleEntry.split(': ')[1];
        break;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayPage(
          number_factory: number_factory,
          day: day,
          productionNumber: productionNumber,
          totalWeeklyProduction: totalWeeklyProduction,
        ),
      ),
    ).then(
      (updatedProductionNumber) {
        if (updatedProductionNumber != null) {
          setState(
            () {
              for (int i = 0; i < weeklySchedule.length; i++) {
                if (weeklySchedule[i].startsWith(day)) {
                  weeklySchedule[i] = '$day: $updatedProductionNumber';
                  break;
                }
              }
              updateWeeklyProduction(); // Update the weekly production when a day's production is updated
              saveWeeklyScheduleToStorage(); // Save the updated weekly schedule to storage
              saveWeeklyProductionToDatabase(); // Save the updated weekly production to the database
            },
          );
        }
      },
    );
  }

  Future<void> saveWeeklyProductionToDatabase() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final firestore = FirebaseFirestore.instance;
      final collectionRef =
          firestore.collection('weekly_production$number_factory');

      // Clear the existing documents in the collection
      await collectionRef.get().then(
        (snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        },
      );

      int totalProduction = 0;

      for (String scheduleEntry in weeklySchedule) {
        final day = scheduleEntry.split(': ')[0];
        final productionNumber =
            int.tryParse(scheduleEntry.split(': ')[1]) ?? 0;

        totalProduction += productionNumber; // Accumulate the production number

        await collectionRef.doc(day).set(
          {
            'day': day,
            'productionNumber': productionNumber,
          },
        );
      }

      setState(
        () {
          weeklyProductionTotal =
              totalProduction; // Update the affected weekly production total
        },
      );

      print('Weekly production data saved to the database.');

      // Calculate the unaffected weekly production total separately
      int unaffectedTotal = 0;
      for (String scheduleEntry in weeklySchedule) {
        final productionNumber =
            int.tryParse(scheduleEntry.split(': ')[1]) ?? 0;
        unaffectedTotal += productionNumber;
      }
      unaffectedWeeklyProductionTotal = unaffectedTotal;

      // Save the unaffected weekly production total in device storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unaffectedProductionTotal$number_factory',
          unaffectedWeeklyProductionTotal);

      // Save the unaffected weekly production total in a new collection in the database
      await firestore
          .collection('unaffected_production$number_factory')
          .doc('total')
          .set(
        {
          'productionTotal': unaffectedWeeklyProductionTotal,
        },
      );
      Get.snackbar("رسالة", "تم بنجاح", snackPosition: SnackPosition.BOTTOM);
      setState(
        () {
          _isLoading = false;
        },
      );
    } catch (e) {
      print('Error saving weekly production to the database: $e');
    }
  }

  void getUnaffectedProductionTotal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedProductionTotal =
        prefs.getInt('unaffectedProductionTotal$number_factory') ?? 0;
    setState(
      () {
        unaffectedWeeklyProductionTotal = storedProductionTotal;
      },
    );
  }

  void gettotal_in() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('total_in').doc('total').get();

      setState(
        () {
          total_in = snapshot['productionTotal'] ?? 0;
        },
      );
      setState(
        () {
          _isLoading = false;
        },
      );
      print(total_in);
    } catch (e) {
      print('Error loading cost data: $e');
    }
  }

  Future<void> loadWeeklyDataFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('weeklySchedule$number_factory');
      final totalProduction =
          prefs.getInt('weeklyProductionTotal$number_factory');
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        setState(
          () {
            weeklySchedule = jsonList.map((json) => json.toString()).toList();
            weeklyProductionTotal = totalProduction ?? 0;
            production = weeklyProductionTotal.toString();
          },
        );
      }
    } catch (e) {
      print('Error loading weekly data from storage: $e');
    }
  }

  Future<void> saveWeeklyScheduleToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = weeklySchedule.map((entry) => entry).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString('weeklySchedule$number_factory', jsonString);
      await prefs.setInt(
          'weeklyProductionTotal$number_factory', weeklyProductionTotal);
    } catch (e) {
      print('Error saving weekly schedule to storage: $e');
    }
  }

  Future<void> loadWeeklyScheduleFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('weeklySchedule$number_factory');
      final totalProduction =
          prefs.getInt('totalWeeklyProduction$number_factory');
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        setState(
          () {
            weeklySchedule = jsonList.map((json) => json.toString()).toList();
            totalWeeklyProduction = totalProduction ?? 0;
            production = totalWeeklyProduction.toString();
          },
        );
      }
    } catch (e) {
      print('Error loading weekly schedule from storage: $e');
    }
  }

  int unaffectedWeeklyProductionTotal = 0;
  void calculateWeeklyProduction() {
    weeklyProductionTotal = 0;
    for (String scheduleEntry in weeklySchedule) {
      final productionNumber = int.tryParse(scheduleEntry.split(': ')[1]) ?? 0;
      weeklyProductionTotal += productionNumber;
    }
  }

  // void _showWarningDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('تحذير'),
  //         content: Text('هل تريد تصفير المخزون ؟'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               // Handle 'No' option
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('لا'),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               setState(() {
  //                 total_in = 0;
  //               });
  //               final firestore = FirebaseFirestore.instance;
  //               SharedPreferences prefs = await SharedPreferences.getInstance();

  //               await prefs.setInt('total_in', total_in);
  //               // Save the unaffected weekly production total in a new collection in the database
  //               await firestore.collection('total_in').doc('total').set({
  //                 'productionTotal': total_in,
  //               });
  //               // Handle 'Yes' option
  //               // Call your function or perform the desired action here
  //               Navigator.of(context).pop();
  //               // Add your logic here
  //             },
  //             child: Text('نعم'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          "صفحة الأنتاخ",
          style: TextStyle(fontFamily: "myfont", fontSize: 25),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              textAlign: TextAlign.end,
              'الأنتاخ الأسبوعي',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "myfont"),
            ),
            const SizedBox(height: 10),
            Text(unaffectedWeeklyProductionTotal.toString()),
            const SizedBox(height: 20),
            const Text(
              'المخزون',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "myfont"),
            ),
            const SizedBox(height: 10),
            Text(total_in.toString()),
            const SizedBox(height: 20),
            const Text(
              'الأنتاخ اليومي',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "myfont"),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: weeklySchedule.length,
                itemBuilder: (context, index) {
                  String scheduleEntry = weeklySchedule[index];
                  String day = scheduleEntry.split(': ')[0];
                  String productionNumber = scheduleEntry.split(': ')[1];
                  return ListTile(
                    title: Text(
                      textAlign: TextAlign.end,
                      day,
                      style: TextStyle(
                        fontFamily: "myfont",
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Text(
                      productionNumber,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontFamily: "myfont",
                        fontSize: 20,
                      ),
                    ),
                    onTap: () {
                      openDayPage(day);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // Display the loading indicator
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        weeklyProductionTotal = 0;
                        for (int i = 0; i < weeklySchedule.length; i++) {
                          final day = weeklySchedule[i].split(': ')[0];
                          weeklySchedule[i] =
                              '$day: 0'; // Set the day number to 0
                        }
                        calculateWeeklyProduction();
                        production =
                            weeklyProductionTotal.toString(); // Update the UI
                      });
                      saveWeeklyScheduleToStorage();
                      saveWeeklyProductionToDatabase();
                      print(unaffectedWeeklyProductionTotal);
                    },
                    child: Text(
                      'تصفير الأسبوع',
                      style: TextStyle(
                        fontFamily: "myfont",
                        fontSize: 20,
                      ),
                    ),
                  ),

            // ElevatedButton(
            //   onPressed: () {
            //     _showWarningDialog(context);
            //   },
            //   child: Text(
            //     'تصفير المخزون',
            //     style: TextStyle(
            //       fontFamily: "myfont",
            //       fontSize: 20,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
