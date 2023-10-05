// ignore_for_file: avoid_print, prefer_const_constructors, use_build_context_synchronously, non_constant_identifier_names

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'day_page.dart';

class ProductionModel {
  String day;
  int productionQuantity;
  List<Worker> selectedWorkers; // Change to List<Worker>

  ProductionModel({
    required this.day,
    this.productionQuantity = 0,
    this.selectedWorkers = const [],
  });
}

class Worker {
  final String name;
  double laborCost;

  Worker({required this.name, required this.laborCost});
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'laborCost': laborCost,
    };
  }

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      name: json['name'],
      laborCost: json['laborCost'].toDouble(),
    );
  }
  void incrementLaborCost(double value) {
    laborCost += value;
  }
}

//  بيانات العمال

Worker? selectedWorker;
List<Worker> workers = [
  Worker(name: 'حمزة فاضل', laborCost: 0),
  Worker(name: 'رسول عباس', laborCost: 0),
  Worker(name: 'محمد فهد', laborCost: 0),
  // Add more workers as needed
];

class ProductionPage extends StatefulWidget {
  const ProductionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductionPageState createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPage> {
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
    'الأحد: 100',
    'الأثنين: 120',
    'الثلاثاء: 90',
    'الأربعاء: 110',
    'الخميس: 80',
    'الجمعة: 70',
    'السبت: 60',
  ];
  Future<void> saveWorkersLocally(List<Worker> workers) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedWorkers = workers.map((worker) => worker.toJson()).toList();
    await prefs.setStringList('workers', encodedWorkers.cast<String>());
  }

// Function to load workers from local storage
  Future<List<Worker>> loadWorkersLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedWorkers = prefs.getStringList('workers') ?? [];
    return encodedWorkers
        .map((encodedWorker) =>
            Worker.fromJson(encodedWorker as Map<String, dynamic>))
        .toList();
  }

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
    loadWorkersFromFirestore();
  }

  Future<void> loadWorkersFromFirestore() async {
    setState(() {
      // _isLoading = true;
    });
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference workersCollection = firestore.collection('workers');
      QuerySnapshot querySnapshot = await workersCollection.get();
      List<Worker> loadedWorkers = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('name')) {
          loadedWorkers.add(Worker(
            name: data['name'],
            laborCost: data['laborCost'].toDouble(),
          ));
        }
      }

      setState(() {
        workers = loadedWorkers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data from Firestore: $e');
    }
  }

  void updateDataAndCheckInternet() async {
    bool hasInternet = await checkInternetConnectivity();
    if (hasInternet) {
      await saveWeeklyProductionToDatabase();
    } else {
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
      final collectionRef = firestore.collection('weekly_production');

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
      await prefs.setInt(
          'unaffectedProductionTotal', unaffectedWeeklyProductionTotal);

      // Save the unaffected weekly production total in a new collection in the database
      await firestore.collection('unaffected_production').doc('total').set(
        {
          'productionTotal': unaffectedWeeklyProductionTotal,
        },
      );

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
        prefs.getInt('unaffectedProductionTotal') ?? 0;
    setState(
      () {
        unaffectedWeeklyProductionTotal = storedProductionTotal;
      },
    );
  }

  void gettotal_in() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedProductionTotal = prefs.getInt('total_in') ?? 0;
    setState(
      () {
        total_in = storedProductionTotal;
      },
    );
  }

  Future<void> loadWeeklyDataFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('weeklySchedule');
      final totalProduction = prefs.getInt('weeklyProductionTotal');
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
      await prefs.setString('weeklySchedule', jsonString);
      await prefs.setInt('weeklyProductionTotal', weeklyProductionTotal);
    } catch (e) {
      print('Error saving weekly schedule to storage: $e');
    }
  }

  Future<void> loadWeeklyScheduleFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('weeklySchedule');
      final totalProduction = prefs.getInt('totalWeeklyProduction');
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
                        // _isLoading = true;
                        weeklyProductionTotal = 0;
                        for (int i = 0; i < weeklySchedule.length; i++) {
                          final day = weeklySchedule[i].split(': ')[0];
                          weeklySchedule[i] =
                              '$day: 0'; // Set the day number to 0
                        }
                        calculateWeeklyProduction(); // Recalculate the weekly production total
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
