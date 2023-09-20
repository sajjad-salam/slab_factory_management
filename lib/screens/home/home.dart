import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/mybutton.dart';

// ignore: camel_case_types
class home_screen extends StatefulWidget {
  const home_screen({super.key});

  @override
  State<home_screen> createState() => _champ_screenState();
}

// ignore: camel_case_types
class _champ_screenState extends State<home_screen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          "الصفحة الرئيسية",
          style: TextStyle(fontFamily: "myfont", fontSize: 25),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SizedBox(
          height: size.height,
          child: Column(
            children: [
              const SizedBox(
                  height: 10), // Adjust the spacing between the items

              mybutton(
                rout: "",
                size: MediaQuery.of(context).size,
                name: 'الصادر',
                icon: const Icon(Icons.send),
                color: Colors.lightBlueAccent,
              ),

              const SizedBox(
                  height: 10), // Adjust the spacing between the items

              mybutton(
                rout: "",
                size: MediaQuery.of(context).size,
                name: 'الوارد',
                icon: const Icon(Icons.all_inbox_sharp),
                color: Colors.greenAccent,
              ),

              const SizedBox(
                  height: 10), // Adjust the spacing between the items
              mybutton(
                rout: "",
                size: MediaQuery.of(context).size,
                name: 'الأنتاخ',
                icon: const Icon(Icons.check_box),
                color: Colors.purpleAccent,
              ),

              // Add more mybutton widgets with appropriate data and spacing

              const SizedBox(
                  height: 10), // Adjust the spacing between the items

              mybutton(
                rout: "",
                size: MediaQuery.of(context).size,
                name: 'العمال',
                icon: const Icon(Icons.work),
                color: Colors.redAccent,
              ),

              const SizedBox(
                  height: 10), // Adjust the spacing between the items

              mybutton(
                rout: "",
                size: MediaQuery.of(context).size,
                name: 'ملاحضات',
                icon: const Icon(Icons.notes),
                color: Colors.amberAccent,
              ),

              const SizedBox(
                  height: 10), // Adjust the spacing between the items

              mybutton(
                rout: "",
                size: MediaQuery.of(context).size,
                name: 'الجرد الشهري',
                icon: const Icon(Icons.library_books_outlined),
                color: const Color.fromARGB(255, 184, 138, 123),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
