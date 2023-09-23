import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
          style: TextStyle(fontFamily: "myfont", fontSize: 25),
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
          ),
          TextField(
            keyboardType: TextInputType.number,
            controller: numberofworkers,
            onChanged: (value) {
              saveValuesToStorage();
            },
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
              labelText: 'عدد الأيام',
            ),
            style: const TextStyle(fontFamily: "myfont", fontSize: 25),
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

class WorkerDetailsPage extends StatefulWidget {
  final Worker worker;

  const WorkerDetailsPage(
      {Key? key,
      required this.worker,
      required this.temp_price,
      required this.numberofworkers})
      : super(key: key);
  final String temp_price;
  final String numberofworkers;

  @override
  _WorkerDetailsPageState createState() =>
      _WorkerDetailsPageState(numberofworkers, temp_price: temp_price);
}

class _WorkerDetailsPageState extends State<WorkerDetailsPage> {
  _WorkerDetailsPageState(this.numberworkers, {required this.temp_price});
  TextEditingController daysController = TextEditingController();
  double totalCost = 0.0;
  final String temp_price;
  final String numberworkers;
  int inventoryCount = 0;

  @override
  void dispose() {
    daysController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getInventoryCount();
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
      appBar: CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          widget.worker.name.toString(),
          style: const TextStyle(fontFamily: "myfont", fontSize: 25),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 10),
            Text(
              'الحساب: ${widget.worker.orderAmount}',
              style: const TextStyle(fontFamily: "myfont", fontSize: 25),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'عدد الأيام',
              ),
              style: const TextStyle(fontFamily: "myfont", fontSize: 25),
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
      ),
    );
  }
}
