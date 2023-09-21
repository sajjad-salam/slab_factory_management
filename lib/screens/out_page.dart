import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class out_screen extends StatefulWidget {
  const out_screen({super.key});

  @override
  State<out_screen> createState() => _out_screenState();
}

class _out_screenState extends State<out_screen> {
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
    );
  }
}
