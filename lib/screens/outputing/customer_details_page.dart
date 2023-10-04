import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slab_factory_management/screens/outputing/out_page.dart';

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
                ? const CircularProgressIndicator() // Display the loading indicator
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
                        } catch (e) {
                          // ignore: avoid_print
                          print(e);
                        }
                      }
                      await prefs.setInt('total_in', total_in);

                      final updatedCustomer = Customer(
                          intflen, intmastek, intflankot, intzefet,
                          name: widget.customer.name,
                          customerNumber: int.tryParse(shtagernumber.text) ??
                              widget.customer.customerNumber);

                      // ignore: use_build_context_synchronously
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
