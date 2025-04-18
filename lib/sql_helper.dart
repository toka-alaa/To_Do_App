import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'model.dart';

class SQLHelper
{
  static Database? database;

  static getDatabase() async {
    if (database != null) {
      return database;
    }
    database = await initDatabase();
    return database;
  }



   static initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
        version: 1,
        onCreate: (db, index) async {
        Batch batch = db.batch();
      batch.execute(
        '''
        CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
         title TEXT,
          description TEXT,
           createdAt TEXT,
            isCompleted INTEGER
            )
        ''');
      batch.commit();
      },
    );
  }

 Future addTask(newTask)async
  {
    Database db = await getDatabase();
    db.insert('tasks', newTask.toMap() ,
        conflictAlgorithm: ConflictAlgorithm.replace);

  }

  Future<List<Map>> loadTasks({String filter = 'All'}) async {
    Database db = await getDatabase();
    if (filter == 'Completed') {
      return await db.query('tasks', where: 'isCompleted = ?', whereArgs: [1]);
    } else if (filter == 'inCompleted') {
      return await db.query('tasks', where: 'isCompleted = ?', whereArgs: [0]);
    } else {
      return await db.query('tasks');
    }
  }


  Future editTask(Task task) async {
    final db = await getDatabase();
    return await db.update('tasks',
        task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }


  Future deleteTask(int id) async {
    Database db = await getDatabase();
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }


  Future deleteAll() async {
    Database db = await getDatabase();
    return await db.delete('tasks');
  }

  Future<List<Task>> getCompletedTasks() async {
    Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'isCompleted = ?',
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        createdAt: maps[i]['createdAt'],
        isCompleted: maps[i]['isCompleted'] == 1,
      );
    });
  }
}