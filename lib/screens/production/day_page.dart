import 'package:flutter/cupertino.dart';
import 'package:slab_factory_management/screens/production/production_page.dart';

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DayPage extends StatefulWidget {
  final String day;
  final String productionNumber;

  const DayPage({
    Key? key,
    required this.day,
    required this.productionNumber,
    required int totalWeeklyProduction,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DayPageState createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {
  @override
  void initState() {
    super.initState();

    loadWeeklyDataFromStorage();
    getUnaffectedProductionTotal();
    gettotal_in();
    gettotal_in2();
    loadCostData();
  }

//  بيانات العمال
  String selectedWorker = 'Hamza'; // Default worker
  int productionQuantity = 0;
  int hamzaCost = 0;
  int muhammadCost = 0;
  int philanthropistCost = 0;
  int totalCost = 0;
  bool _isLoading = false;

  Future<void> loadCostData() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('costData').doc('cost').get();

      setState(
        () {
          hamzaCost = snapshot['hamzaCost'] ?? 0;
          muhammadCost = snapshot['muhammadCost'] ?? 0;
          philanthropistCost = snapshot['philanthropistCost'] ?? 0;
          totalCost = snapshot['totalCost'] ?? 0;
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

  Future<void> saveCostData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('workers').doc('cost').set({
        'hamzaCost': hamzaCost,
        'muhammadCost': muhammadCost,
        'philanthropistCost': philanthropistCost,
        'totalCost': totalCost,
      });
    } catch (e) {
      print('Error saving cost data: $e');
    }
  }

  TextEditingController productionController = TextEditingController();

  int totalWeeklyProduction = 0;

  List<String> weeklySchedule = [
    'الأحد: 100',
    'الأثنين: 120',
    'الثلاثاء: 90',
    'الأربعاء: 110',
    'الخميس: 80',
    'الجمعة: 70',
    'السبت: 60',
  ];

  String production = '';
  String inventory = '';

  @override
  void dispose() {
    productionController.dispose();
    super.dispose();
  }

  TextEditingController noteController = TextEditingController();

  MaterialStateProperty<Color?> amberColor =
      MaterialStateProperty.all<Color?>(const Color.fromARGB(255, 105, 63, 0));

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

  int weeklyProductionTotal = 0;
  // هذا المتغير هو المخزون الكلي
  int total_in = 0;
  int total_in2 = 0;

  int totalProduction = 0;
  void updateWeeklyProduction() {
    for (String scheduleEntry in weeklySchedule) {
      int productionNumber = int.tryParse(scheduleEntry.split(': ')[1]) ?? 0;
      totalProduction += productionNumber;
    }
    setState(
      () {
        totalWeeklyProduction = totalProduction;
        production = totalWeeklyProduction.toString();
      },
    );
  }

  void openDayPage(String day) {
    String productionNumber = '';
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
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      CollectionReference workcollection = firestore.collection('workers');

      await workcollection.doc('workersData').set(
        {
          'workers': workers.map((worker) => worker.toJson()).toList(),
        },
      );
      final collectionRef = firestore.collection('weekly_production');
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
          weeklyProductionTotal = totalProduction;
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

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          'unaffectedProductionTotal', unaffectedWeeklyProductionTotal);
      await firestore.collection('unaffected_production').doc('total').set(
        {
          'productionTotal': unaffectedWeeklyProductionTotal,
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

  void gettotal_in2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedProductionTotal = prefs.getInt('total_in2') ?? 0;
    setState(
      () {
        total_in2 = storedProductionTotal;
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
            weeklySchedule = jsonList
                .map(
                  (json) => json.toString(),
                )
                .toList();
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

  TextEditingController productionQuantit = TextEditingController();

  String updatedProduction = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          'انتاخ ${widget.day} ',
          style: const TextStyle(fontFamily: "myfont"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 10),
            CupertinoTextField(
              onChanged: (value) {
                setState(
                  () {
                    productionQuantity = int.tryParse(value) ?? 0;
                  },
                );
              },
              decoration: BoxDecoration(
                // color: CupertinoColors.extraLightBackgroundGray,
                borderRadius: BorderRadius.circular(10),
              ),
              controller: productionController,
              autocorrect: true,
              textInputAction: TextInputAction.done,

              placeholder: "....ادخل كمية الأنتاخ هنا",
              // maxLength: 10,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFamily: "myfont",
                color: Color.fromARGB(255, 0, 0, 0), // Set the color to white
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedWorker,
              onChanged: (worker) {
                setState(
                  () {
                    selectedWorker = worker!;
                  },
                );
              },
              items: const [
                DropdownMenuItem<String>(
                  value: 'Hamza',
                  child: Text('Hamza'),
                ),
                DropdownMenuItem<String>(
                  value: 'Muhammad',
                  child: Text('Muhammad'),
                ),
                DropdownMenuItem<String>(
                  value: 'Philanthropist',
                  child: Text('Philanthropist'),
                ),
              ],
            ),
            Text('Selected Worker: $selectedWorker'),
            Text('Production Quantity: $productionQuantity'),
            Text('Hamza Cost: $hamzaCost'),
            Text('Muhammad Cost: $muhammadCost'),
            Text('Philanthropist Cost: $philanthropistCost'),
            Text('total Cost: $totalCost'),
            const SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // Display the loading indicator
                : ElevatedButton(
                    onPressed: () async {
                      setState(
                        () {
                          _isLoading = true;
                        },
                      );
                      //  هاي بيانا تلاعمال
                      switch (selectedWorker) {
                        case 'Hamza':
                          hamzaCost += (productionQuantity * 600);
                          break;
                        case 'Muhammad':
                          muhammadCost += (productionQuantity * 600);
                          break;
                        case 'Philanthropist':
                          philanthropistCost += (productionQuantity * 600);
                          break;
                      }
                      totalCost = hamzaCost + muhammadCost + philanthropistCost;
                      saveCostData(); // هذه الدالة لحفض بيانات العمال في قاعدة البيانات

                      // updateDataAndCheckInternet();
                      saveWeeklyProductionToDatabase();
                      saveWeeklyScheduleToStorage();
                      final firestore = FirebaseFirestore.instance;

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      setState(
                        () {
                          updatedProduction = productionController.text;

                          // Navigate to the first screen
                          print(updatedProduction);
                          total_in += int.parse(updatedProduction);
                          total_in2 += int.parse(updatedProduction);
                        },
                      );
                      await prefs.setInt('total_in', total_in);
                      await prefs.setInt('total_in2', total_in2);
                      // Save the unaffected weekly production total in a new collection in the database
                      await firestore.collection('total_in').doc('total').set(
                        {
                          'productionTotal': total_in,
                        },
                      );
                      await firestore.collection('total_in2').doc('total2').set(
                        {
                          'productionTotal': total_in2,
                        },
                      );
                      print(total_in);
                      print(total_in2);
                      setState(
                        () {
                          _isLoading = false;
                        },
                      );
                    },
                    child: const Text(
                      'تعديل',
                      style: TextStyle(fontFamily: "myfont", fontSize: 18),
                    ),
                  ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context, updatedProduction);
              },
              child: const Text(
                'خروخ',
                style: TextStyle(fontFamily: "myfont", fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
