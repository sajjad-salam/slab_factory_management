// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    gettotal_outCost();
    loadTotal_output();
    loadCostaggregateData();
    loadCostcementdData();
    loadCostsandData();
    loadCostData();
    loadTotal_in_with_output();
    gettotal_in2();
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
          // outtotal = total_in2 - total_in;
          _isLoading = false;
        },
      );
    } catch (e) {
      print('Error loading cost data: $e');
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

  int totalOutCost = 0;

  void gettotal_outCost() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('total_out_cost').doc('total').get();

      setState(
        () {
          totalOutCost = snapshot['Total'] ?? 0;
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
      print('Error loading cost data: $e');
    }
  }

  int outtotal = 0;
  int total_in = 0;
  Future<void> loadTotal_output() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('total_out').doc('cost').get();

      setState(
        () {
          outtotal = snapshot['total'] ?? 0;
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

  Future<void> loadTotal_in_with_output() async {
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
          outtotal = total_in2 - total_in;

          _isLoading = false;
        },
      );
    } catch (e) {
      print('Error loading cost data: $e');
    }
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
    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('total_in2').doc('total2').get();
      setState(() {
        total_in2 = snapshot['productionTotal'];
      });
      setState(() {
        outtotal = total_in2 - total_in;

        _isLoading = false;
      });
    } catch (e) {
      print('Error loading secondary expenses: $e');
    }
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

  Future<void> resettotalOut_cost() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('total_out_cost').doc('total').set({
        'Total': 0,
      });
      setState(() {
        totalOutCost = 0;
        _isLoading = false;
      });
    } catch (e) {
      print('Error resetting cost data: $e');
    }
  }

// صافي الارباح
  int ProfitsTotal = 0;

  Future<void> loadCostData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('workers1').doc('total').get();
      DocumentSnapshot snapshot1 =
          await firestore.collection('workers2').doc('total').get();

      setState(() {
        totalCost = snapshot['totalCost'] + snapshot1['totalCost'];
        ProfitsTotal = totalOutCost - (totalCost + secondaryExpenses.toInt());
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
                    Text(
                      "المخزون الكلي مع البيع ${total_in.toString()} ",
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      "المخزون الكلي عدا البيع ${total_in2.toString()} ",
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      "مجموع المصاريف الثانوية ${secondaryExpenses.toString()} ",
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      "      رمل   ${totalsandtPrice.toString()} ",
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      "     حصو   ${totalaggregatetPrice.toString()} ",
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      "     اسمنت  ${totalCementPrice.toString()} ",
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      "كمية الصادر الكلية  ${outtotal.toString()} ",
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      "مبلغ الصادر الكلي ${totalOutCost.toString()}",
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      "مبلغ العمال الكلي  ${totalCost.toString()}",
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      "  صافي الارباح  ${ProfitsTotal.toString()}",
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        resetCostDataToZero();
                        Get.snackbar("الرسالة", "تم تصفير حساب العمال",
                            snackPosition: SnackPosition.BOTTOM);
                      },
                      child: const Text('تصفير حساب العمال '),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        resettotal_in2ToZero();
                        Get.snackbar(
                            "الرسالة", "تم تصفير المخزون الكلي عدا البيع",
                            snackPosition: SnackPosition.BOTTOM);
                      },
                      child: const Text('تصفير  المخزون الكلي عدا البيع '),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        resetsecondaryExpenses();
                        Get.snackbar("الرسالة", "تم تصفير  المصاريف الثانوية",
                            snackPosition: SnackPosition.BOTTOM);
                      },
                      child: const Text('تصفيرالمصاريف الثانوية'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        resettotalOut_cost();
                        Get.snackbar("الرسالة", "تم تصفير  مبلغ الصادر الكلي",
                            snackPosition: SnackPosition.BOTTOM);
                      },
                      child: const Text(' تصفير مبلغ الصادر الكلي'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
