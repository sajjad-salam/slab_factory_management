import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: camel_case_types
class out_screen extends StatefulWidget {
  const out_screen({super.key});

  @override
  State<out_screen> createState() => _out_screenState();
}

// ignore: camel_case_types
class _out_screenState extends State<out_screen> {
  List<Customer> customers = [
    // Customer(15, 27, 48, 18, name: "سجاد سلام", customerNumber: 200),
    // Customer(15, 27, 48, 18, name: " محمد بدر", customerNumber: 200)
  ];

  List<Customer> filteredCustomers = [];

  TextEditingController searchController = TextEditingController();
  TextEditingController addCustomerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCustomers = customers;
    gettotal_in();
    loadCustomersFromDatabase();
    loadCustomersFromStorage();
    // updateCustomer
  }

  int total_in = 0;
  void gettotal_in() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedProductionTotal = prefs.getInt('total_in') ?? 0;
    setState(() {
      total_in = storedProductionTotal;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    addCustomerController.dispose();
    super.dispose();
  }

  int totaloutputing = 0;

  void filterCustomers(String searchQuery) {
    setState(() {
      filteredCustomers = customers.where((customer) {
        return customer.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    });
  }

  Future<void> updateCustomer(Customer updatedCustomer) async {
    for (Customer customer in customers) {
      // int productionNumber = int.tryParse(customer.customerNumber) ?? 0;
      totaloutputing += customer.customerNumber;
    }

    final customerIndex = customers
        .indexWhere((customer) => customer.name == updatedCustomer.name);
    if (customerIndex != -1) {
      setState(() {
        customers[customerIndex] = updatedCustomer;
      });
      await saveCustomersToStorage();
      await saveCustomersToDatabase();
    }
  }

  Future<void> saveCustomersToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = customers.map((customer) => customer.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString('customers', jsonString);
    } catch (e) {
      print('Error saving customers to storage: $e');
    }
  }

  Future<void> loadCustomersFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    for (Customer customer in customers) {
      // int productionNumber = int.tryParse(customer.customerNumber) ?? 0;
      totaloutputing += customer.customerNumber;
      await prefs.setInt('total_number_out', totaloutputing);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('customers');
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        setState(() {
          customers = jsonList
              .map((json) => Customer(
                    json['flen'],
                    json['mastek'],
                    json['flankot'],
                    json['zefet'],
                    name: json['name'],
                    customerNumber: json['customerNumber'],
                  ))
              .toList();
          filteredCustomers = customers;
        });
      }
    } catch (e) {
      print('Error loading customers from storage: $e');
    }
  }

  void addCustomer(String customerName) {
    final newCustomer = Customer(
      0,
      0,
      0,
      0,
      name: customerName,
      customerNumber: 0,
    );
    setState(() {
      customers.add(newCustomer);
      filteredCustomers = customers;
    });
    addCustomerController.clear();

    saveCustomersToStorage();
    saveCustomersToDatabase();
  }

  Future<void> saveCustomersToDatabase() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference customersCollection =
          firestore.collection('customers');

      await customersCollection.doc('customerData').set({
        'customers': customers.map((customer) => customer.toJson()).toList(),
      });
    } catch (e) {
      print('Error saving customers to database: $e');
    }
  }

  Future<void> loadCustomersFromDatabase() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference customersCollection =
          firestore.collection('customers');

      DocumentSnapshot docSnapshot =
          await customersCollection.doc('customerData').get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final jsonList = data['customers'] as List<dynamic>;
        setState(() {
          customers = jsonList
              .map((json) => Customer(
                    json['flen'],
                    json['mastek'],
                    json['flankot'],
                    json['zefet'],
                    name: json['name'],
                    customerNumber: json['customerNumber'],
                  ))
              .toList();
          filteredCustomers = customers;
        });
      }
    } catch (e) {
      print('Error loading customers from database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          "صفحة الصادرات",
          style: TextStyle(fontFamily: "myfont", fontSize: 25),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterCustomers(value);
              },
              decoration: const InputDecoration(
                labelText: 'بحث',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCustomers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    filteredCustomers[index].name,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontFamily: "myfont",
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Text(
                    '${filteredCustomers[index].customerNumber}',
                    style: const TextStyle(
                      fontFamily: "myfont",
                    ),
                    textAlign: TextAlign.end,
                  ),
                  onTap: () async {
                    final updatedCustomer = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerDetailsPage(
                            customer: filteredCustomers[index]),
                      ),
                    );

                    if (updatedCustomer != null) {
                      await updateCustomer(updatedCustomer);
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: addCustomerController,
                    decoration: const InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'اضافة عميل ',
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 1.4,
                  child: IconButton(
                    alignment: Alignment.bottomCenter,
                    icon: const Icon(Icons.add_circle),
                    onPressed: () {
                      print(totaloutputing);
                      String customerName = addCustomerController.text;
                      if (customerName.isNotEmpty) {
                        addCustomer(customerName);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Customer {
  final String name;
  final int customerNumber;
  final int flen;
  final int mastek;
  final int flankot;
  final int zefet;

  Customer(
    this.flen,
    this.mastek,
    this.flankot,
    this.zefet, {
    required this.name,
    required this.customerNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'customerNumber': customerNumber,
      'flen': flen,
      'mastek': mastek,
      'flankot': flankot,
      'zefet': zefet,
    };
  }
}

class CustomerDetailsPage extends StatefulWidget {
  final Customer customer;

  // ignore: prefer_const_constructors_in_immutables
  CustomerDetailsPage({super.key, required this.customer});

  @override
  // ignore: library_private_types_in_public_api
  _CustomerDetailsPageState createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  late TextEditingController shtagernumber;
  late TextEditingController zefet;
  late TextEditingController mastek;
  late TextEditingController flankot;
  late TextEditingController flen;
  int total_in = 0;
  void gettotal_in() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedProductionTotal = prefs.getInt('total_in') ?? 0;
    setState(() {
      total_in = storedProductionTotal;
    });
  }

  @override
  void initState() {
    super.initState();
    gettotal_in();
    shtagernumber =
        TextEditingController(text: widget.customer.customerNumber.toString());
    flen = TextEditingController(text: widget.customer.flen.toString());
    zefet = TextEditingController(text: widget.customer.zefet.toString());
    flankot = TextEditingController(text: widget.customer.flankot.toString());
    mastek = TextEditingController(text: widget.customer.mastek.toString());
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  void dispose() {
    shtagernumber.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(widget.customer.name.toString()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: shtagernumber,
              decoration: const InputDecoration(
                labelText: 'عدد الشتايكر',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: mastek,
              decoration: const InputDecoration(
                labelText: 'عدد الماستك',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: zefet,
              decoration: const InputDecoration(
                labelText: 'عدد الزفت',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: flen,
              decoration: const InputDecoration(
                labelText: 'عدد الفلين',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: flankot,
              decoration: const InputDecoration(
                labelText: 'عدد الفلانكوت',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // Display the loading indicator
                : ElevatedButton(
                    onPressed: () async {
                      bool hasInternet = await checkInternetConnectivity();
                      int intflen = int.parse(flen.text);
                      int intzefet = int.parse(zefet.text);
                      int intflankot = int.parse(flankot.text);
                      int intmastek = int.parse(mastek.text);
                      total_in -= int.tryParse(shtagernumber.text) ??
                          widget.customer.customerNumber;
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      if (hasInternet) {
                        setState(() {
                          _isLoading = true;
                        });

                        final firestore = FirebaseFirestore.instance;

                        // Save the unaffected weekly production total in a new collection in the database
                        await firestore
                            .collection('total_in')
                            .doc('total')
                            .set({
                          'productionTotal': total_in,
                        });
                        try {
                          setState(() {
                            _isLoading = false;
                          });
                        } catch (e) {}
                      }
                      await prefs.setInt('total_in', total_in);

                      final updatedCustomer = Customer(
                          intflen, intmastek, intflankot, intzefet,
                          name: widget.customer.name,
                          customerNumber: int.tryParse(shtagernumber.text) ??
                              widget.customer.customerNumber);

                      Navigator.pop(context, updatedCustomer);
                    },
                    child: const Text(
                      textAlign: TextAlign.end,
                      'تحديث',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "myfont",
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
