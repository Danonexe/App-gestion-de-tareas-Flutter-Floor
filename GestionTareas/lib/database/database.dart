// database.dart
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:gestiontareas/daos/task_dao.dart';
import 'package:gestiontareas/database/database.dart';
import 'package:gestiontareas/models/Tarea.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';


part 'database.g.dart'; // Esta parte será generada automáticamente

@Database(version: 1, entities: [Task])
abstract class AppDatabase extends FloorDatabase {
  TaskDao get taskDao;

  static Future<AppDatabase> getInstance() async {
    return await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  }
}