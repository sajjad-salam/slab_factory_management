// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:slab_factory_management/screens/production/pages/production_page.dart';

class chose_factory extends StatefulWidget {
  const chose_factory({super.key});

  @override
  State<chose_factory> createState() => _chose_factoryState();
}

class _chose_factoryState extends State<chose_factory> {
  int number_factory = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          'اختيار المعمل',
          style: TextStyle(fontFamily: "myfont"),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  number_factory = int.tryParse(value) ?? 1;
                });
              },
              maxLength: 1,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                icon: Icon(Icons.fact_check),
                labelText: 'ادخل رقم المعمل',
                labelStyle: TextStyle(
                  color: Color(0xFF6200EE),
                ),
                helperText: '1 , 2',
                suffixIcon: Icon(
                  Icons.check_circle,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF6200EE),
                  ),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  CupertinoPageRoute<Widget>(builder: (BuildContext context) {
                return ProductionPage(
                  number_factory: number_factory,
                );
              }));
            },
            // onPressed: () {},
            child: const Text(
              '          دخول            ',
              style: TextStyle(fontFamily: "myfont", fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
