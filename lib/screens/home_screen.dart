import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_todo_app/database/database.dart';
import 'package:my_todo_app/models/note_model.dart';
import 'add_note_screen.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late Future<List<Note>> _noteList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  void initState(){
    super.initState();
    _updateNoteList();
  }

  _updateNoteList(){
    _noteList = DatabaseHelper.instance.getNoteList();
  }

  Widget _myNote(Note note){
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
      children: [
        ListTile(
          title: Text(note.title!,style: TextStyle(
            fontSize: 15.0,
            color: Colors.indigo,
            decoration: note.status == 0
              ? TextDecoration.none
                : TextDecoration.lineThrough
          ),
          ),
          subtitle: Text('${_dateFormatter.format(note.date!)} - ${note.priority}',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.indigo,
                decoration: note.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough
            ),
          ),
          trailing: Checkbox(onChanged: (value){
              note.status = value! ? 1 : 0;
              DatabaseHelper.instance.updateNote(note);
              _updateNoteList();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          },
            activeColor: Theme.of(context).primaryColor,
            value: note.status  == 1? true : false,

        ),


          onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => AddNoteScreen(
            updateNoteList: _updateNoteList(),
            note: note,
          ),
          ),
          ),
      ),
        Divider(
          height: 5.0,
          color: Colors.indigo.shade200,
          thickness: 3.0,
        ),
      ],
      ),
    );
  }

  Icon custIcon = Icon(Icons.search);
  Widget custSearchBar = Text("Search");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: custSearchBar,
        actions: <Widget>[

          IconButton(
              onPressed: (){
                setState(() {
                  if(this.custIcon.icon == Icons.search){
                    this.custIcon = Icon(Icons.cancel);
                    this.custSearchBar = TextField(
                      textInputAction: TextInputAction.go,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter search keyword",
                        hintStyle: TextStyle(
                        color: Colors.grey,
                          fontSize: 18.0,),
                      ),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20.0,
                      ),
                    );
                  }
                  else{
                    this.custIcon = Icon(Icons.search);
                    this.custSearchBar = Text("Search");
                  }
                });
              },

              icon: custIcon,
          ),
        ],
      ),

      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: (){
          Navigator.push(context,
              CupertinoPageRoute(builder:(_)=> AddNoteScreen(
                updateNoteList: _updateNoteList(),
              ),
              ),
          );
          },
        child: Icon(Icons.add),
      ),

      body: FutureBuilder(
          future: _noteList,
          builder: (context, AsyncSnapshot snapshot) {
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
         final int completedNoteCount =
             snapshot.data!.where((Note note) => note.status ==1).toList().length;

        return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 70.0),
            itemCount: int.parse(snapshot.data!.length.toString()) +1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'My Notes',
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15.0,),
                      Text(
                        '$completedNoteCount of ${snapshot.data.length}',
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),),
                    ],),
                );
              }
              return _myNote(snapshot.data![index - 1]);
            }
        );
        }
      ),
    );
  }
}
