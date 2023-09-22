import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          "التقرير ",
          style: TextStyle(fontFamily: "myfont", fontSize: 25),
        ),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "المخزون الكلي مع البيع ",
                style: TextStyle(fontFamily: "myfont", fontSize: 20),
              ),
              Text("0"),
              Text(
                ":الوارد الكلي ",
                style: TextStyle(fontFamily: "myfont", fontSize: 20),
              ),
              Text(
                "رمل",
                style: TextStyle(fontFamily: "myfont", fontSize: 20),
              ),
              Text(
                "0",
                style: TextStyle(fontFamily: "myfont", fontSize: 20),
              ),
              Text(
                "حصو",
                style: TextStyle(fontFamily: "myfont", fontSize: 20),
              ),
              Text(
                "0",
                style: TextStyle(fontFamily: "myfont", fontSize: 20),
              ),
              Text(
                "اسمنت",
                style: TextStyle(fontFamily: "myfont", fontSize: 20),
              ),
              Text(
                "0",
                style: TextStyle(fontFamily: "myfont", fontSize: 20),
              ),
              Text(
                "انتاج الشهر",
                style: TextStyle(fontFamily: "myfont", fontSize: 20),
              ),
              Text(
                "0",
                style: TextStyle(fontFamily: "myfont", fontSize: 20),
              ),
              Text(
                "مبلغ العمال الكلي",
                style: TextStyle(fontFamily: "myfont", fontSize: 20),
              ),
              Text(
                "0",
                style: TextStyle(fontFamily: "myfont", fontSize: 20),
              ),
              Text(
                "كمية الصادر الكلية",
                style: TextStyle(fontFamily: "myfont", fontSize: 20),
              ),
              Text(
                "0",
                style: TextStyle(fontFamily: "myfont", fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
