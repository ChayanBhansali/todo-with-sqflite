import 'package:cc_todo/screens/notedetail.dart';
import 'package:flutter/material.dart';
import 'package:cc_todo/database.dart';
import 'package:cc_todo/model/note.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  int count = 0;
  DatabaseHelper databaseHelper = DatabaseHelper();
  late List<Note> noteList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note List'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('fab clicked');
          navigateToDetail(Note('', '', 2 ,''),'Add Note');
        },
        child: Icon(Icons.add),
      ),
    );
  }
  ListView getNoteListView(){
  return ListView.builder(
      itemCount: count,
      itemBuilder: (context, index){
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getPriorityColor(this.noteList[index].priority),
                child: getPriorityIcon(this.noteList[index].priority),
              ),
            title: Text(this.noteList[index].title!,),
            subtitle: Text(this.noteList[index].date!),
            trailing: IconButton(onPressed: (){
              _delete(context, noteList[index]);
            },
            icon: Icon(Icons.delete),

            ),
            onTap: (){
                debugPrint('tapped');
                navigateToDetail(noteList[index],'Edit Note');

            },
          ),
        );
      }


  );

  }
  void navigateToDetail(Note note, String title) async{
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(appBarTitle: Title, note: note);
    }));
    if (result == true) {
      updateListView();
    }
  }
  // Returns the priority color
  Color getPriorityColor(int? priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
    }
  }
  // Returns the priority icon
  Icon getPriorityIcon(int? priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {

    int? result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {

    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }


  void updateListView() {

    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {

      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
