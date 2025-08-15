import 'package:to_do_app/data/models/models.dart';
import 'package:to_do_app/data/repositories/repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTaskState {
  final String title;
  final String description;
  final int importance;

  AddTaskState({
    this.title = "",
    this.description = "",
    this.importance = 2,
  });

  AddTaskState copyWith({
    String? title,
    String? description,
    int? importance,
  }) {
    return AddTaskState(
      title: title ?? this.title,
      description: description ?? this.description,
      importance: importance ?? this.importance,
    );
  }
}

class AddTaskViewmodel extends StateNotifier<AddTaskState> {
  final TaskRepository _repo;

  AddTaskViewmodel(this._repo) : super(AddTaskState());

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value);
  }

  void setImportance(int value) {
    state = state.copyWith(importance: value);
  }

  Future<void> saveTask() async {
    if (state.title.isEmpty) return;

    await _repo.addTask(Task(
      title: state.title,
      description: state.description,
      importance: state.importance,
    ));

    // Reset the form after saving
    state = AddTaskState(importance: 2);
  }
}


final addTaskViewmodelProvider = StateNotifierProvider<AddTaskViewmodel, AddTaskState>((ref) {
  final repo = ref.read(taskRepositoryProvider);
  return AddTaskViewmodel(repo);
});
