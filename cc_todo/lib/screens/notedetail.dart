import 'package:cc_todo/model/note.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database.dart';
class NoteDetail extends StatefulWidget {
  final Note note;
  final appBarTitle;
  NoteDetail( {Key? key,required this.appBarTitle, required this.note}) : super(key: key);
  @override
  _NoteDetailState createState() => _NoteDetailState(this.note, this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];
  DatabaseHelper helper = DatabaseHelper();
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  String appBarTitle;

  Note note;
  _NoteDetailState(this.note , this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    titleController.text = note.title!;
    descController.text = note.description!;
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: [
            ListTile(
              title: DropdownButton(
                  items: _priorities.map((dropDownStringItem) {
                    return DropdownMenuItem (
                    value: dropDownStringItem,
                    child: Text(dropDownStringItem),
                    );
                    }).toList(),
                  value: getPriorityAsString(note.priority),
                      onChanged: (valueSelectedByUser) {
                        setState(() {
                          debugPrint('User selected $valueSelectedByUser');
                          updatePriorityAsInt(valueSelectedByUser);
                        });
                      }
                  ),
                  ),
            SizedBox(height: 10,),
            Container(
              child: TextField(
                controller: titleController,
                onChanged: (value) {
                  debugPrint('something changed in the title textfield ');
                  updateTitle();
                },
                decoration:   InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )
                ),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              child: TextField(
                controller: descController,
                onChanged: (value) {
                  debugPrint('something changed in the description textfield ');
                  updateDescription();
                },
                decoration:   InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 50,
                    padding: EdgeInsets.all(5),
                    child: ElevatedButton(onPressed: (){
                      debugPrint('add button clicked');
                      _save();
                    }, child: Text('Save',
                    style: TextStyle(
                      fontSize: 18
                    ),
                    )
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 50,
                    padding: EdgeInsets.all(5),

                    child: ElevatedButton(onPressed: (){
                      _delete();
                      debugPrint('Delete button clicked');
                    }, child: Text('Delete',
                      style: TextStyle(
                          fontSize: 18
                      ),)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int? value) {
    String priority = '';
    switch (value) {
      case 1:
        priority = _priorities[0];  // 'High'
        break;
      case 2:
        priority = _priorities[1];  // 'Low'
        break;
    }
    return priority;
  }
  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(var value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }
  // Update the title of Note object
  void updateTitle(){
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descController.text;
  }
  void _delete() async {

    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int? result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }
  void moveToLastScreen() {
    Navigator.pop(context, true);
  }
  void _showAlertDialog(String title, String message) {

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }
  // Save data to database
  void _save() async {

    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int? result;
    if (note.id != null) {  // Case 1: Update operation
      result = await helper.updateNote(note);
    } else { // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {  // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {  // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }

  }
}
