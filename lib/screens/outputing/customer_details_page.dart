// ignore_for_file: non_constant_identifier_names, avoid_print, unused_local_variable, avoid_function_literals_in_foreach_calls

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slab_factory_management/screens/outputing/out_page.dart';

class CustomerDetailsPage extends StatefulWidget {
  final Customer customer;

  // ignore: prefer_const_constructors_in_immutables
  CustomerDetailsPage({super.key, required this.customer});

  @override
  // ignore: library_private_types_in_public_api
  _CustomerDetailsPageState createState() => _CustomerDetailsPageState();
}

class Note {
  final String title;
  final String content;

  Note({
    required this.title,
    required this.content,
  });

  // Define a toJson method to convert Note to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  List<Note> notes = [];
  Note noteFromJson(String noteJson) {
    Map<String, dynamic> json = jsonDecode(noteJson);
    return Note(
      title: json['title'],
      content: json['content'],
    );
  }

// Define a list to hold the loaded notes during initialization
  List<Note> loadedNotes = [];

// Load notes from the database only once during initialization
  void loadNotesFromDatabase() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference customerNotesCollection =
          firestore.collection('customer_notes');

      QuerySnapshot notesSnapshot = await customerNotesCollection
          .doc(widget.customer.name) // Specify the customer ID
          .collection('notes')
          .get();

      loadedNotes = notesSnapshot.docs
          .map((doc) => Note(
                title: doc['title'],
                content: doc['content'],
              ))
          .toList();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notes from Firestore: $e');
    }
  }

// Function to save notes to the database
  Future<void> saveNotesForCustomer(
      String customerId, List<Note> newNotes) async {
    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference customerNotesCollection =
          firestore.collection('customer_notes');

      // Merge existing notes with new notes
      List<Note> mergedNotes = [...loadedNotes, ...newNotes];

      // Clear existing notes for the customer
      await customerNotesCollection
          .doc(customerId)
          .collection('notes')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      // Add the merged notes back to Firestore
      for (Note note in mergedNotes) {
        await customerNotesCollection
            .doc(customerId)
            .collection('notes')
            .add(note.toJson());
      }

      setState(
        () {
          int intval = total.toInt();
          noteController.text = intval.toString();

          totalOutCost = totalOutCost + (int.parse(noteController.text));
          if ((int.parse(noteController.text) > 0)) {
            totalOutCost1 = totalOutCost1 + (int.parse(noteController.text));
          }
        },
      );
      await firestore.collection('total_out_cost').doc('total').set(
        {
          'Total': totalOutCost,
        },
      );
      await firestore.collection('total_out_cost1').doc('total').set(
        {
          'Total': totalOutCost1,
        },
      );

      // loadNotesFromDatabase();

      // Print a success message
      print('Notes saved to Firestore for customer: $customerId');
    } catch (e) {
      print('Error saving notes to Firestore: $e');
    }
  }

  Future<void> deleteNotesForClientFromFirestore(String clientId) async {
    setState(() {
      _isLoading = true;
    });
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference clientNotesCollection =
        firestore.collection('customer_notes');

    QuerySnapshot querySnapshot =
        await clientNotesCollection.doc(clientId).collection('notes').get();
    List<DocumentSnapshot> documents = querySnapshot.docs;

    List<Future<void>> deleteOperations = documents.map((doc) async {
      await clientNotesCollection
          .doc(clientId)
          .collection('notes')
          .doc(doc.id)
          .delete();
    }).toList();

    await Future.wait(deleteOperations);
  }

