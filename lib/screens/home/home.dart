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
        child: Container(
          height: size.height,
          child: Column(
            children: [
              SizedBox(height: 10), // Adjust the spacing between the items

              mybutton(
                rout: "",
                size: MediaQuery.of(context).size,
                name: 'الصادر',
                icon: Icon(Icons.send),
                color: Colors.lightBlueAccent,
              ),

              SizedBox(height: 10), // Adjust the spacing between the items

              mybutton(
                rout: "",
                size: MediaQuery.of(context).size,
                name: 'الوارد',
                icon: Icon(Icons.all_inbox_sharp),
                color: Colors.greenAccent,
              ),

              SizedBox(height: 10), // Adjust the spacing between the items
              mybutton(
                rout: "",
                size: MediaQuery.of(context).size,
                name: 'الأنتاخ',
                icon: Icon(Icons.check_box),
                color: Colors.purpleAccent,
              ),

              // Add more mybutton widgets with appropriate data and spacing

              SizedBox(height: 10), // Adjust the spacing between the items

              mybutton(
                rout: "",
                size: MediaQuery.of(context).size,
                name: 'العمال',
                icon: Icon(Icons.work),
                color: Colors.redAccent,
              ),

              SizedBox(height: 10), // Adjust the spacing between the items

              mybutton(
                rout: "",
                size: MediaQuery.of(context).size,
                name: 'ملاحضات',
                icon: Icon(Icons.notes),
                color: Colors.amberAccent,
              ),

              SizedBox(height: 10), // Adjust the spacing between the items

              mybutton(
                rout: "",
                size: MediaQuery.of(context).size,
                name: 'الجرد الشهري',
                icon: Icon(Icons.library_books_outlined),
                color: Color.fromARGB(255, 184, 138, 123),
              ),
              // Container(
              //   height: size.height, // Adjust the height according to your needs
              //   child: ListView.builder(
              //     itemCount: 6,
              //     itemBuilder: (BuildContext context, int index) {
              //       // final buttonData = myButtonList[index];
              //       return mybutton(
              //         size: MediaQuery.of(context).size,
              //         name: 'name',
              //         icon: Icon(Icons.abc),
              //         color: Colors.black,
              //       );
              //     },
              //   ),
              // ),

              // ListView.builder(
              //   itemCount: 6,
              //   itemBuilder: (context, index) => mybutton(
              //     size: size,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
