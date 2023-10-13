// ignore_for_file: file_names, avoid_print, camel_case_types, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class sandData {
  final String type;
  final int price;
  final String number;

  sandData({
    required this.type,
    required this.price,
    required this.number,
  });
}

class sandPage extends StatefulWidget {
  const sandPage({super.key});

  @override
  _sandPageState createState() => _sandPageState();
}

class _sandPageState extends State<sandPage> {
  List<sandData> sandList = [];

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

  Future<void> addsandDataToFirestore(sandData sandData) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference sandCollection = firestore.collection('sandData');

      await sandCollection.add({
        'type': sandData.type,
        'price': sandData.price,
        'number': sandData.number,
      });
    } catch (e) {
      print('Error adding sand data to Firestore: $e');
    }
  }

  Future<List<sandData>> loadsandDataFromFirestore() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference sandCollection = firestore.collection('sandData');

      QuerySnapshot querySnapshot = await sandCollection.get();

      List<sandData> sandList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return sandData(
          type: data['type'],
          price: data['price'],
          number: data['number'],
        );
      }).toList();
      setState(() {
        _isLoading = false;
      });
      return sandList;
    } catch (e) {
      print('Error loading sand data from Firestore: $e');
      return [];
    }
  }

  void addsandData() async {
    setState(() {
      _isLoading = true;
    });
    final type = typeController.text;
    final price = int.parse(priceController.text);
    final number = numberController.text;

    if (type.isNotEmpty && price > 0 && number.isNotEmpty) {
      final sanddata = sandData(type: type, price: price, number: number);

      // Save to Firestore
      await addsandDataToFirestore(sanddata);

      setState(() {
        sandList.add(sanddata);

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

  int totalsandPrice = 0;
  void calculateTotalPrice() {
    int totalPrice = 0;
    for (final sand in sandList) {
      totalPrice += sand.price;
    }
    setState(() {
      totalsandPrice = totalPrice;
    });
    print(totalPrice);
  }

  @override
  void initState() {
    super.initState();
    loadCostData();
    loadsandDataFromFirestore().then((loadedData) {
      setState(() {
        sandList = loadedData;

        // Calculate total price
        calculateTotalPrice();
      });
    });
  }

  Future<void> saveCostData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('total_sand').doc('total_sand_price').set({
        'totalCost': totalsandPrice,
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
          .collection('total_sand')
          .doc('total_sand_price')
          .get();

      setState(
        () {
          totalsandPrice = snapshot['totalCost'] ?? 0;
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
          "الرمل",
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
                    controller: numberController,
                    decoration: const InputDecoration(
                      labelText: 'نوع الحمل',
                      labelStyle: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: addsandData,
                    child: const Text(
                      'اضافة البيانات ',
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sandList.length,
                      itemBuilder: (context, index) {
                        final sand = sandList[index];
                        return ListTile(
                          title: Text(
                            'اسم السائق: ${sand.type}',
                            style: const TextStyle(
                                fontFamily: "myfont", fontSize: 20),
                          ),
                          subtitle: Text(
                            'السعر: \$${sand.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontFamily: "myfont", fontSize: 20),
                          ),
                          trailing: Text(
                            'نوع الحمل: ${sand.number}',
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
