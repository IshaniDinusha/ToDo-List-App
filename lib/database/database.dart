import 'dart:io';
import 'package:my_todo_app/models/note_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
class DatabaseHelper{
  static final DatabaseHelper instance = DatabaseHelper._instance();

  static Database? _database = null;

  DatabaseHelper._instance();
  String noteTable ='note_table';
  String cId= 'id';
  String cTitle= 'title';
  String cDate= 'date';
  String cPriority= 'priority';
  String cStatus= 'status';

  Future<Database?> get database async{
    if(_database == null){
      _database = await _initDb();
    }
    return _database;
  }

  Future<Database> _initDb() async{
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'my_todo_app.db';
    final myToDoAppDB = await openDatabase(
      path,version: 1, onCreate: _createDb
    );
     return myToDoAppDB;
  }

  void _createDb(Database database, int version) async{
    await database.execute(
      'CREATE TABLE $noteTable($cId INTEGER PRIMARY KEY AUTOINCREMENT, '
          '$cTitle TEXT,$cDate TEXT, $cPriority TEXT, $cStatus INTEGER)'
    );
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async{
    Database? database = await this.database;
    final List<Map<String, dynamic>> result = await database!.query(noteTable);
    return result;
  }

  Future<List<Note>> getNoteList() async{
    final List<Map<String, dynamic>> noteMapList = await getNoteMapList();
    final List<Note> noteList = [];

    noteMapList.forEach((noteMap){
      noteList.add(Note.fromMap(noteMap));
    });

    noteList.sort((noteOne, noteTwo) => noteOne.date!.compareTo(noteTwo.date!));
    return noteList;
  }
Future<int> addNote(Note note) async{
    Database? database = await this.database;
    final int result = await database!.insert(
      noteTable,
      note.toMap(),
    );
    return result;
  }
  Future<int> updateNote(Note note) async{
    Database? database = await this.database;
    final int result = await database!.update(
      noteTable,
      note.toMap(),
      where: '$cId = ?',
      whereArgs: [note.id],
    );
    return result;
  }


  Future<int> deleteNote(int id) async{
    Database? database = await this.database;
    final int result = await database!.delete(
      noteTable,
      where: '$cId = ?',
      whereArgs: [id],
    );
    return result;
  }

}

