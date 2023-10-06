// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String title;
  final String content;

  Note({required this.title, required this.content});
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> notes = [];
  double secondaryExpenses = 0.0;
  Future<void> saveSecondaryExpensesToFirestore(
      double secondaryExpenses) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Reference to a document where you want to store the secondary expenses
      DocumentReference expensesRef =
          firestore.collection('expenses').doc('secondary');

      // Update the secondary expenses in the Firestore document
      await expensesRef.set({
        'secondaryExpenses': secondaryExpenses,
      });

      print('Secondary expenses data saved to Firestore.');
    } catch (e) {
      print('Error saving secondary expenses data to Firestore: $e');
    }
  }

  Future<double> loadSecondaryExpensesFromFirestore() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference expensesCollection = firestore.collection('expenses');
      DocumentSnapshot doc = await expensesCollection.doc('secondary').get();

      if (doc.exists && doc.data() != null) {
        double secondaryExpensess = doc['secondaryExpenses'].toDouble();
        setState(() {
          secondaryExpenses = secondaryExpensess;
        });
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading secondary expenses: $e');
    }
    // Return a default value of 0.0 in case of an error or missing data
    return 0.0;
  }

  TextEditingController noteController = TextEditingController();
  void addNote() async {
    setState(
      () {
        _isLoading = true;
      },
    );
    String newNoteTitle = noteController.text;
    String newNoteContent = ''; // Add content here if needed
    if (newNoteTitle.isNotEmpty) {
      // Extract and accumulate numbers from the note's content
      final RegExp regex =
          RegExp(r'(\d+(\.\d+)?)'); // Regular expression to match numbers
      final Iterable<Match> matches = regex.allMatches(newNoteTitle);
      final List<double> numbers =
          matches.map((match) => double.parse(match.group(0)!)).toList();
      final double total =
          numbers.isNotEmpty ? numbers.reduce((a, b) => a + b) : 0.0;

      // Update secondaryExpenses
      secondaryExpenses += total;

      setState(() {
        notes.add(Note(title: newNoteTitle, content: newNoteContent));
        noteController.clear();
        _isLoading = false;
      });

      await saveNotes(notes.cast<Note>());
      print(secondaryExpenses);
    }
  }

  MaterialStateProperty<Color?> amberColor =
      MaterialStateProperty.all<Color?>(const Color.fromARGB(255, 105, 63, 0));
  Future<List<Note>> loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notesJson = prefs.getStringList('notes');
    return notesJson != null
        ? notesJson.map((noteJson) => noteFromJson(noteJson)).toList()
        : [];
  }

  void deleteNote(int index) {
    setState(() {
      Note deletedNote = notes.removeAt(index);
      deleteNoteFromStorage(
          deletedNote); // Call a function to delete the note from storage
    });
  }

  void deleteNoteFromStorage(Note note) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedNotes = prefs.getStringList('notes');

    if (storedNotes != null) {
      String noteJson = noteToJson(note);
      storedNotes.remove(noteJson);
      await prefs.setStringList('notes', storedNotes);
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesJson = notes.map((note) => noteToJson(note)).toList();
    await prefs.setStringList('notes', notesJson);
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

  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    loadSecondaryExpensesFromFirestore();
    loadNotes().then((loadedNotes) {
      setState(() {
        notes = loadedNotes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        previousPageTitle: "رجوع",
        middle: Text(
          "الملاحضات",
          style: TextStyle(fontFamily: "myfont", fontSize: 25),
        ),
      ),
      body: _isLoading
          ? const CircularProgressIndicator() // Display the loading indicator
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                    decoration: BoxDecoration(
                      // color: CupertinoColors.extraLightBackgroundGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    controller: noteController,
                    autocorrect: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      addNote();
                      saveSecondaryExpensesToFirestore(secondaryExpenses);
                    },
                    placeholder: ".... كتابة ملاحظة ",
                    // maxLength: 10,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontFamily: "myfont",
                      color: Color.fromARGB(
                          255, 0, 0, 0), // Set the color to white
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ButtonStyle(backgroundColor: amberColor),
                    onPressed: () {
                      addNote();
                    },
                    child: const Text(
                      'اضافة ملاحضة',
                      style: TextStyle(fontFamily: "myfont", fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
