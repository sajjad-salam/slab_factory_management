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
    _loadCounter();
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
      final snapshot = await firestore
          .collection('unaffected_production')
          .doc('total')
          .get();
      inventoryCount = snapshot.data()?['productionTotal'] ?? 0;
    
  }

  int numberOfOut = 0;
  // ignore: non_constant_identifier_names
  Future<int> load_number_of_out() async {
   
    return numberOfOut;
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
                      ":الوارد الكلي ",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    const Text(
                      "رمل",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      sand.toString(),
                      style: const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    const Text(
                      "حصو",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      aggregate.toString(),
                      style: const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    const Text(
                      "اسمنت",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      cement.toString(),
                      style: const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    const Text(
                      "كمية الصادر الكلية",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      outtotal.toString(),
                      style: const TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
