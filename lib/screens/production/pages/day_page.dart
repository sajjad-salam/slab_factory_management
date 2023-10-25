// ignore_for_file: avoid_print, non_constant_identifier_names, empty_catches, no_logic_in_create_state, use_build_context_synchronously, division_optimization
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slab_factory_management/screens/production/widget/buttons.dart';

class DayPage extends StatefulWidget {
  final String day;
  final String productionNumber;
  final int number_factory;

  const DayPage({
    Key? key,
    required this.day,
    required this.productionNumber,
    required int totalWeeklyProduction,
    required this.number_factory,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DayPageState createState() => _DayPageState(number_factory: number_factory);
}

class _DayPageState extends State<DayPage> {
  _DayPageState({required this.number_factory});
  final int number_factory;
  @override
  void initState() {
    super.initState();
    loadCostData();
    laoadcost_modl();
    load_number_of_workers();
    loadWeeklyDataFromStorage();
    getUnaffectedProductionTotal();
    gettotal_in();
    gettotal_in2();
  }

//  بيانات العمال
  String selectedWorker = 'worker1'; // Default worker
  double productionQuantity = 0;
  double worker1 = 0;
  double worker6 = 0;
  double worker7 = 0;
  double worker8 = 0;
  double worker5 = 0;
  int worker1d = 0;
  int worker5d = 0;
  int worker6d = 0;
  int worker7d = 0;
  int worker8d = 0;

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

      DocumentSnapshot snapshottotal = await firestore
          .collection('workers$number_factory')
          .doc('total')
          .get();
      DocumentSnapshot snapshot = await firestore
          .collection('workers$number_factory')
          .doc('cost')
          .get();

      if (snapshottotal.exists) {
        setState(
          () {
            totalCost = snapshottotal['totalCost'] ?? 0.0;
            worker1 = snapshot['worker1'] ?? 0.0;
            worker6 = snapshot['worker2'] ?? 0.0;
            worker7 = snapshot['worker3'] ?? 0.0;
            worker8 = snapshot['worker4'] ?? 0.0;
            worker5 = snapshot['worker5'] ?? 0.0;
            worker1d = snapshot['worker1d'] ?? 0.0;
            worker6d = snapshot['worker2d'] ?? 0.0;
            worker7d = snapshot['worker3d'] ?? 0.0;
            worker8d = snapshot['worker4d'] ?? 0.0;
            worker5d = snapshot['worker5d'] ?? 0.0;
          },
        );
        print(worker1);
        print(worker6);
        print(worker7);
        print(worker8);
        print(worker5);
        // Access the fields here
      } else {
        // Handle the case where the document does not exist
      }

      setState(
        () {
          _isLoading = false;
        },
      );
    } catch (e) {
      print('Error loading cost the values data: $e');
    }
  }

  Future<void> saveCostData() async {
    setState(() {
      _isLoading = true;
    });

    switch (selectedWorker) {
      case 'worker1':
        worker1 += (productionQuantity * cost_mold) / number_of_workers;
        worker1d += 1;
        totalCost +=
            ((productionQuantity * cost_mold) / number_of_workers).toInt();

        break;
      case 'worker2':
        worker6 += (productionQuantity * cost_mold) / number_of_workers;
        worker6d += 1;

        totalCost +=
            ((productionQuantity * cost_mold) / number_of_workers).toInt();
        break;
      case 'worker3':
        worker7 += (productionQuantity * cost_mold) / number_of_workers;
        worker7d += 1;
        totalCost +=
            ((productionQuantity * cost_mold) / number_of_workers).toInt();
        break;
      case 'worker4':
        worker8 += (productionQuantity * cost_mold) / number_of_workers;
        worker8d += 1;
        totalCost +=
            ((productionQuantity * cost_mold) / number_of_workers).toInt();
        break;
      case 'worker5':
        worker5 += (productionQuantity * cost_mold) / number_of_workers;
        worker5d += 1;
        totalCost +=
            ((productionQuantity * cost_mold) / number_of_workers).toInt();
        break;
    }

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('workers$number_factory').doc('cost').set({
        'worker1': worker1,
        'worker5': worker5,
        'worker2': worker6,
        'worker3': worker7,
        'worker4': worker8,
        'worker4d': worker8d,
        'worker1d': worker1d,
        'worker2d': worker6d,
        'worker3d': worker7d,
        'worker5d': worker5d,
      });
      await firestore.collection('workers$number_factory').doc('total').set({
        'totalCost': totalCost,
      });
    } catch (e) {
      print('Error saving cost data: $e');
    }
    setState(() {
      _isLoading = false;
    });
  }

  TextEditingController productionController = TextEditingController();
  int totalWeeklyProduction = 0;
  List<String> weeklySchedule = [
    'الأحد: 0',
    'الأثنين: 0',
    'الثلاثاء: 0',
    'الأربعاء: 0',
    'الخميس: 0',
    'الجمعة: 0',
    'السبت: 0',
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

  Future<void> saveWeeklyProductionToDatabase() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final collectionRef =
          firestore.collection('weekly_production$number_factory');
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
      await prefs.setInt('unaffectedProductionTotal$number_factory',
          unaffectedWeeklyProductionTotal);
      await firestore
          .collection('unaffected_production$number_factory')
          .doc('total')
          .set(
        {
          'productionTotal': unaffectedWeeklyProductionTotal,
        },
      );
      setState(() {
        _isLoading = false;
      });
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
      print('Error loading cost totl data: $e');
    }
  }

  void gettotal_in2() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('total_in2').doc('total2').get();

      setState(
        () {
          total_in2 = snapshot['productionTotal'] ?? 0;
        },
      );
      setState(
        () {
          _isLoading = false;
        },
      );
      print(total_in2);
    } catch (e) {
      print('Error loading cost total2 data: $e');
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
  int cost_mold = 0; //سعر القالب
  // هاي دالة جلب سعر القالب من قاعدة البيانات
  Future<void> laoadcost_modl() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('cost_modl').doc('mold').get();

      setState(
        () {
          cost_mold = int.parse(snapshot['mold_cost'] ?? 0);
          _isLoading = false;
        },
      );
    } catch (e) {
      print('Error loading cost mold data: $e');
    }
  }

  // تصفير بيانات العمال
  Future<void> deleteCostDocument() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('workers$number_factory').doc('cost').delete();
      print('Document "cost" deleted successfully');
    } catch (e) {
      print('Error deleting document "cost": $e');
    }
  }

