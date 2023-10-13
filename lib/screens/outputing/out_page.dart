// ignore_for_file: avoid_print

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'customer_details_page.dart';

// ignore: camel_case_types
class out_screen extends StatefulWidget {
  const out_screen({super.key});

  @override
  State<out_screen> createState() => _out_screenState();
}

// ignore: camel_case_types
class _out_screenState extends State<out_screen> {
  List<Customer> customers = [];

  List<Customer> filteredCustomers = [];

  TextEditingController searchController = TextEditingController();
  TextEditingController addCustomerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCustomers = customers;
    gettotal_in();
    loadCustomersFromDatabase();
    // updateCustomer(updatedCustomer);
  }

  bool _isLoading = false;
  // ignore: non_constant_identifier_names
  int total_in = 0;
  // ignore: non_constant_identifier_names
  void gettotal_in() async {
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
          _isLoading = false;
        },
      );
      print(total_in);
    } catch (e) {
      print('Error loading cost data: $e');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    addCustomerController.dispose();
    super.dispose();
  }

  void filterCustomers(String searchQuery) {
    setState(() {
      filteredCustomers = customers.where((customer) {
        return customer.id.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    });
  }

  Future<void> updateCustomer(Customer updatedCustomer) async {
    final customerIndex = customers
        .indexWhere((customer) => customer.name == updatedCustomer.name);
    if (customerIndex != -1) {
      setState(() {
        customers[customerIndex] = updatedCustomer;
      });
      await saveCustomersToDatabase();
    }
  }

  void addCustomer(String customerId, String customerName) {
    final newCustomer = Customer(
      customerId,
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

    // Save the updated list of customers
    saveCustomersToDatabase(); // If you want to store this data online
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
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference customersCollection =
          firestore.collection('customers');

      DocumentSnapshot docSnapshot =
          await customersCollection.doc('customerData').get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final jsonList = data['customers'] as List<dynamic>;
        setState(
          () {
            customers = jsonList
                .map((json) => Customer(
                      json['id'],
                      json['flen'],
                      json['mastek'],
                      json['flankot'],
                      json['zefet'],
                      name: json['name'],
                      customerNumber: json['customerNumber'],
                    ))
                .toList();
            filteredCustomers = customers;
          },
        );
      }
      setState(
        () {
          _isLoading = false;
        },
      );
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
      body: _isLoading
          ? const CircularProgressIndicator() // Display the loading indicator
          : Column(
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
                          filteredCustomers[index].id,
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
                            String customerName = addCustomerController.text;
                            if (customerName.isNotEmpty) {
                              final random = Random();

                              // Generate a random integer between a specified range (inclusive)
                              int randomInt = random.nextInt(100000);
                              addCustomer(
                                customerName,
                                randomInt.toString(),
                              );
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
  final String id; // Unique identifier for the customer
  final String name;
  final int customerNumber;
  final int flen;
  final int mastek;
  final double flankot;
  final int zefet;

  Customer(
    this.id,
    this.flen,
    this.mastek,
    this.flankot,
    this.zefet, {
    required this.name,
    required this.customerNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'customerNumber': customerNumber,
      'flen': flen,
      'mastek': mastek,
      'flankot': flankot,
      'zefet': zefet,
    };
  }
}
