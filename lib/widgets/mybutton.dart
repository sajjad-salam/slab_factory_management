import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: camel_case_types
class mybutton extends StatelessWidget {
  const mybutton({
    super.key,
    required this.size,
    required this.name,
    required this.icon,
    required this.color,
    required this.rout,
  });
  final String rout;
  final Size size;
  final String name;
  final Icon icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Stack(
          children: [
            Container(
              // ignore: prefer_const_constructors
              margin: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              height: 100,
              // color: Colors.green,
              child: InkWell(
                onTap: () {
                  // فقط قم بأزالة التعليق عن السطر التالي
                  try {
                    Get.toNamed(rout);
                    // ignore: empty_catches
                  } catch (e) {}
                },
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  // فائدة الستاك انو اكدر اخلي اكثر من عنصر
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: color,
                          boxShadow: const [
                            //شادو او ضل للبوكس الازرق
                            BoxShadow(
                              offset: Offset(0, 15),
                              blurRadius: 25,
                              color: Colors.white,
                            )
                          ]),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      //خطوات اضافة الصورة داخل الكارد
                      child: Transform.scale(
                        scale: 1.5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          height: 100,
                          width: 150,

                          child: icon,
                          // child: Image.asset(
                          //   product.image,
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: SizedBox(
                        height: 136,
                        //لان الصورة عرضهة 200 ف اني نقصت عرض الشاشة من ال 200
                        width: size.width - 250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // نقل العناصر الى اقصى اليمين
                          children: [
                            const Spacer(), //مسافة
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                      fontFamily: "myfont", fontSize: 20),
                                )),
                            const Spacer(), // مسافة
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
