// ignore_for_file: file_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class aggregateData {
  final String type;
  final int price;
  final String number;

  aggregateData({
    required this.type,
    required this.price,
    required this.number,
  });
}

// ignore: camel_case_types
class aggregatePage extends StatefulWidget {
  const aggregatePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _aggregatePageState createState() => _aggregatePageState();
}

// ignore: camel_case_types
class _aggregatePageState extends State<aggregatePage> {
  List<aggregateData> aggregateList = [];

  final TextEditingController typeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  // ignore: non_constant_identifier_names
  final TextEditingController type_car = TextEditingController();

  @override
  void dispose() {
    typeController.dispose();
    priceController.dispose();
    type_car.dispose();
    super.dispose();
  }

  Future<void> addaggregateDataToFirestore(aggregateData aggregateData) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference aggregateCollection =
          firestore.collection('aggregateData');

      await aggregateCollection.add({
        'type': aggregateData.type,
        'price': aggregateData.price,
        'number': aggregateData.number,
      });
    } catch (e) {
      print('Error adding aggregate data to Firestore: $e');
    }
  }

  Future<List<aggregateData>> loadaggregateDataFromFirestore() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference aggregateCollection =
          firestore.collection('aggregateData');

      QuerySnapshot querySnapshot = await aggregateCollection.get();

      List<aggregateData> aggregateList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return aggregateData(
          type: data['type'],
          price: data['price'],
          number: data['number'],
        );
      }).toList();
      setState(() {
        _isLoading = false;
      });
      return aggregateList;
    } catch (e) {
      print('Error loading aggregate data from Firestore: $e');
      return [];
    }
  }

  void addaggregateData() async {
    setState(() {
      _isLoading = true;
    });
    final type = typeController.text;
    final price = int.parse(priceController.text);
    final number = type_car.text;

    if (type.isNotEmpty && price > 0 && number.isNotEmpty) {
      final aggregatedata =
          aggregateData(type: type, price: price, number: number);

      // Save to Firestore
      await addaggregateDataToFirestore(aggregatedata);

      setState(() {
        aggregateList.add(aggregatedata);

        // Clear the input fields
        typeController.clear();
        priceController.clear();
        type_car.clear();

        // Recalculate total price
        calculateTotalPrice();
        // لحفض الكلفة الكلية للسمنت
        saveCostData();
        _isLoading = false;
      });
    }
  }

  int totalaggregatePrice = 0;
  void calculateTotalPrice() {
    int totalPrice = 0;
    for (final aggregate in aggregateList) {
      totalPrice += aggregate.price;
    }
    setState(() {
      totalaggregatePrice = totalPrice;
    });
    print(totalPrice);
  }

  @override
  void initState() {
    super.initState();
    loadCostData();
    loadaggregateDataFromFirestore().then((loadedData) {
      setState(() {
        aggregateList = loadedData;

        // Calculate total price
        calculateTotalPrice();
      });
    });
  }

  Future<void> saveCostData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore
          .collection('total_aggregate')
          .doc('total_aggregate_price')
          .set({
        'totalCost': totalaggregatePrice,
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
          .collection('total_aggregate')
          .doc('total_aggregate_price')
          .get();

      setState(
        () {
          totalaggregatePrice = snapshot['totalCost'] ?? 0;
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
          "الحصو",
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
                      labelText: 'اسم السائق',
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
                    controller: type_car,
                    decoration: const InputDecoration(
                      labelText: 'نوع الحمل',
                      labelStyle: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: addaggregateData,
                    child: const Text(
                      'اضافة البيانات ',
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: aggregateList.length,
                      itemBuilder: (context, index) {
                        final aggregate = aggregateList[index];
                        return ListTile(
                          title: Text(
                            'اسم السائق: ${aggregate.type}',
                            style: const TextStyle(
                                fontFamily: "myfont", fontSize: 20),
                          ),
                          subtitle: Text(
                            'السعر: \$${aggregate.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontFamily: "myfont", fontSize: 20),
                          ),
                          trailing: Text(
                            'نوع الحمل: ${aggregate.number}',
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
