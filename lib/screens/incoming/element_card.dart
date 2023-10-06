// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ElementCard extends StatefulWidget {
  final String elementName;
  final int elementValue;

  const ElementCard({
    super.key,
    required this.elementName,
    required this.elementValue,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ElementCardState createState() => _ElementCardState();
}

class _ElementCardState extends State<ElementCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  widget.elementValue.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'myfont', // Set the custom font family
                  ),
                ),
                const SizedBox(
                    width: 10), // Adds spacing between the number and the name
                Expanded(
                  child: Text(
                    widget.elementName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'myfont', // Set the custom font family
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(
                height: 10), // Adds spacing between the elements and the button
          ],
        ),
      ),
    );
  }
}
