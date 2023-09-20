import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slab_factory_management/screens/home/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertinoDialog,
      initialRoute: "/login",
      getPages: [
        GetPage(
          name: "/home",
          page: () => const home_screen(),
        ),
        GetPage(
          name: "/login",
          page: () => MyHomePage(),
        ),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<QuerySnapshot> getCollectionSnapshot() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference collectionRef = firestore.collection('counters');
    QuerySnapshot querySnapshot = await collectionRef.get();
    return querySnapshot;
  }

  void printLastValueInCollection() async {
    try {
      QuerySnapshot querySnapshot = await getCollectionSnapshot();

      if (querySnapshot.docs.isNotEmpty) {
        QueryDocumentSnapshot lastDocument = querySnapshot.docs.last;
        var lastData = lastDocument.data() as Map<String, dynamic>;
        var lastValue = lastData['value'];
        print('Last value in collection: $lastValue');
      } else {
        print('No documents found in the collection');
      }
    } catch (e) {
      print('Error retrieving last value: $e');
    }
  }

  Future<void> _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
    });
  }

  void addDataToCollection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter++;
      prefs.setInt('counter', _counter);
    });
    // var connectivityResult = await Connectivity().checkConnectivity();
    // if (connectivityResult == ConnectivityResult.none) {
    try {
      // Get a reference to the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Create a new collection reference
      CollectionReference collectionRef = firestore.collection('counters');

      // Create a new document with a generated ID
      DocumentReference docRef = collectionRef.doc();

      // Set the data for the document
      await docRef.set({
        'value': _counter.toString(),
      });

      print('Document added successfully!');
    } catch (e) {
      print('Error adding document: $e');
    }
    // }
  }

  TextEditingController numberController = TextEditingController();

  void storeNumberInDatabase() async {
    String number = numberController.text;

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference docRef =
          firestore.collection('counters').doc('myCounter');

      await docRef.set({
        'value': number,
      });

      print('Number stored in the database successfully!');
    } catch (e) {
      print('Error storing number in the database: $e');
    }
  }

  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "ادارة معمل شتايكر بغداد",
          style: TextStyle(fontFamily: "myfont", color: Colors.black),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'تيست',
              style: TextStyle(fontFamily: "myfont", fontSize: 22),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextField(
              controller: numberController,
              onSubmitted: (value) {
                //              setState(() => _counter += int.parse(_controller));
                setState(() {
                  int intValue = int.parse(numberController.text);

                  _counter = intValue;
                });
                storeNumberInDatabase();
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: ' ادخل السعر ',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addDataToCollection();
          printLastValueInCollection();
          // _incrementCounter();
          // Get.toNamed("/login");
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
