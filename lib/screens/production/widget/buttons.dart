import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: camel_case_types
class buttonresetworkerdata extends StatelessWidget {
  const buttonresetworkerdata({super.key, required this.deleteCostDocument});
  final Function deleteCostDocument;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        deleteCostDocument();

        Get.snackbar(
            "رسالة", " تم تصفير حساب العمال بنجاح يرجى الخروخ والعودة مجددا",
            snackPosition: SnackPosition.BOTTOM);
      },
      child: const Text(
        'تصفير حساب العمال ',
        style: TextStyle(fontFamily: "myfont", fontSize: 18),
      ),
    );
  }
}