//  بهاي الدالة افلتر الارقام وانطي التوتل للعميل
  double total = 0;
  TextEditingController noteController = TextEditingController();
  double shtager = 0; // Initialize flankot with a very large number
  double filterAndProcessText(String inputText) {
    // Split the inputText by whitespace and trim any leading/trailing spaces
    final parts = inputText.trim().split(' ');

    for (final part in parts) {
      if (part.contains('#')) {
        // If the part contains '*', split and multiply the numbers
        final numbers = part.split('#').map((s) => double.tryParse(s) ?? 0);
        final numbersList = numbers.toList();

        if (numbersList.length == 2) {
          final product = numbersList.reduce((a, b) => a * b);
          total += product;

          // Check if one of the numbers is between 3000 and 5000 and store it in shtager
        }
      } else if (part.contains('*')) {
        final numbers = part.split('*').map((s) => double.tryParse(s) ?? 0);
        final numbersList = numbers.toList();

        // Handle the case for "شتايكر" and extract the number that follows it
        if (numbersList[0] >= 2000 && numbersList[0] <= 5000) {
          shtager = numbersList[1];
        } else if (numbersList[1] >= 2000 && numbersList[1] <= 5000) {
          shtager = numbersList[0];
        }
        if (numbersList.length == 2) {
          final product = numbersList.reduce((a, b) => a * b);
          total += product;

          // Check if one of the numbers is between 3000 and 5000 and store it in shtager
        }
      } else if (double.tryParse(part) != null) {
        // If the part is a valid number, subtract it from the total
        final number = double.parse(part);
        total -= number;
      }
    }

    // Print the calculated total and shtager
    print('Total: $total');
    print('Shtager: $shtager');

    return total;
  }

  void addNote() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    String newNoteTitle = noteController.text;
    String newNoteContent = ''; // Add content here if needed
    if (newNoteTitle.isNotEmpty) {
      setState(() {
        notes.add(Note(title: newNoteTitle, content: newNoteContent));
      });

      await saveNotesForCustomer(widget.customer.name, notes.cast<Note>());
      setState(() {
        _isLoading = false;
      });
    }
  }

  String noteToJson(Note note) {
    return jsonEncode({'title': note.title, 'content': note.content});
  }

  late TextEditingController shtagernumber;
  late TextEditingController zefet;
  late TextEditingController mastek;
  late TextEditingController flankot;
  late TextEditingController flen;

  // Future<List<Note>> loadNotesForClientFromLocalStorage(String clientId) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String>? notesJson = prefs.getStringList('Client_data_$clientId');
  //   return notesJson != null
  //       ? notesJson.map((noteJson) => noteFromJson(noteJson)).toList()
  //       : [];
  // }

  // Future<void> saveNotesForClientToLocalStorage(
  //     String clientId, List<Note> notes) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String> notesJson = notes.map((note) => noteToJson(note)).toList();
  //   await prefs.setStringList('Client_data_$clientId', notesJson);
  // }

  @override
  void initState() {
    super.initState();
    loadTotal_output();
    gettotal_outCost();
    gettotal_outCost2();
    gettotal_in();
    // loadNotesForClientFromLocalStorage(widget.customer.name).then((value) {
    //   setState(() {
    //     notes = value;
    //   });
    // });
    loadNotesFromDatabase();
    // loadNotesForCustomer(widget.customer.name).then((value) {
    //   setState(() {
    //     notes = value;
    //   });
    // });

    // loadNotesForCustomer(widget.customer.name);
    shtagernumber =
        TextEditingController(text: widget.customer.customerNumber.toString());
    flen = TextEditingController(text: widget.customer.flen.toString());
    zefet = TextEditingController(text: widget.customer.zefet.toString());
    flankot = TextEditingController(text: widget.customer.flankot.toString());
    mastek = TextEditingController(text: widget.customer.mastek.toString());
  }

  @override
  void dispose() {
    shtagernumber.dispose();
    super.dispose();
  }

  double totaloutputing = 0;

  Future<void> updateTotal_output() async {
    // int productionNumber = int.tryParse(customer.customerNumber) ?? 0;
    setState(() {
      totaloutputing += shtager;
    });

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('total_out').doc('cost').set(
      {
        'total': totaloutputing,
      },
    );
  }

  Future<void> loadTotal_output() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('total_out').doc('cost').get();

      setState(
        () {
          totaloutputing = snapshot['total'] ?? 0;
        },
      );
      setState(
        () {
          _isLoading = false;
        },
      );
    } catch (e) {
      print('Error loading cost data: $e');
    }
  }

  Future<void> updateTotal_in() async {
    // int productionNumber = int.tryParse(customer.customerNumber) ?? 0;
    setState(() {
      total_in -= shtager.toInt();
    });

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('total_in').doc('total').set(
      {
        'productionTotal': total_in,
      },
    );
  }

  int totalOutCost = 0;
  int totalOutCost1 = 0;

  void gettotal_outCost2() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('total_out_cost1').doc('total').get();

      setState(
        () {
          totalOutCost1 = snapshot['Total'] ?? 0;
        },
      );

      setState(
        () {
          _isLoading = false;
        },
      );
    } catch (e) {
      print('Error loading cost data: $e');
    }
  }

  void gettotal_outCost() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('total_out_cost').doc('total').get();

      setState(
        () {
          totalOutCost = snapshot['Total'] ?? 0;
        },
      );
      setState(
        () {
          _isLoading = false;
        },
      );
    } catch (e) {
      print('Error loading cost data: $e');
    }
  }

  int total_in = 0;
  void gettotal_in() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot =
          await firestore.collection('total_in').doc('total').get();

      setState(
        () {
          total_in = snapshot['productionTotal'] ?? 0;
        },
      );
      setState(
        () {
          _isLoading = false;
        },
      );
      // print(total_in);
      print(totalOutCost);
    } catch (e) {
      print('Error loading cost data: $e');
    }
  }

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          widget.customer.id.toString(),
          style: const TextStyle(fontFamily: "myfont", fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "عدد شتايكر العميل هو : ${widget.customer.flankot}",
              style: const TextStyle(fontFamily: "myfont", fontSize: 18),
            ),
            const SizedBox(height: 20),
            CupertinoTextField(
              decoration: BoxDecoration(
                // color: CupertinoColors.extraLightBackgroundGray,
                borderRadius: BorderRadius.circular(10),
              ),
              controller: noteController,
              autocorrect: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                filterAndProcessText(noteController.text);
                addNote();
                flankot.text = shtager.toString();
                // updateTotal_output();
                updateTotal_in();
              },
              placeholder: "....  اضافة وصل جديد",
              // maxLength: 10,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFamily: "myfont",
                color: Color.fromARGB(255, 0, 0, 0), // Set the color to white
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator() // Display the loading indicator
                : ElevatedButton(
                    onPressed: () async {
                      int intflen = int.parse(flen.text);
                      int intzefet = int.parse(zefet.text);
                      double intflankot = shtager + widget.customer.flankot;
                      int intmastek = int.parse(mastek.text);
                      widget.customer.customerNumber;
                      setState(() {
                        _isLoading = true;
                      });
                      updateTotal_output();

                      try {
                        setState(() {
                          _isLoading = false;
                        });
                      } catch (e) {
                        print(e);
                      }

                      final updatedCustomer = Customer(widget.customer.id,
                          intflen, intmastek, intflankot, intzefet,
                          name: widget.customer.name,
                          customerNumber: int.parse(noteController.text) +
                              widget.customer.customerNumber);

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context, updatedCustomer);
                      Get.snackbar("رسالة", "تم حفض البيانات بنجاح",
                          snackPosition: SnackPosition.BOTTOM);
                    },
                    child: const Text(
                      textAlign: TextAlign.end,
                      'تحديث',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "myfont",
                      ),
                    ),
                  ),
            Expanded(
              child: ListView.builder(
                itemCount: loadedNotes.length,
                itemBuilder: (context, index) {
                  Note note = loadedNotes[index];
                  return ListTile(
                    title: Text(
                      textAlign: TextAlign.end,
                      note.title,
                      style: const TextStyle(fontFamily: "myfont"),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                int intflen = int.parse(flen.text);
                int intzefet = int.parse(zefet.text);
                double intflankot = double.parse(flankot.text);
                int intmastek = int.parse(mastek.text);
                widget.customer.customerNumber;

                deleteNotesForClientFromFirestore(widget.customer.name);
                // deleteNotesForClientFromLocalStorage(widget.customer.name);

                final updatedCustomer = Customer(
                    widget.customer.id, intflen, intmastek, 0, intzefet,
                    name: widget.customer.name, customerNumber: 0);

                // ignore: use_build_context_synchronously
                Navigator.pop(context, updatedCustomer);
                print(widget.customer.name);
                print(widget.customer.customerNumber);
                Get.snackbar("رسالة", "تم تصفير الحساب بنجاح",
                    snackPosition: SnackPosition.BOTTOM);
              },
              child: const Text(
                textAlign: TextAlign.end,
                'تصفير الحساب ',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "myfont",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
