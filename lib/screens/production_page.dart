import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductionPage extends StatefulWidget {
  @override
  _ProductionPageState createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPage> {
  List<String> weeklySchedule = [
    'الأحد: 100',
    'الأثنين: 120',
    'الثلاثاء: 90',
    'الأربعاء: 110',
    'الخميس: 80',
    'الجمعة: 70',
    'السبت: 60',
  ];

  TextEditingController productionController = TextEditingController();
  TextEditingController inventoryController = TextEditingController();

  String production = '';
  String inventory = '';

  @override
  void dispose() {
    productionController.dispose();
    inventoryController.dispose();
    super.dispose();
  }

  void updateWeeklyProduction() {
    int totalProduction = int.tryParse(production) ?? 0;
    setState(() {
      production = totalProduction.toString();
    });
  }

  void openDayPage(String day) {
    String productionNumber = '';
    for (String scheduleEntry in weeklySchedule) {
      if (scheduleEntry.startsWith(day)) {
        productionNumber = scheduleEntry.split(': ')[1];
        break;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayPage(
          day: day,
          productionNumber: productionNumber,
        ),
      ),
    ).then((updatedProductionNumber) {
      if (updatedProductionNumber != null) {
        setState(() {
          for (int i = 0; i < weeklySchedule.length; i++) {
            if (weeklySchedule[i].startsWith(day)) {
              weeklySchedule[i] = '$day: $updatedProductionNumber';
              break;
            }
          }

          updateWeeklyProduction(); // Update the weekly production when a day's production is updated
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          "صفحة الأنتاخ",
          style: TextStyle(fontFamily: "myfont", fontSize: 25),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              textAlign: TextAlign.end,
              'الأنتاخ الأسبوعي',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "myfont"),
            ),
            SizedBox(height: 10),
            Text("0"),
            TextField(
              controller: productionController,
              onChanged: (value) {
                setState(() {
                  production = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'تعديل الأنتاج الأسوعي',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'المخزون',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "myfont"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: inventoryController,
              onChanged: (value) {
                setState(() {
                  inventory = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Enter inventory',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'الأنتاخ اليومي',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "myfont"),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: weeklySchedule.length,
                itemBuilder: (context, index) {
                  String scheduleEntry = weeklySchedule[index];
                  String day = scheduleEntry.split(': ')[0];
                  String productionNumber = scheduleEntry.split(': ')[1];
                  return ListTile(
                    title: Text(day),
                    subtitle: Text('$productionNumber'),
                    onTap: () {
                      openDayPage(day);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class DayPage extends StatefulWidget {
  final String day;
  final String productionNumber;

  const DayPage({
    Key? key,
    required this.day,
    required this.productionNumber,
  }) : super(key: key);

  @override
  _DayPageState createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {
  TextEditingController productionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    productionController.text = widget.productionNumber;
  }

  @override
  void dispose() {
    productionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          'انتاخ ${widget.day} ',
          style: TextStyle(fontFamily: "myfont"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: 10),
            TextField(
              controller: productionController,
              decoration: InputDecoration(
                labelText: 'ادخل كمية الأنتاج',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String updatedProduction = productionController.text;
                Navigator.pop(context, updatedProduction);
              },
              child: Text('تعديل'),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
