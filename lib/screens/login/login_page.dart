import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: camel_case_types
class login_page extends StatefulWidget {
  const login_page({super.key});

  @override
  State<login_page> createState() => _login_pageState();
}

// ignore: camel_case_types

// ignore: camel_case_types
class _login_pageState extends State<login_page> {
  TextEditingController user = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: <Widget>[
          const CupertinoSliverNavigationBar(
            // middle: Icon(Icons.abc),
            // leading:  ,
            largeTitle: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                textAlign: TextAlign.end,
                'ادارة معمل شتايكر بغداد',
                style: TextStyle(fontFamily: "myfont"),
              ),
            ),
          ),
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: CupertinoTextField(
                    decoration: BoxDecoration(
                      color: CupertinoColors.extraLightBackgroundGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    controller: user,

                    autocorrect: true,
                    textInputAction: TextInputAction.next,
                    placeholder: ":اسم المستخدم",
                    // maxLength: 10,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontFamily: "myfont",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: CupertinoTextField(
                    onSubmitted: (value) {
                      if (user.text == "aa" || password.text == "112233") {
                        Get.toNamed("/home");
                      } else {
                        Get.snackbar(
                          "خطا",
                          "خطأ في كلمة المرور او اسم المستخدم",
                        );
                      }
                    },
                    // ignore: avoid_print
                    // onSubmitted: (value) => print("submitid $value $email"),
                    obscureText: true,
                    controller: password,
                    obscuringCharacter: "*",
                    maxLength: 10,
                    textAlign: TextAlign.end,
                    placeholder: ":الرمز",
                    style: const TextStyle(fontFamily: "myfont"),
                    decoration: BoxDecoration(
                      color: CupertinoColors.extraLightBackgroundGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: CupertinoButton.filled(
                    onPressed: () {
                      if (user.text == "aa" && password.text == "112233") {
                        Get.toNamed("/home");
                      } else {
                        Get.snackbar(
                            "خطا", "خطأ في كلمة المرور او اسم المستخدم",
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                    borderRadius: BorderRadius.circular(15),
                    disabledColor: Colors.amber,
                    child: const Text('تسجيل الدخول',
                        style: TextStyle(fontFamily: "myfont", fontSize: 18)),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                const Text(
                  "تطوير المهندس سجاد سلام",
                  style: TextStyle(
                      fontFamily: "myfont", fontSize: 20, color: Colors.black),
                ),
                const Text(
                  "07748820206",
                  style: TextStyle(
                      fontFamily: "myfont", fontSize: 18, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
