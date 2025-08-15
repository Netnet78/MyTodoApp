import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_app/data/db/database.dart';
import 'package:to_do_app/data/models/models.dart';

class TaskRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> addTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});