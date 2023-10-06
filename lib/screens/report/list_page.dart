// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Listpage extends StatefulWidget {
  const Listpage({super.key});

  @override
  State<Listpage> createState() => _ListpageState();
}

class _ListpageState extends State<Listpage> {
  int inventoryCount = 0;

  @override
  void initState() {
    super.initState();
    loadSecondaryExpensesFromFirestore();
    gettotal_in();
    loadCostaggregateData();
    loadCostcementdData();
    loadCostsandData();
    gettotal_in2();
    loadCostData();
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

  int outtotal = 0;
  int total_in = 0;
  void gettotal_in() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedProductionTotal = prefs.getInt('total_in') ?? 0;
    final int totalNumberOut = prefs.getInt('total_number_out') ?? 0;
    setState(() {
      total_in = storedProductionTotal;
      outtotal = totalNumberOut;
      _isLoading = false;
    });
  }

  Future<void> getInventoryCount() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot =
        await firestore.collection('unaffected_production').doc('total').get();
    inventoryCount = snapshot.data()?['productionTotal'] ?? 0;
  }

  int productionQuantity = 0;
  int hamzaCost = 0;
  int muhammadCost = 0;
  int philanthropistCost = 0;
  int totalCost = 0;
  int numberOfOut = 0;

  int total_in2 = 0;

  void gettotal_in2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedProductionTotal = prefs.getInt('total_in2') ?? 0;
    setState(
      () {
        total_in2 = storedProductionTotal;
      },
    );
  }

  double secondaryExpenses = 0;

  Future<double> loadSecondaryExpensesFromFirestore() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference expensesCollection = firestore.collection('expenses');
      DocumentSnapshot doc = await expensesCollection.doc('secondary').get();

      if (doc.exists && doc.data() != null) {
        double secondaryExpensess = doc['secondaryExpenses'].toDouble();
        setState(() {
          secondaryExpenses = secondaryExpensess;
        });
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading secondary expenses: $e');
    }
    // Return a default value of 0.0 in case of an error or missing data
    return 0.0;
  }

  Future<void> resetCostDataToZero() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('workers').doc('total').set({
        'totalCost': 0,
      });
      setState(() {
        totalCost = 0;
        _isLoading = false;
      });
    } catch (e) {
      print('Error resetting cost data: $e');
    }
  }

  Future<void> resettotal_in2ToZero() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('total_in2').doc('total2').set({
        'productionTotal': 0,
      });
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error resetting cost data: $e');
    }
  }

  Future<void> resetsecondaryExpenses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('expenses').doc('secondary').set({
        'secondaryExpenses': 0,
      });
      setState(() {
        secondaryExpenses = 0;
        _isLoading = false;
      });
    } catch (e) {
      print('Error resetting cost data: $e');
    }
  }

  Future<void> loadCostData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('workers').doc('total').get();

      setState(() {
        totalCost = snapshot['totalCost'] ?? 0;
      });
    } catch (e) {
      print('Error loading cost data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          "التقرير ",
          style: TextStyle(fontFamily: "myfont", fontSize: 25),
        ),
      ),
      body: _isLoading
          ? const CircularProgressIndicator()
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "المخزون الكلي مع البيع ",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(total_in.toString()),
                    const Text(
                      "المخزون الكلي عدا البيع ",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(total_in2.toString()),
                    const Text(
                      "مجموع المصاريف الثانوية",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(secondaryExpenses.toString()),
                    const Text(
                      ":الوارد الكلي ",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    const Text(
                      "رمل",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      totalsandtPrice.toString(),
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    const Text(
                      "حصو",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      totalaggregatetPrice.toString(),
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    const Text(
                      "اسمنت",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      totalCementPrice.toString(),
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    const Text(
                      "كمية الصادر الكلية",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      outtotal.toString(),
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        resetCostDataToZero();
                      },
                      child: const Text('تصفير حساب العمال '),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        resettotal_in2ToZero();
                      },
                      child: const Text('تصفير  المخزون الكلي عدا البيع '),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        resetsecondaryExpenses();
                      },
                      child: const Text('تصفيرالمصاريف الثانوية'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
