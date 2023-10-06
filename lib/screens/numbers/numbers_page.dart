// ignore_for_file: non_constant_identifier_names, avoid_print, library_private_types_in_public_api, no_logic_in_create_state

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  _WorkersPageState createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    loadCostDatatotal();
    load_number_of_workers();
  }

  int number_of_workers = 0;
  Future<void> load_number_of_workers() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot = await firestore
          .collection('number_of_workers')
          .doc('number_of_workers')
          .get();

      setState(
        () {
          number_of_workers = int.parse(snapshot['number'] ?? 0);
          _isLoading = false;
        },
      );
    } catch (e) {
      print('Error loading cost data: $e');
    }
  }

  String totalCost = "0";
  Future<void> loadCostDatatotal() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot snapshottotal =
          await firestore.collection('cost_modl').doc('mold').get();

      setState(
        () {
          totalCost = snapshottotal['mold_cost'] ?? 0.0;
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

  Future<void> edit_modl_cost() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('cost_modl').doc('mold').set(
        {
          'mold_cost': priceController.text,
        },
      );
      setState(
        () {
          _isLoading = false;
        },
      );
    } catch (e) {
      print('Error saving cost data: $e');
    }
  }

  Future<void> edit_number_of_workers() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore
          .collection('number_of_workers')
          .doc('number_of_workers')
          .set(
        {
          'number': numberofworkers.text,
        },
      );
      setState(
        () {
          _isLoading = false;
        },
      );
    } catch (e) {
      print('Error saving cost data: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  TextEditingController priceController = TextEditingController();
  TextEditingController numberofworkers = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          "صفحة الاعداد ",
          style: TextStyle(fontFamily: "myfont", fontSize: 20),
        ),
      ),
      body: _isLoading
          ? const CircularProgressIndicator()
          : Column(
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
                    // saveValuesToStorage();
                  },
                  style: const TextStyle(fontFamily: "myfont", fontSize: 20),
                  decoration: const InputDecoration(
                    labelText: 'ادخل عدد العمال',
                    prefixIcon: Icon(Icons.price_check),
                  ),
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    edit_modl_cost();
                    edit_number_of_workers();
                  },
                  child: const Text(
                    'تحديث الاعداد',
                    style: TextStyle(fontFamily: "myfont", fontSize: 20),
                  ),
                ),
                Text(
                  "عدد العمال الحالي هو :$number_of_workers",
                  style: const TextStyle(fontFamily: "myfont", fontSize: 20),
                ),
                Text(
                  "سعر القالب الحالي هو : $totalCost",
                  style: const TextStyle(fontFamily: "myfont", fontSize: 20),
                ),
                const SizedBox(height: 10),
              ],
            ),
    );
  }
}
