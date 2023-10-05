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
  int cement = 0;
  int sand = 0;
  int aggregate = 0;
  @override
  void initState() {
    super.initState();
    gettotal_in();
    gettotal_in2();
    _loadCounter();
    loadCostData();
    load_number_of_out();
    // startDataUpdateTimer();
  }

  bool _isLoading = false;
  int outtotal = 0;
  // ignore: non_constant_identifier_names
  int total_in = 0;
  // ignore: non_constant_identifier_names
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

  Future<void> _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (cement == 0) {
        // Load cement only if it hasn't been initialized
        cement = prefs.getInt('cement') ?? 0;
      }
      if (sand == 0) {
        // Load sand only if it hasn't been initialized
        sand = prefs.getInt('sand') ?? 0;
      }
      if (aggregate == 0) {
        // Load aggregate only if it hasn't been initialized
        aggregate = prefs.getInt('aggregate') ?? 0;
      }
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
  // ignore: non_constant_identifier_names
  Future<int> load_number_of_out() async {
    return numberOfOut;
  }

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

  Future<void> resetCostDataToZero() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('workers').doc('cost').set({
        'hamzaCost': 0,
        'muhammadCost': 0,
        'philanthropistCost': 0,
        'totalCost': 0,
      });
      setState(() {
        hamzaCost = 0;
        muhammadCost = 0;
        philanthropistCost = 0;
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

  Future<void> loadCostData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('workers').doc('cost').get();

      setState(() {
        hamzaCost = snapshot['hamzaCost'] ?? 0;
        muhammadCost = snapshot['muhammadCost'] ?? 0;
        philanthropistCost = snapshot['philanthropistCost'] ?? 0;
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
          ? const CircularProgressIndicator() // Display the loading indicator
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
                      ":الوارد الكلي ",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    const Text(
                      "رمل",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      sand.toString(),
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    const Text(
                      "حصو",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      aggregate.toString(),
                      style:
                          const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    const Text(
                      "اسمنت",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      cement.toString(),
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
                      child: Text('تصفير بيانات العمال '),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        resettotal_in2ToZero();
                      },
                      child: Text('تصفير  المخزون الكلي عدا البيع '),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
