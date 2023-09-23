import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'list_page.dart';

// ignore: camel_case_types
class report extends StatelessWidget {
  const report({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        appBar: const CupertinoNavigationBar(
          previousPageTitle: "رجوع",
          middle: Text(
            "التقرير الشهري",
            style: TextStyle(fontFamily: "myfont", fontSize: 25),
          ),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Listpage(),
                ),
              );
            },
            child: const Text(
              'تصدير التقرير',
              style: TextStyle(
                fontFamily: "myfont",
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