// لود عدد العمال من قاعدة البيانات
  int number_of_workers = 0;
  Future<void> load_number_of_workers() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot = await firestore
          .collection('number_of_workers')
          .doc('number_of_workers')
          .get();

      setState(
        () {
          number_of_workers = int.tryParse(snapshot['number']) ?? 0;
          _isLoading = false;
        },
      );
    } catch (e) {
      print('Error loading cost number of workers data: $e');
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
            CupertinoTextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(
                  () {
                    productionQuantity = double.tryParse(value) ?? 0;
                  },
                );
              },
              decoration: decuration(),
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
                  value: 'worker1',
                  child: Text('العامل الاول'),
                ),
                DropdownMenuItem<String>(
                  value: 'worker2',
                  child: Text('العامل الثاني'),
                ),
                DropdownMenuItem<String>(
                  value: 'worker3',
                  child: Text('العامل الثالث'),
                ),
                DropdownMenuItem<String>(
                  value: 'worker4',
                  child: Text('العامل الرابع'),
                ),
                DropdownMenuItem<String>(
                  value: 'worker5',
                  child: Text('العامل الخامس'),
                ),
              ],
            ),
            Text(
              'كمية الأنتاخ: $productionQuantity',
              style: const TextStyle(fontFamily: "myfont", fontSize: 20),
            ),
            Text(
              'حساب العامل الاول: $worker1',
              style: const TextStyle(fontFamily: "myfont", fontSize: 20),
            ),
            Text(
              'ايام العامل الاول: $worker1d',
              style: const TextStyle(fontFamily: "myfont", fontSize: 20),
            ),
            Text(
              'حساب العامل الثاني: $worker6',
              style: const TextStyle(fontFamily: "myfont", fontSize: 20),
            ),
            Text(
              'ايام العامل الثاني: $worker6d',
              style: const TextStyle(fontFamily: "myfont", fontSize: 20),
            ),
            Text(
              'حساب العامل الثالث: $worker7',
              style: const TextStyle(fontFamily: "myfont", fontSize: 20),
            ),
            Text(
              'ابام العامل الثالث: $worker7d',
              style: const TextStyle(fontFamily: "myfont", fontSize: 20),
            ),
            Text(
              'حساب العامل الرابع: $worker8',
              style: const TextStyle(fontFamily: "myfont", fontSize: 20),
            ),
            Text(
              'ابام العامل الرابع: $worker8d',
              style: const TextStyle(fontFamily: "myfont", fontSize: 20),
            ),
            Text(
              'حساب العامل الخامس: $worker5',
              style: const TextStyle(fontFamily: "myfont", fontSize: 20),
            ),
            Text(
              'ابام العامل الخامس: $worker5d',
              style: const TextStyle(fontFamily: "myfont", fontSize: 20),
            ),
            Text(
              'حساب العمال الكلي: $totalCost',
              style: const TextStyle(fontFamily: "myfont", fontSize: 20),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator() // Display the loading indicator
                : ElevatedButton(
                    onPressed: () async {
                      setState(
                        () {
                          _isLoading = true;
                        },
                      );
                      //  هاي بيانا تلاعمال

                      saveCostData(); // هذه الدالة لحفض بيانات العمال في قاعدة البيانات

                      // updateDataAndCheckInternet();

                      print(total_in);
                      print(total_in2);
                      Get.snackbar("رسالة", "تم حفض البيانات بنجاح",
                          snackPosition: SnackPosition.BOTTOM);
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
                saveWeeklyProductionToDatabase();
                saveWeeklyScheduleToStorage();
                final firestore = FirebaseFirestore.instance;

                SharedPreferences prefs = await SharedPreferences.getInstance();

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
                Navigator.pop(context, updatedProduction);
              },
              child: const Text(
                'خروخ',
                style: TextStyle(fontFamily: "myfont", fontSize: 18),
              ),
            ),
            buttonresetworkerdata(deleteCostDocument: deleteCostDocument),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  BoxDecoration decuration() {
    return BoxDecoration(
      // color: CupertinoColors.extraLightBackgroundGray,
      borderRadius: BorderRadius.circular(10),
    );
  }
}
