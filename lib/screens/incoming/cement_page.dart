// ignore_for_file: file_names, avoid_print, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CementPage extends StatefulWidget {
  @override
  _CementPageState createState() => _CementPageState();
}

class _CementPageState extends State<CementPage> {
  List<CementData> cementList = [];

  final TextEditingController typeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  @override
  void dispose() {
    typeController.dispose();
    priceController.dispose();
    numberController.dispose();
    super.dispose();
  }

  Future<void> addCementDataToFirestore(CementData cementData) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference cementCollection = firestore.collection('cementData');

      await cementCollection.add({
        'type': cementData.type,
        'price': cementData.price,
        'number': cementData.number,
      });
    } catch (e) {
      print('Error adding cement data to Firestore: $e');
    }
  }

  Future<List<CementData>> loadCementDataFromFirestore() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference cementCollection = firestore.collection('cementData');

      QuerySnapshot querySnapshot = await cementCollection.get();

      List<CementData> cementList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return CementData(
          type: data['type'],
          price: data['price'],
          number: data['number'],
        );
      }).toList();
      setState(() {
        _isLoading = false;
      });
      return cementList;
    } catch (e) {
      print('Error loading cement data from Firestore: $e');
      return [];
    }
  }

  void addCementData() async {
    setState(() {
      _isLoading = true;
    });
    final type = typeController.text;
    final price = int.parse(priceController.text);
    final number = numberController.text;

    if (type.isNotEmpty && price > 0 && number.isNotEmpty) {
      final cementData = CementData(type: type, price: price, number: number);

      // Save to Firestore
      await addCementDataToFirestore(cementData);

      setState(() {
        cementList.add(cementData);

        // Clear the input fields
        typeController.clear();
        priceController.clear();
        numberController.clear();

        // Recalculate total price
        calculateTotalPrice();
        // لحفض الكلفة الكلية للسمنت
        saveCostData();
        _isLoading = false;
      });
    }
  }

  int totalCementPrice = 0;
  void calculateTotalPrice() {
    int totalPrice = 0;
    for (final cement in cementList) {
      totalPrice += cement.price;
    }
    setState(() {
      totalCementPrice = totalPrice;
    });
    print(totalPrice);
  }

  @override
  void initState() {
    super.initState();
    loadCostData();
    loadCementDataFromFirestore().then((loadedData) {
      setState(() {
        cementList = loadedData;

        // Calculate total price
        calculateTotalPrice();
      });
    });
  }

  Future<void> saveCostData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('total_cement').doc('total_cement_price').set({
        'totalCost': totalCementPrice,
      });
    } catch (e) {
      print('Error saving cost data: $e');
    }
  }

  Future<void> loadCostData() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot = await firestore
          .collection('total_cement')
          .doc('total_cement_price')
          .get();

      setState(
        () {
          totalCementPrice = snapshot['totalCost'] ?? 0;
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

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.pink[800],
        previousPageTitle: "رجوع",
        middle: const Text(
          "الأسمنت",
          style: TextStyle(fontFamily: "myfont", fontSize: 20),
        ),
      ),
      body: _isLoading
          ? const CircularProgressIndicator() // Display the loading indicator
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: typeController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'نوع الاسمنت ',
                      labelStyle: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                  ),
                  TextField(
                    textInputAction: TextInputAction.next,
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'السعر',
                      labelStyle: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                  ),
                  TextField(
                    textInputAction: TextInputAction.done,
                    controller: numberController,
                    decoration: const InputDecoration(
                      labelText: 'العدد',
                      labelStyle: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: addCementData,
                    child: const Text(
                      'اضافة البيانات ',
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cementList.length,
                      itemBuilder: (context, index) {
                        final cement = cementList[index];
                        return ListTile(
                          title: Text(
                            'النوع: ${cement.type}',
                            style: const TextStyle(
                                fontFamily: "myfont", fontSize: 20),
                          ),
                          subtitle: Text(
                            'السعر: \$${cement.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontFamily: "myfont", fontSize: 20),
                          ),
                          trailing: Text(
                            'العدد: ${cement.number}',
                            style: const TextStyle(
                                fontFamily: "myfont", fontSize: 20),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class CementData {
  final String type;
  final int price;
  final String number;

  CementData({
    required this.type,
    required this.price,
    required this.number,
  });
}
