// ignore_for_file: avoid_print, prefer_const_constructors, use_build_context_synchronously, non_constant_identifier_names

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionPage extends StatefulWidget {
  const ProductionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductionPageState createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPage> {
  int totalWeeklyProduction = 0;

  List<String> weeklySchedule = [
    'الأحد: 100',
    'الأثنين: 120',
    'الثلاثاء: 90',
    'الأربعاء: 110',
    'الخميس: 80',
    'الجمعة: 70',
    'السبت: 60',
  ];
  bool _isLoading = false;

  TextEditingController productionController = TextEditingController();

  String production = '';
  String inventory = '';

  @override
  void dispose() {
    productionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadWeeklyDataFromStorage();
    startDataUpdateTimer();
    getUnaffectedProductionTotal();
    gettotal_in();
    Map<String, List<Note>> dailyNotes = {
      'الأحد': [],
      'الأثنين': [],
      'الثلاثاء': [],
      'الأربعاء': [],
      'الخميس': [],
      'الجمعة': [],
      'السبت': [],
    };
  }

  void startDataUpdateTimer() {
    Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      updateDataAndCheckInternet();
    });
  }

  void updateDataAndCheckInternet() async {
    bool hasInternet = await checkInternetConnectivity();
    if (hasInternet) {
      await saveWeeklyProductionToDatabase();
    } else {
      print('No internet connection available. Data update postponed.');
    }
  }

  // هذا المتغير هو المخزون الكلي
  int total_in = 0;

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  int weeklyProductionTotal = 0;

  int totalProduction = 0;

  void updateWeeklyProduction() {
    for (String scheduleEntry in weeklySchedule) {
      int productionNumber = int.tryParse(scheduleEntry.split(': ')[1]) ?? 0;
      totalProduction += productionNumber;
    }
    setState(() {
      totalWeeklyProduction = totalProduction;
      production = totalWeeklyProduction.toString();
    });
  }

  void openDayPage(String day) {
    String productionNumber = '';
    int Daynumber = 0;
    for (String scheduleEntry in weeklySchedule) {
      if (scheduleEntry.startsWith(day)) {
        productionNumber = scheduleEntry.split(': ')[1];
        // Daynumber
        break;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayPage(
          day: day,
          productionNumber: productionNumber,
          totalWeeklyProduction: totalWeeklyProduction,
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
          // print(day);

          updateWeeklyProduction(); // Update the weekly production when a day's production is updated
          saveWeeklyScheduleToStorage(); // Save the updated weekly schedule to storage
          saveWeeklyProductionToDatabase(); // Save the updated weekly production to the database
        });
      }
    });
  }

  Future<void> saveWeeklyProductionToDatabase() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final firestore = FirebaseFirestore.instance;
      final collectionRef = firestore.collection('weekly_production');

      // Clear the existing documents in the collection
      await collectionRef.get().then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      int totalProduction =
          0; // Initialize the variable to calculate the affected total

      for (String scheduleEntry in weeklySchedule) {
        final day = scheduleEntry.split(': ')[0];
        final productionNumber =
            int.tryParse(scheduleEntry.split(': ')[1]) ?? 0;

        totalProduction += productionNumber; // Accumulate the production number

        await collectionRef.doc(day).set({
          'day': day,
          'productionNumber': productionNumber,
        });
      }

      setState(() {
        weeklyProductionTotal =
            totalProduction; // Update the affected weekly production total
      });

      print('Weekly production data saved to the database.');

      // Calculate the unaffected weekly production total separately
      int unaffectedTotal = 0;
      for (String scheduleEntry in weeklySchedule) {
        final productionNumber =
            int.tryParse(scheduleEntry.split(': ')[1]) ?? 0;
        unaffectedTotal += productionNumber;
      }
      unaffectedWeeklyProductionTotal = unaffectedTotal;

      // Save the unaffected weekly production total in device storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          'unaffectedProductionTotal', unaffectedWeeklyProductionTotal);

      // Save the unaffected weekly production total in a new collection in the database
      await firestore.collection('unaffected_production').doc('total').set({
        'productionTotal': unaffectedWeeklyProductionTotal,
      });
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error saving weekly production to the database: $e');
    }
  }

  void getUnaffectedProductionTotal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedProductionTotal =
        prefs.getInt('unaffectedProductionTotal') ?? 0;
    setState(() {
      unaffectedWeeklyProductionTotal = storedProductionTotal;
    });
  }

  void gettotal_in() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedProductionTotal = prefs.getInt('total_in') ?? 0;
    setState(() {
      total_in = storedProductionTotal;
    });
  }

  Future<void> loadWeeklyDataFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('weeklySchedule');
      final totalProduction = prefs.getInt('weeklyProductionTotal');
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        setState(() {
          weeklySchedule = jsonList.map((json) => json.toString()).toList();
          weeklyProductionTotal = totalProduction ?? 0;
          production = weeklyProductionTotal.toString();
        });
      }
    } catch (e) {
      print('Error loading weekly data from storage: $e');
    }
  }

  Future<void> saveWeeklyScheduleToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = weeklySchedule.map((entry) => entry).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString('weeklySchedule', jsonString);
      await prefs.setInt('weeklyProductionTotal', weeklyProductionTotal);
    } catch (e) {
      print('Error saving weekly schedule to storage: $e');
    }
  }

  Future<void> loadWeeklyScheduleFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('weeklySchedule');
      final totalProduction = prefs.getInt('totalWeeklyProduction');
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        setState(() {
          weeklySchedule = jsonList.map((json) => json.toString()).toList();
          totalWeeklyProduction = totalProduction ?? 0;
          production = totalWeeklyProduction.toString();
        });
      }
    } catch (e) {
      print('Error loading weekly schedule from storage: $e');
    }
  }

  int unaffectedWeeklyProductionTotal = 0;
  void calculateWeeklyProduction() {
    weeklyProductionTotal = 0;
    for (String scheduleEntry in weeklySchedule) {
      final productionNumber = int.tryParse(scheduleEntry.split(': ')[1]) ?? 0;
      weeklyProductionTotal += productionNumber;
    }
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تحذير'),
          content: Text('هل تريد تصفير المخزون ؟'),
          actions: [
            TextButton(
              onPressed: () {
                // Handle 'No' option
                Navigator.of(context).pop();
              },
              child: Text('لا'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  total_in = 0;
                });
                final firestore = FirebaseFirestore.instance;
                SharedPreferences prefs = await SharedPreferences.getInstance();

                await prefs.setInt('total_in', total_in);
                // Save the unaffected weekly production total in a new collection in the database
                await firestore.collection('total_in').doc('total').set({
                  'productionTotal': total_in,
                });
                // Handle 'Yes' option
                // Call your function or perform the desired action here
                Navigator.of(context).pop();
                // Add your logic here
              },
              child: Text('نعم'),
            ),
          ],
        );
      },
    );
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
            Text(unaffectedWeeklyProductionTotal.toString()),
            const SizedBox(height: 20),
            const Text(
              'المخزون',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "myfont"),
            ),
            const SizedBox(height: 10),
            Text(total_in.toString()),
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
                    title: Text(
                      textAlign: TextAlign.end,
                      day,
                      style: TextStyle(
                        fontFamily: "myfont",
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Text(
                      productionNumber,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontFamily: "myfont",
                        fontSize: 20,
                      ),
                    ),
                    onTap: () {
                      openDayPage(day);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // Display the loading indicator
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // _isLoading = true;
                        weeklyProductionTotal = 0;
                        for (int i = 0; i < weeklySchedule.length; i++) {
                          final day = weeklySchedule[i].split(': ')[0];
                          weeklySchedule[i] =
                              '$day: 0'; // Set the day number to 0
                        }
                        calculateWeeklyProduction(); // Recalculate the weekly production total
                        production =
                            weeklyProductionTotal.toString(); // Update the UI
                      });
                      saveWeeklyScheduleToStorage();
                      saveWeeklyProductionToDatabase();
                      print(unaffectedWeeklyProductionTotal);
                    },
                    child: Text(
                      'تصفير الأسبوع',
                      style: TextStyle(
                        fontFamily: "myfont",
                        fontSize: 20,
                      ),
                    ),
                  ),
            ElevatedButton(
              onPressed: () {
                _showWarningDialog(context);
              },
              child: Text(
                'تصفير المخزون',
                style: TextStyle(
                  fontFamily: "myfont",
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Note {
  final String title;
  final String content;

  Note({required this.title, required this.content});
}

class DayPage extends StatefulWidget {
  final String day;
  final String productionNumber;

  const DayPage({
    Key? key,
    required this.day,
    required this.productionNumber,
    required int totalWeeklyProduction,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DayPageState createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {
  TextEditingController productionController = TextEditingController();

  int totalWeeklyProduction = 0;

  List<String> weeklySchedule = [
    'الأحد: 100',
    'الأثنين: 120',
    'الثلاثاء: 90',
    'الأربعاء: 110',
    'الخميس: 80',
    'الجمعة: 70',
    'السبت: 60',
  ];

  String production = '';
  String inventory = '';

  @override
  void dispose() {
    productionController.dispose();
    super.dispose();
  }

  TextEditingController noteController = TextEditingController();
  void addNote() async {
    String newNoteTitle = noteController.text;
    String newNoteContent = ''; // Add content here if needed
    if (newNoteTitle.isNotEmpty) {
      setState(() {
        notes.add(Note(title: newNoteTitle, content: newNoteContent));
        noteController.clear();
      });
      await saveNotes(notes.cast<Note>());
    }
  }

  List<String>? notesJson = [];
  MaterialStateProperty<Color?> amberColor =
      MaterialStateProperty.all<Color?>(const Color.fromARGB(255, 105, 63, 0));
  Future<List<Note>> loadNotes() async {
    switch (widget.day) {
      case "الأحد":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        notesJson = prefs.getStringList('notes_sun');
        break;
      case "الأثنين":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        notesJson = prefs.getStringList('notes_mon');
        break;
      case "الثلاثاء":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        notesJson = prefs.getStringList('notes_tue');
        break;
      case "الأربعاء":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        notesJson = prefs.getStringList('notes_wed');
        break;
      case "الخميس":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        notesJson = prefs.getStringList('notes_thu');
        break;
      case "الجمعة":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        notesJson = prefs.getStringList('notes_fri');
        break;
      case "السبت":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        notesJson = prefs.getStringList('notes_sat');
        break;
      default:
        SharedPreferences prefs = await SharedPreferences.getInstance();
        notesJson = prefs.getStringList('notes');
    }

    return notesJson != null
        ? notesJson!.map((noteJson) => noteFromJson(noteJson)).toList()
        : [];
  }

  void deleteNote(int index) {
    setState(() {
      Note deletedNote = notes.removeAt(index);
      deleteNoteFromStorage(deletedNote);
    });
  }

  List<Note> notes = [];

  void deleteNoteFromStorage(Note note) async {
    switch (widget.day) {
      case "الأحد":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String>? storedNotes = prefs.getStringList('notes_sun');

        if (storedNotes != null) {
          String noteJson = noteToJson(note);
          storedNotes.remove(noteJson);
          await prefs.setStringList('notes_sun', storedNotes);
        }
        break;
      case "الأثنين":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String>? storedNotes = prefs.getStringList('notes_mon');

        if (storedNotes != null) {
          String noteJson = noteToJson(note);
          storedNotes.remove(noteJson);
          await prefs.setStringList('notes_mon', storedNotes);
        }
        break;
      case "الثلاثاء":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String>? storedNotes = prefs.getStringList('notes_tue');

        if (storedNotes != null) {
          String noteJson = noteToJson(note);
          storedNotes.remove(noteJson);
          await prefs.setStringList('notes_tue', storedNotes);
        }
        break;
      case "الأربعاء":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String>? storedNotes = prefs.getStringList('notes_wed');

        if (storedNotes != null) {
          String noteJson = noteToJson(note);
          storedNotes.remove(noteJson);
          await prefs.setStringList('notes_wed', storedNotes);
        }
        break;
      case "الخميس":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String>? storedNotes = prefs.getStringList('notes_thu');

        if (storedNotes != null) {
          String noteJson = noteToJson(note);
          storedNotes.remove(noteJson);
          await prefs.setStringList('notes_thu', storedNotes);
        }
        break;
      case "الجمعة":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String>? storedNotes = prefs.getStringList('notes_fri');

        if (storedNotes != null) {
          String noteJson = noteToJson(note);
          storedNotes.remove(noteJson);
          await prefs.setStringList('notes_fri', storedNotes);
        }
        break;
      case "السبت":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String>? storedNotes = prefs.getStringList('notes_fri');

        if (storedNotes != null) {
          String noteJson = noteToJson(note);
          storedNotes.remove(noteJson);
          await prefs.setStringList('notes_fri', storedNotes);
        }
        break;
      default:
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String>? storedNotes = prefs.getStringList('notes');

        if (storedNotes != null) {
          String noteJson = noteToJson(note);
          storedNotes.remove(noteJson);
          await prefs.setStringList('notes', storedNotes);
        }
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    switch (widget.day) {
      case "الأحد":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> notesJson = notes.map((note) => noteToJson(note)).toList();
        await prefs.setStringList('notes_sun', notesJson);

        break;
      case "الأثنين":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> notesJson = notes.map((note) => noteToJson(note)).toList();
        await prefs.setStringList('notes_mon', notesJson);

        break;
      case "الثلاثاء":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> notesJson = notes.map((note) => noteToJson(note)).toList();
        await prefs.setStringList('notes_tue', notesJson);

        break;
      case "الأربعاء":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> notesJson = notes.map((note) => noteToJson(note)).toList();
        await prefs.setStringList('notes_wed', notesJson);

        break;
      case "الخميس":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> notesJson = notes.map((note) => noteToJson(note)).toList();
        await prefs.setStringList('notes_thu', notesJson);

        break;
      case "الجمعة":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> notesJson = notes.map((note) => noteToJson(note)).toList();
        await prefs.setStringList('notes_fri', notesJson);

        break;
      case "السبت":
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> notesJson = notes.map((note) => noteToJson(note)).toList();
        await prefs.setStringList('notes_sat', notesJson);

        break;
      default:
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> notesJson = notes.map((note) => noteToJson(note)).toList();
        await prefs.setStringList('notes', notesJson);
    }
  }

  String noteToJson(Note note) {
    return jsonEncode({'title': note.title, 'content': note.content});
  }

  Note noteFromJson(String noteJson) {
    Map<String, dynamic> json = jsonDecode(noteJson);
    return Note(
      title: json['title'],
      content: json['content'],
    );
  }

  @override
  void initState() {
    super.initState();

    loadWeeklyDataFromStorage();
    startDataUpdateTimer();
    getUnaffectedProductionTotal();
    gettotal_in();
    loadNotes().then((loadedNotes) {
      setState(() {
        notes = loadedNotes;
      });
    });
  }

  void startDataUpdateTimer() {
    Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      updateDataAndCheckInternet();
    });
  }

  void updateDataAndCheckInternet() async {
    bool hasInternet = await checkInternetConnectivity();
    if (hasInternet) {
      await saveWeeklyProductionToDatabase();
    } else {
      print('No internet connection available. Data update postponed.');
    }
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  int weeklyProductionTotal = 0;
  // هذا المتغير هو المخزون الكلي
  int total_in = 0;

  int totalProduction = 0;
  void updateWeeklyProduction() {
    for (String scheduleEntry in weeklySchedule) {
      int productionNumber = int.tryParse(scheduleEntry.split(': ')[1]) ?? 0;
      totalProduction += productionNumber;
    }
    setState(() {
      totalWeeklyProduction = totalProduction;
      production = totalWeeklyProduction.toString();
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
          totalWeeklyProduction: totalWeeklyProduction,
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
          saveWeeklyScheduleToStorage(); // Save the updated weekly schedule to storage
          saveWeeklyProductionToDatabase(); // Save the updated weekly production to the database
        });
      }
    });
  }

  Future<void> saveWeeklyProductionToDatabase() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final collectionRef = firestore.collection('weekly_production');

      // Clear the existing documents in the collection
      await collectionRef.get().then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      int totalProduction =
          0; // Initialize the variable to calculate the affected total

      for (String scheduleEntry in weeklySchedule) {
        final day = scheduleEntry.split(': ')[0];
        final productionNumber =
            int.tryParse(scheduleEntry.split(': ')[1]) ?? 0;

        totalProduction += productionNumber; // Accumulate the production number

        await collectionRef.doc(day).set({
          'day': day,
          'productionNumber': productionNumber,
        });
      }

      setState(() {
        weeklyProductionTotal =
            totalProduction; // Update the affected weekly production total
      });

      print('Weekly production data saved to the database.');

      // Calculate the unaffected weekly production total separately
      int unaffectedTotal = 0;
      for (String scheduleEntry in weeklySchedule) {
        final productionNumber =
            int.tryParse(scheduleEntry.split(': ')[1]) ?? 0;
        unaffectedTotal += productionNumber;
      }
      unaffectedWeeklyProductionTotal = unaffectedTotal;

      // Save the unaffected weekly production total in device storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          'unaffectedProductionTotal', unaffectedWeeklyProductionTotal);

      // Save the unaffected weekly production total in a new collection in the database
      await firestore.collection('unaffected_production').doc('total').set({
        'productionTotal': unaffectedWeeklyProductionTotal,
      });
    } catch (e) {
      print('Error saving weekly production to the database: $e');
    }
  }

  void getUnaffectedProductionTotal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedProductionTotal =
        prefs.getInt('unaffectedProductionTotal') ?? 0;
    setState(() {
      unaffectedWeeklyProductionTotal = storedProductionTotal;
    });
  }

  void gettotal_in() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int storedProductionTotal = prefs.getInt('total_in') ?? 0;
    setState(() {
      total_in = storedProductionTotal;
    });
  }

  Future<void> loadWeeklyDataFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('weeklySchedule');
      final totalProduction = prefs.getInt('weeklyProductionTotal');
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        setState(() {
          weeklySchedule = jsonList.map((json) => json.toString()).toList();
          weeklyProductionTotal = totalProduction ?? 0;
          production = weeklyProductionTotal.toString();
        });
      }
    } catch (e) {
      print('Error loading weekly data from storage: $e');
    }
  }

  Future<void> saveWeeklyScheduleToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = weeklySchedule.map((entry) => entry).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString('weeklySchedule', jsonString);
      await prefs.setInt('weeklyProductionTotal', weeklyProductionTotal);
    } catch (e) {
      print('Error saving weekly schedule to storage: $e');
    }
  }

  Future<void> loadWeeklyScheduleFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('weeklySchedule');
      final totalProduction = prefs.getInt('totalWeeklyProduction');
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        setState(() {
          weeklySchedule = jsonList.map((json) => json.toString()).toList();
          totalWeeklyProduction = totalProduction ?? 0;
          production = totalWeeklyProduction.toString();
        });
      }
    } catch (e) {
      print('Error loading weekly schedule from storage: $e');
    }
  }

  int unaffectedWeeklyProductionTotal = 0;
  void calculateWeeklyProduction() {
    weeklyProductionTotal = 0;
    for (String scheduleEntry in weeklySchedule) {
      final productionNumber = int.tryParse(scheduleEntry.split(': ')[1]) ?? 0;
      weeklyProductionTotal += productionNumber;
    }
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
            CupertinoTextField(
              onEditingComplete: () {
                addNote();
              },
              decoration: BoxDecoration(
                // color: CupertinoColors.extraLightBackgroundGray,
                borderRadius: BorderRadius.circular(10),
              ),
              controller: productionController,
              autocorrect: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                addNote();
              },
              placeholder: "....ادخل كمية الأنتاخ هنا",
              // maxLength: 10,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFamily: "myfont",
                color: Color.fromARGB(255, 0, 0, 0), // Set the color to white
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // print(widget.day);
                updateDataAndCheckInternet();
                saveWeeklyProductionToDatabase();
                saveWeeklyScheduleToStorage();
                // save_prod_in();
                setState(() {
                  String updatedProduction = productionController.text;
                  Navigator.pop(context, updatedProduction);
                  print(updatedProduction);
                  total_in += int.parse(updatedProduction);
                });
                final firestore = FirebaseFirestore.instance;
                SharedPreferences prefs = await SharedPreferences.getInstance();

                await prefs.setInt('total_in', total_in);
                // Save the unaffected weekly production total in a new collection in the database
                await firestore.collection('total_in').doc('total').set({
                  'productionTotal': total_in,
                });
                print(total_in);
              },
              child: const Text(
                'تعديل',
                style: TextStyle(fontFamily: "myfont", fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  Note note = notes[index];
                  return ListTile(
                    title: Text(
                      textAlign: TextAlign.end,
                      note.title,
                      style: const TextStyle(fontFamily: "myfont"),
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          deleteNote(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            CupertinoTextField(
              onEditingComplete: () {
                addNote();
              },
              decoration: BoxDecoration(
                // color: CupertinoColors.extraLightBackgroundGray,
                borderRadius: BorderRadius.circular(10),
              ),
              controller: noteController,
              autocorrect: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                addNote();
              },
              placeholder: ".... ادخل اسماء العمال هنا ",
              // maxLength: 10,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFamily: "myfont",
                color: Color.fromARGB(255, 0, 0, 0), // Set the color to white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
