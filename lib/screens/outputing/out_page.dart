import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'customer_details_page.dart';

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

  // ignore: non_constant_identifier_names
  int total_in = 0;
  // ignore: non_constant_identifier_names
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
    final prefs = await SharedPreferences.getInstance();
    final jsonList = customers.map((customer) => customer.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString('customers', jsonString);
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
      // ignore: empty_catches
    } catch (e) {}
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
      // ignore: avoid_print
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
      // ignore: avoid_print
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
                      // ignore: avoid_print
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
