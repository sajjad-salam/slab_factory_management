import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<String> notes = [];

  TextEditingController noteController = TextEditingController();

  void addNote() {
    String newNote = noteController.text;
    if (newNote.isNotEmpty) {
      setState(() {
        notes.add(newNote);
        noteController.clear();
      });
    }
  }

  MaterialStateProperty<Color?> amberColor =
      MaterialStateProperty.all<Color?>(Color.fromARGB(255, 105, 63, 0));
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  String note = notes[index];
                  return ListTile(
                    title: Text(
                      textAlign: TextAlign.end,
                      note,
                      style: TextStyle(fontFamily: "myfont"),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'اكتب الملاحضة هنا ',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ButtonStyle(backgroundColor: amberColor),
              onPressed: () {
                addNote();
              },
              child: const Text('اضافة ملاحضة'),
            ),
          ],
        ),
      ),
    );
  }
}
