import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_app/data/models/models.dart';
import 'package:to_do_app/data/repositories/repositories.dart';

class TaskViewmodel extends StateNotifier<List<Task>> {
  final TaskRepository repo;

  TaskViewmodel(this.repo): super([]);

  Future<void> get() async {
    final tasks = await repo.getTasks();
    state = tasks;
  }

  Future<void> add(Task task) async {
    await repo.addTask(task);
    await get();
  }

  Future<void> delete(int id) async {
    await repo.deleteTask(id);
    await get();
  }

  Future<void> update(Task task) async {
    await repo.updateTask(task);
    await get();
  }

  Future<void> refresh() => get();
}

// Riverpod provider
final taskViewmodelProvider = StateNotifierProvider<TaskViewmodel, List<Task>>((ref) {
  final repo = ref.read(taskRepositoryProvider);
  return TaskViewmodel(repo);
});
