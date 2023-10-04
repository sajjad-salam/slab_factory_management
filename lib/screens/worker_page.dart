// ignore_for_file: non_constant_identifier_names, avoid_print, library_private_types_in_public_api, no_logic_in_create_state

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'worker_details_page.dart';

class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  _WorkersPageState createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  double templatePrice = 0.0;

  void getTemplatePrice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double storedTemplatePrice = prefs.getDouble('templatePrice') ?? 0.0;
    setState(() {
      templatePrice = storedTemplatePrice;
    });
  }

  List<Worker> filteredWorkers = [];

  TextEditingController searchController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController numberofworkers = TextEditingController();

  @override
  void initState() {
    super.initState();
    retrieveValuesFromStorage();
    getInventoryCount();
  }

  void saveValuesToStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('price', priceController.text);
    prefs.setString('numberOfWorkers', numberofworkers.text);
  }

// Retrieve the values from device storage
  void retrieveValuesFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String price = prefs.getString('price') ?? '';
    String numberOfWorkers = prefs.getString('numberOfWorkers') ?? '';

    priceController.text = price;
    numberofworkers.text = numberOfWorkers;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  TextEditingController daysController = TextEditingController();
  double totalCost = 0.0;
  late final String temp_price;
  late final String numberworkers;
  int inventoryCount = 0;

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

  void calculateTotalCost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String price = prefs.getString('price') ?? '';
    String numberOfWorkers = prefs.getString('numberOfWorkers') ?? '';
    int numberOfDays = int.parse(daysController.text);

    try {
      double templatePrice =
          double.parse(price); // Add your template price retrieval logic here
      int numberofworkers = int.parse(
          numberOfWorkers); // Add your template price retrieval logic here

      setState(() {
        totalCost =
            (templatePrice * inventoryCount * numberOfDays) / numberofworkers;
      });
      print(totalCost);
    } catch (e) {
      Get.snackbar("خطأ", "$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          "صفحة العمال ",
          style: TextStyle(fontFamily: "myfont", fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          TextField(
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            controller: priceController,
            onChanged: (value) {},
            decoration: const InputDecoration(
              labelText: 'ادخل سعر القالب',
              prefixIcon: Icon(Icons.price_check),
            ),
            style: const TextStyle(fontFamily: "myfont", fontSize: 20),
          ),
          TextField(
            keyboardType: TextInputType.number,
            controller: numberofworkers,
            onChanged: (value) {
              saveValuesToStorage();
            },
            style: const TextStyle(fontFamily: "myfont", fontSize: 20),
            decoration: const InputDecoration(
              labelText: 'ادخل عدد العمال',
              prefixIcon: Icon(Icons.price_check),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: daysController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_month),
              labelText: 'عدد الأيام',
            ),
            style: const TextStyle(fontFamily: "myfont", fontSize: 20),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              getInventoryCount();
              calculateTotalCost();
            },
            child: const Text(
              'حساب',
              style: TextStyle(fontFamily: "myfont", fontSize: 20),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'الحساب الأجمالي: $totalCost',
            style: const TextStyle(fontFamily: "myfont", fontSize: 25),
          ),
        ],
      ),
    );
  }
}

class Worker {
  final String name;
  final int orderAmount;
  final int days;

  Worker(
    this.days, {
    required this.name,
    required this.orderAmount,
  });
}
