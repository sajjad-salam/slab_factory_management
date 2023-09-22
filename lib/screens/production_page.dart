import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProductionPage extends StatefulWidget {
  const ProductionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
            const Text(
              textAlign: TextAlign.end,
              'الأنتاخ الأسبوعي',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "myfont"),
            ),
            const SizedBox(height: 10),
            const Text("0"),
            TextField(
              controller: productionController,
              onChanged: (value) {
                setState(() {
                  production = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'تعديل الأنتاج الأسوعي',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'المخزون',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "myfont"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: inventoryController,
              onChanged: (value) {
                setState(() {
                  inventory = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'ادخل المخزون',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'الأنتاخ اليومي',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "myfont"),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: weeklySchedule.length,
                itemBuilder: (context, index) {
                  String scheduleEntry = weeklySchedule[index];
                  String day = scheduleEntry.split(': ')[0];
                  String productionNumber = scheduleEntry.split(': ')[1];
                  return ListTile(
                    title: Text(day),
                    subtitle: Text(productionNumber),
                    onTap: () {
                      openDayPage(day);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
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
  // ignore: library_private_types_in_public_api
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
          style: const TextStyle(fontFamily: "myfont"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: productionController,
              decoration: const InputDecoration(
                labelText: 'ادخل كمية الأنتاج',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String updatedProduction = productionController.text;
                Navigator.pop(context, updatedProduction);
              },
              child: const Text('تعديل'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
