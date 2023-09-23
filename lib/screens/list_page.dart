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
    gettotal_in();
    _loadCounter();
    load_number_of_out();
    // startDataUpdateTimer();
  }

  bool _isLoading = false;
  int outtotal = 0;
  int total_in = 0;
  void gettotal_in() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedProductionTotal = prefs.getInt('total_in') ?? 0;
    final int total_number_out = prefs.getInt('total_number_out') ?? 0;
    setState(() {
      total_in = storedProductionTotal;
      outtotal = total_number_out;
      _isLoading = false;
    });
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

  Future<void> getInventoryCount() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('unaffected_production')
          .doc('total')
          .get();
      inventoryCount = snapshot.data()?['productionTotal'] ?? 0;
    } catch (e) {
      print('Error retrieving inventory count: $e');
    }
  }

  int numberOfOut = 0;
  Future<int> load_number_of_out() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      int numberOfOut = prefs.getInt('total_number_out') ?? 0;
    } catch (e) {
      print(e);
    }
    return numberOfOut;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          "التقرير ",
          style: TextStyle(fontFamily: "myfont", fontSize: 25),
        ),
      ),
      body: _isLoading
          ? CircularProgressIndicator() // Display the loading indicator
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "المخزون الكلي مع البيع ",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(total_in.toString()),
                    Text(
                      ":الوارد الكلي ",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      "رمل",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      sand.toString(),
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      "حصو",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      aggregate.toString(),
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      "اسمنت",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      cement.toString(),
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      "كمية الصادر الكلية",
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                    Text(
                      outtotal.toString(),
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
