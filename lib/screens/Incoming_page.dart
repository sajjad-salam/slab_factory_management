import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class incoming_screen extends StatefulWidget {
  const incoming_screen({super.key});

  @override
  State<incoming_screen> createState() => _incoming_screenState();
}

class _incoming_screenState extends State<incoming_screen> {
  int cement = 10;
  int sand = 20;
  int aggregate = 30;

  Future<void> _showSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Builder(
          builder: (BuildContext context) {
            final double keyboardHeight =
                MediaQuery.of(context).viewInsets.bottom;
            final double maxHeight = MediaQuery.of(context).size.height - 120;
            final double contentHeight =
                MediaQuery.of(context).size.height - keyboardHeight - 200;
            final bool isKeyboardOpen = keyboardHeight > 0;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: isKeyboardOpen ? maxHeight : contentHeight,
                ),
                child: AlertDialog(
                  title: Text(
                    'اضافة مواد',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: "myfont",
                      fontSize: 22,
                    ),
                  ),
                  contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          int intval = int.tryParse(value) ?? 0;
                          setState(() {
                            sand += intval;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'الرمل',
                        ),
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          int intval = int.tryParse(value) ?? 0;
                          setState(() {
                            aggregate += intval;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'الحصو',
                        ),
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          int intval = int.tryParse(value) ?? 0;
                          setState(() {
                            cement += intval;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'الأسمنت',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('حفض'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          sand = 0;
                          aggregate = 0;
                          cement = 0;
                        });
                      },
                      child: Text('تصفير الكل'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          "صفحة الـواردات",
          style: TextStyle(fontFamily: "myfont", fontSize: 25),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElementCard(
            elementName: 'الأسمنت',
            elementValue: cement,
          ),
          ElementCard(
            elementName: 'الرمل',
            elementValue: sand,
          ),
          ElementCard(
            elementName: 'الحصو',
            elementValue: aggregate,
          ),
          // Spacer(),
          SizedBox(
            height: 200,
          ),
          ElevatedButton(
            onPressed: () {
              _showSettingsDialog(context);
            },
            child: Text(
              'اضافة مواد',
              style: TextStyle(
                fontFamily: "myfont",
                fontSize: 30,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20), // Make the button rounded
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ElementCard extends StatefulWidget {
  final String elementName;
  final int elementValue;

  const ElementCard({
    required this.elementName,
    required this.elementValue,
  });

  @override
  _ElementCardState createState() => _ElementCardState();
}

class _ElementCardState extends State<ElementCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  widget.elementValue.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'myfont', // Set the custom font family
                  ),
                ),
                SizedBox(
                    width: 10), // Adds spacing between the number and the name
                Expanded(
                  child: Text(
                    widget.elementName,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'myfont', // Set the custom font family
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            SizedBox(
                height: 10), // Adds spacing between the elements and the button
          ],
        ),
      ),
    );
  }
}
