import 'package:to_do_app/data/models/models.dart';
import 'package:to_do_app/data/repositories/repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditTaskState {
  final String title;
  final String? description;
  final int? importance;
  final bool? isCompleted;

  EditTaskState({
    this.title = "",
    this.description,
    this.importance,
    this.isCompleted, 
  });

  EditTaskState copyWith({
    String? title,
    String? description,
    int? importance,
    bool? isCompleted,
  }) {
    return EditTaskState(
      title: title ?? this.title,
      description: description ?? this.description,
      importance: importance ?? this.importance,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

}

class EditTaskViewmodel extends StateNotifier<EditTaskState> {
  final TaskRepository _repo;

  EditTaskViewmodel(this._repo) : super(EditTaskState());

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value);
  }

  void setImportance(int value) {
    state = state.copyWith(importance: value);
  }

  void setIsCompleted(bool value) {
    state = state.copyWith(isCompleted: value);
  }
}


final editTaskViewmodelProvider = StateNotifierProvider<EditTaskViewmodel, EditTaskState>((ref) {
  final repo = ref.read(taskRepositoryProvider);
  return EditTaskViewmodel(repo);
});
