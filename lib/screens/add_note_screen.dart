import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_todo_app/database/database.dart';
import 'package:my_todo_app/models/note_model.dart';
import 'package:my_todo_app/screens/home_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AddNoteScreen extends StatefulWidget {


  final Note? note;
  final Function? updateNoteList;

  AddNoteScreen({this.note, this.updateNoteList});

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {

final _formKey = GlobalKey<FormState>();
String _title = '';
String _priority = 'Low';
DateTime _date = DateTime.now();
String btnAdd =  "Add Note";
String titleText = "Add Note";

TextEditingController _dateController = TextEditingController();
final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
final List<String> _priorities = ['High', 'Medium','Low'];

@override
void initState(){
  super.initState();

  if(widget.note != null){
    _title = widget.note!.title!;
    _date = widget.note!.date!;
    _priority = widget.note!.priority!;

    setState(() {
      btnAdd ="Update Note";
      titleText = "Update Note";
    });
  }
  else{
    setState(() {
      btnAdd ="Add Note";
      titleText = "Add Note";
    });
  }
  _dateController.text = _dateFormatter.format(_date);
}

@override
  void dispose(){
  _dateController.dispose();
  super.dispose();
}

_handleDataPicker() async{
  final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2120)
  );


  if(date != null && date != _date){
    setState(() {
      _date = date;
    });
    _dateController.text = _dateFormatter.format(date);

  }
}
 _deleteNote(){
      DatabaseHelper.instance.deleteNote(widget.note!.id!);
      Navigator.pushReplacement(context,
        MaterialPageRoute(
        builder: (_)=> HomeScreen(),
        ),
      );
      widget.updateNoteList!();
    }


_add(){
  if(_formKey.currentState!.validate()){
    _formKey.currentState!.save();
    print('$_title, $_date, $_priority');
    Note note = Note(
      title: _title,
      date: _date,
      priority: _priority,
    );
    if(widget.note ==null){
      note.status = 0;
      DatabaseHelper.instance.addNote(note);
      Navigator.pushReplacement(context,
        MaterialPageRoute(
          builder: (_)=> HomeScreen(),
        ),
      );
    }

    else{
      note.id = widget.note!.id;
      note.status = widget.note!.status;
      DatabaseHelper.instance.updateNote(note);

      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (_)=> HomeScreen(),
          ),
      );
    }
    widget.updateNoteList!();
  }
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Manage Notes'),
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 60.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(),)),
                  child: Icon(
                      Icons.arrow_back,
                    size: 25.0,
                    color: Theme.of(context).primaryColor,
                  ),
                  ),

                SizedBox(height: 15.0,),
                Text(
                  titleText,
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10.0,),
                Form(key: _formKey,
                  child: Column(
                    children: <Widget> [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: TextFormField(style: TextStyle(fontSize: 15.0),
                          decoration: InputDecoration(labelText: 'Add Note',
                            labelStyle: TextStyle(fontSize: 15.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),

                          validator: (input) => input!.trim().isEmpty ?'Please enter note title':null,
                          onSaved: (input) => _title =input!,
                          initialValue: _title,
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          style: TextStyle(fontSize: 15.0),
                          onTap: _handleDataPicker,
                          decoration: InputDecoration(labelText: 'Date',
                            labelStyle: TextStyle(fontSize: 15.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: DropdownButtonFormField(
                          isDense: true,
                          icon: Icon(Icons.arrow_drop_down_circle),
                          iconSize: 20.0,
                          iconEnabledColor: Theme.of(context).primaryColor,
                          items: _priorities.map((String priority){
                            return DropdownMenuItem(
                              value: priority,
                                child: Text(
                                priority,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                  ),
                                ),
                            );

                          }).toList(),

                          style: TextStyle(fontSize: 15.0),
                          decoration: InputDecoration(labelText: 'Priority',
                            labelStyle: TextStyle(fontSize: 15.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          validator: (input) => _priority == null ?'Please select priority type' : null,
                          onChanged: (value){setState((){
                              _priority = value.toString();
                            });
                          },
                          value: _priority,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15.0),
                        height: 50.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ElevatedButton(
                          child: Text(btnAdd,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                          onPressed: _add,
                        ),
                      ),

                      widget.note != null? Container(margin: EdgeInsets.symmetric(vertical: 15.0),
                        height: 50.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ElevatedButton(
                          child: Text('Delete Note',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                          onPressed: _deleteNote,
                        ),
                      ): SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
