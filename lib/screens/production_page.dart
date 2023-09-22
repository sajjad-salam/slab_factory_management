import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionPage extends StatefulWidget {
  const ProductionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductionPageState createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPage> {
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

  TextEditingController productionController = TextEditingController();

  String production = '';
  String inventory = '';

  @override
  void dispose() {
    productionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadWeeklyDataFromStorage();
    startDataUpdateTimer();
    getUnaffectedProductionTotal();
  }

  void startDataUpdateTimer() {
    Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      updateDataAndCheckInternet();
    });
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

  int weeklyProductionTotal = 0;

  int totalProduction = 0;
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
    ).then((updatedProductionNumber) {
      if (updatedProductionNumber != null) {
        setState(() {
          for (int i = 0; i < weeklySchedule.length; i++) {
            if (weeklySchedule[i].startsWith(day)) {
              weeklySchedule[i] = '$day: $updatedProductionNumber';
              break;
            }
          }

          updateWeeklyProduction(); // Update the weekly production when a day's production is updated
          saveWeeklyScheduleToStorage(); // Save the updated weekly schedule to storage
          saveWeeklyProductionToDatabase(); // Save the updated weekly production to the database
        });
      }
    });
  }

  Future<void> saveWeeklyProductionToDatabase() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final collectionRef = firestore.collection('weekly_production');

      // Clear the existing documents in the collection
      await collectionRef.get().then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      int totalProduction =
          0; // Initialize the variable to calculate the affected total

      for (String scheduleEntry in weeklySchedule) {
        final day = scheduleEntry.split(': ')[0];
        final productionNumber =
            int.tryParse(scheduleEntry.split(': ')[1]) ?? 0;

        totalProduction += productionNumber; // Accumulate the production number

        await collectionRef.doc(day).set({
          'day': day,
          'productionNumber': productionNumber,
        });
      }

      setState(() {
        weeklyProductionTotal =
            totalProduction; // Update the affected weekly production total
      });

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
      await firestore.collection('unaffected_production').doc('total').set({
        'productionTotal': unaffectedWeeklyProductionTotal,
      });
    } catch (e) {
      print('Error saving weekly production to the database: $e');
    }
  }

  void getUnaffectedProductionTotal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedProductionTotal =
        prefs.getInt('unaffectedProductionTotal') ?? 0;
    setState(() {
      unaffectedWeeklyProductionTotal = storedProductionTotal;
    });
  }

  Future<void> loadWeeklyDataFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('weeklySchedule');
      final totalProduction = prefs.getInt('weeklyProductionTotal');
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        setState(() {
          weeklySchedule = jsonList.map((json) => json.toString()).toList();
          weeklyProductionTotal = totalProduction ?? 0;
          production = weeklyProductionTotal.toString();
        });
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
        setState(() {
          weeklySchedule = jsonList.map((json) => json.toString()).toList();
          totalWeeklyProduction = totalProduction ?? 0;
          production = totalWeeklyProduction.toString();
        });
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
            // const Text(
            //   'المخزون',
            //   style: TextStyle(
            //       fontSize: 20,
            //       fontWeight: FontWeight.bold,
            //       fontFamily: "myfont"),
            // ),
            // const SizedBox(height: 10),
            // Text(unaffectedWeeklyProductionTotal.toString()),
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
                    title: Text(day),
                    subtitle: Text(productionNumber),
                    onTap: () {
                      openDayPage(day);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  for (int i = 0; i < weeklySchedule.length; i++) {
                    final day = weeklySchedule[i].split(': ')[0];
                    weeklySchedule[i] = '$day: 0'; // Set the day number to 0
                  }
                  calculateWeeklyProduction(); // Recalculate the weekly production total
                  production =
                      weeklyProductionTotal.toString(); // Update the UI
                });
                saveWeeklyScheduleToStorage();
                saveWeeklyProductionToDatabase();
                print(unaffectedWeeklyProductionTotal);
              },
              child: Text('تصفير الكل'),
            ),
          ],
        ),
      ),
    );
  }
}

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

  // TextEditingController productionController = TextEditingController();

  String production = '';
  String inventory = '';

  @override
  void dispose() {
    productionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadWeeklyDataFromStorage();
    startDataUpdateTimer();
    getUnaffectedProductionTotal();
  }

  void startDataUpdateTimer() {
    Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      updateDataAndCheckInternet();
    });
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

  int weeklyProductionTotal = 0;

  int totalProduction = 0;
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
    ).then((updatedProductionNumber) {
      if (updatedProductionNumber != null) {
        setState(() {
          for (int i = 0; i < weeklySchedule.length; i++) {
            if (weeklySchedule[i].startsWith(day)) {
              weeklySchedule[i] = '$day: $updatedProductionNumber';
              break;
            }
          }

          updateWeeklyProduction(); // Update the weekly production when a day's production is updated
          saveWeeklyScheduleToStorage(); // Save the updated weekly schedule to storage
          saveWeeklyProductionToDatabase(); // Save the updated weekly production to the database
        });
      }
    });
  }

  Future<void> saveWeeklyProductionToDatabase() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final collectionRef = firestore.collection('weekly_production');

      // Clear the existing documents in the collection
      await collectionRef.get().then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      int totalProduction =
          0; // Initialize the variable to calculate the affected total

      for (String scheduleEntry in weeklySchedule) {
        final day = scheduleEntry.split(': ')[0];
        final productionNumber =
            int.tryParse(scheduleEntry.split(': ')[1]) ?? 0;

        totalProduction += productionNumber; // Accumulate the production number

        await collectionRef.doc(day).set({
          'day': day,
          'productionNumber': productionNumber,
        });
      }

      setState(() {
        weeklyProductionTotal =
            totalProduction; // Update the affected weekly production total
      });

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
      await firestore.collection('unaffected_production').doc('total').set({
        'productionTotal': unaffectedWeeklyProductionTotal,
      });
    } catch (e) {
      print('Error saving weekly production to the database: $e');
    }
  }

  void getUnaffectedProductionTotal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedProductionTotal =
        prefs.getInt('unaffectedProductionTotal') ?? 0;
    setState(() {
      unaffectedWeeklyProductionTotal = storedProductionTotal;
    });
  }

  Future<void> loadWeeklyDataFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('weeklySchedule');
      final totalProduction = prefs.getInt('weeklyProductionTotal');
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        setState(() {
          weeklySchedule = jsonList.map((json) => json.toString()).toList();
          weeklyProductionTotal = totalProduction ?? 0;
          production = weeklyProductionTotal.toString();
        });
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
        setState(() {
          weeklySchedule = jsonList.map((json) => json.toString()).toList();
          totalWeeklyProduction = totalProduction ?? 0;
          production = totalWeeklyProduction.toString();
        });
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
            TextField(
              keyboardType: TextInputType.number,
              controller: productionController,
              decoration: const InputDecoration(
                labelText: 'ادخل كمية الأنتاج',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateDataAndCheckInternet();
                saveWeeklyProductionToDatabase();
                saveWeeklyScheduleToStorage();
                String updatedProduction = productionController.text;
                Navigator.pop(context, updatedProduction);
              },
              child: const Text('تعديل'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
