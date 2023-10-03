import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Worker {
  final String name;
  double laborCost;

  Worker({required this.name, required this.laborCost});
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'laborCost': laborCost,
    };
  }

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      name: json['name'],
      laborCost: json['laborCost'].toDouble(),
    );
  }
}

class ProductionModel {
  String day;
  int productionQuantity;
  List<Worker> selectedWorkers; // Change to List<Worker>

  ProductionModel({
    required this.day,
    this.productionQuantity = 0,
    this.selectedWorkers = const [],
  });
}

class work extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Production and Account App',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ProductionPag(),
        '/account': (context) => AccountPage(),
      },
    );
  }
}

class ProductionPag extends StatefulWidget {
  @override
  _ProductionPageState createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPag> {
  String selectedDay = 'Monday'; // Default day
  int productionQuantity = 0;
  TextEditingController productionQuantit = TextEditingController();
  Worker? selectedWorker;
  List<Worker> workers = [
    Worker(name: 'حمزة فاضل', laborCost: 10.0),
    Worker(name: 'رسول عباس', laborCost: 12.0),
    Worker(name: 'محمد فهد', laborCost: 15.0),
    // Add more workers as needed
  ];
  @override
  void initState() {
    super.initState();

    // loadWorkersFromLocal(); // Load workers from local storage when the page initializes
  }

  // Load worker data from local storage
  // void loadWorkersFromLocal() async {
  //   final loadedWorkers = await LocalStorageManager.loadWorkers();
  //   setState(() {
  //     workers = loadedWorkers;
  //   });
  // }
  Future<void> saveWorkersLocally(List<Worker> workers) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedWorkers = workers.map((worker) => worker.toJson()).toList();
    await prefs.setStringList('workers', encodedWorkers.cast<String>());
  }

// Function to load workers from local storage
  Future<List<Worker>> loadWorkersLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedWorkers = prefs.getStringList('workers') ?? [];
    return encodedWorkers
        .map((encodedWorker) =>
            Worker.fromJson(encodedWorker as Map<String, dynamic>))
        .toList();
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

// Function to update data and check internet
  Future<void> updateDataAndCheckInternet(Worker worker) async {
    bool hasInternet = await checkInternetConnectivity();
    if (hasInternet) {
      await updateDataInDatabase(workers);
    } else {
      print('No internet connection available. Data update postponed.');
    }
  }

// Function to update data in the database
  Future<void> updateDataInDatabase(List<Worker> workers) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      CollectionReference workcollection = firestore.collection('workers');

      await workcollection.doc('workersData').set({
        'workers': workers.map((worker) => worker.toJson()).toList(),
      });

      print('Data stored in the database successfully!');
    } catch (e) {
      print('Error storing data in the database: $e');
    }
  }

  void updateWorkerLaborCost(
      List<Worker> workers, int workerIndex, double newLaborCost) {
    if (workerIndex >= 0 && workerIndex < workers.length) {
      workers[workerIndex].laborCost = newLaborCost;

      // Update the worker's laborCost in the database
      updateDataInDatabase(workers);
    }
  }

// Function to periodically update data for all workers
  void startDataUpdateTimer(List<Worker> workers) {
    Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      for (var worker in workers) {
        updateDataAndCheckInternet(worker);
      }
    });
  }

  ProductionModel productionData = ProductionModel(day: 'Monday');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Production Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedDay,
              onChanged: (value) {
                setState(() {
                  selectedDay = value!;
                  productionData = ProductionModel(
                    day: selectedDay,
                    productionQuantity: productionQuantity,
                    selectedWorkers: productionData.selectedWorkers,
                  );
                });
              },
              items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                  .map((day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
            ),
            TextField(
              controller: productionQuantit,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  productionQuantity = int.tryParse(value) ?? 0;
                  productionData.productionQuantity = productionQuantity;
                });
              },
              decoration: InputDecoration(labelText: 'Production Quantity'),
            ),
            DropdownButton<Worker>(
              value: selectedWorker,
              onChanged: (worker) {
                setState(() {
                  selectedWorker = worker;
                  productionData.selectedWorkers =
                      List.from(productionData.selectedWorkers)..add(worker!);
                  selectedWorker!.laborCost =
                      double.tryParse(productionQuantit.text) ?? 0.0;
                  productionQuantit.text = "";
                });
              },
              items: workers.map((worker) {
                return DropdownMenuItem<Worker>(
                  value: worker,
                  child: Text(worker.name),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                print(selectedWorker?.laborCost ?? 0);
                print(selectedDay);
                print(selectedWorker?.name ?? "null");
              },
              child: Text('print'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  if (index < productionData.selectedWorkers.length) {
                    return ListTile(
                      title: Text(
                          productionData.selectedWorkers[index].name ?? ""),
                      subtitle: Text(
                        'Labor Cost: \$${productionData.selectedWorkers[index].laborCost.toStringAsFixed(2)}',
                      ),
                    );
                  } else {
                    return null; // or an empty widget if you prefer
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  updateDataAndCheckInternet(
                      productionData.selectedWorkers.first);
                } catch (e) {}
                // updateWorkerLaborCost(workers, workerIndex, newLaborCost)
                // Navigator.pushNamed(context, '/account', arguments: workers);

                // Navigator.pushNamed(context, '/account',
                //     arguments: productionData);
              },
              child: Text('Go to Account Page'),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ProductionModel productionData =
        ModalRoute.of(context)!.settings.arguments as ProductionModel;

    double totalLaborCost = productionData.selectedWorkers
        .fold(0.0, (prev, worker) => prev + worker.laborCost);
    double totalAccount = productionData.productionQuantity * totalLaborCost;

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total Account: \$${totalAccount.toStringAsFixed(2)}'),
            SizedBox(height: 20),
            Text('Selected Workers:'),
            SizedBox(height: 10),
            Column(
              children: productionData.selectedWorkers.map((worker) {
                return ListTile(
                  title: Text(worker.name),
                  subtitle: Text(
                      'Labor Cost: \$${worker.laborCost.toStringAsFixed(2)}'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
