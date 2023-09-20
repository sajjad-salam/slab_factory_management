import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class champ_screen extends StatefulWidget {
  const champ_screen({super.key});

  @override
  State<champ_screen> createState() => _champ_screenState();
}

// ignore: camel_case_types
class _champ_screenState extends State<champ_screen> {
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
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 50),
                    // ignore: prefer_const_constructors
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                            // topLeft: Radius.circular(40),
                            // topRight: Radius.circular(40),
                            )),
                  ),
                  Container(
                    // ignore: prefer_const_constructors
                    margin: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    height: 100,
                    // color: Colors.green,
                    child: InkWell(
                      onTap: () {},
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        // فائدة الستاك انو اكدر اخلي اكثر من عنصر
                        children: [
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.amber,
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                height: 100,
                                width: 150,

                                child: const Icon(
                                  Icons.send,
                                ),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Text(
                                        "الصادر",
                                        style: TextStyle(
                                            fontFamily: "myfont", fontSize: 20),
                                      )),
                                  const Spacer(), // مسافة
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.amber,
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                height: 100,
                                width: 150,

                                child: const Icon(
                                  Icons.send,
                                ),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Text(
                                        "الصادر",
                                        style: TextStyle(
                                            fontFamily: "myfont", fontSize: 20),
                                      )),
                                  const Spacer(), // مسافة
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.amber,
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                height: 100,
                                width: 150,

                                child: const Icon(
                                  Icons.send,
                                ),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Text(
                                        "الصادر",
                                        style: TextStyle(
                                            fontFamily: "myfont", fontSize: 20),
                                      )),
                                  const Spacer(), // مسافة
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.amber,
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                height: 100,
                                width: 150,

                                child: const Icon(
                                  Icons.send,
                                ),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Text(
                                        "الصادر",
                                        style: TextStyle(
                                            fontFamily: "myfont", fontSize: 20),
                                      )),
                                  const Spacer(), // مسافة
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.amber,
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                height: 100,
                                width: 150,

                                child: const Icon(
                                  Icons.send,
                                ),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Text(
                                        "الصادر",
                                        style: TextStyle(
                                            fontFamily: "myfont", fontSize: 20),
                                      )),
                                  const Spacer(), // مسافة
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.amber,
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                height: 100,
                                width: 150,

                                child: const Icon(
                                  Icons.send,
                                ),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Text(
                                        "الصادر",
                                        style: TextStyle(
                                            fontFamily: "myfont", fontSize: 20),
                                      )),
                                  const Spacer(), // مسافة
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
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
          ],
        ),
      ),
    );
  }
}
