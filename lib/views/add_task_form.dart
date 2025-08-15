import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_app/core/utils/utils.dart';
import 'package:to_do_app/viewmodels/viewmodels.dart';
import 'package:to_do_app/components/components.dart';

class AddTaskFormWidget extends ConsumerStatefulWidget {
  const AddTaskFormWidget({super.key});

  static const List<String> importanceLevels = [
    "Least concerned", "Minor", "Normal", "Important", "Critical"
  ];

  @override
  ConsumerState<AddTaskFormWidget> createState() => _AddTaskFormWidgetState();
}

class _AddTaskFormWidgetState extends ConsumerState<AddTaskFormWidget> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();

    final addTaskState = ref.read(addTaskViewmodelProvider);
    _titleController = TextEditingController(text: addTaskState.title);
    _descController = TextEditingController(text: addTaskState.description);

    // When controller changes, update Riverpod state
    _titleController.addListener(() {
      ref.read(addTaskViewmodelProvider.notifier).setTitle(_titleController.text);
    });

    _descController.addListener(() {
      ref.read(addTaskViewmodelProvider.notifier).setDescription(_descController.text);
    });

    // Listen to Riverpod state changes and update controllers if needed
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    ref.listen<AddTaskState>(addTaskViewmodelProvider, (previous, next) {
      // Update controllers only if different to avoid loops
      if (next.title != _titleController.text) {
        _titleController.text = next.title;
      }
      if (next.description != _descController.text) {
        _descController.text = next.description;
      }
    });

    final addTaskState = ref.watch(addTaskViewmodelProvider);
    final addTaskVm = ref.read(addTaskViewmodelProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CustomPaint(
        painter: GridBackgroundPainter(
          gridSize: 25,
          lineColor: const Color.fromARGB(75, 158, 158, 158),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: ((!kIsWeb && !(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) ?
                  EdgeInsets.only(
                    top: 60,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 80,
                  ) : EdgeInsets.only(
                    top: 60,
                    bottom: MediaQuery.of(context).size.height
                  )
                ),
                child: Center(
                  child: MyCard(
                    width: 300,
                    height: 560,
                    borderColor: theme.dividerColor,
                    borderRadius: 12,
                    borderWidth: 2,
                    boxShadowColor: const Color.fromARGB(167, 0, 0, 0),
                    boxShadowOffsetX: 2,
                    boxShadowOffsetY: 4,
                    backgroundColor: theme.cardColor,
                    padding: 20.0,
                    child: Form(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 20,
                        children: [
                          Row(
                            spacing: 20,
                            children: [
                              const Icon(Icons.add_task),
                              Text(
                                "Add a new task",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          MyTextField(
                            icon: Icons.list_alt,
                            text: "Title of the task",
                            onChanged: addTaskVm.setTitle,
                            controller: _titleController,
                          ),
                          MyTextField(
                            text: "Description",
                            icon: Icons.description_rounded,
                            onChanged: addTaskVm.setDescription,
                            controller: _descController,
                          ),
                          Wrap(
                            children: [
                              ImportanceLevelLabel(theme: theme),
                              ImportanceLevelChoices(addTaskState: addTaskState, addTaskVm: addTaskVm),
                            ],
                          ),
                          SaveAndAddTaskButton(theme: theme, addTaskState: addTaskState, addTaskVm: addTaskVm, ref: ref),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 42,
                    semanticLabel: "Go back",
                  ),
                  onPressed: () {Navigator.pop(context, false);},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImportanceLevelLabel extends StatelessWidget {
  const ImportanceLevelLabel({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 2,
                color: theme.dividerColor,
              ),
            ),
          ),
          child: Text(
            "Importance of the task",
            style: GoogleFonts.inter(),
          ),
        ),
      ],
    );
  }
}

class ImportanceLevelChoices extends StatelessWidget {
  const ImportanceLevelChoices({
    super.key,
    required this.addTaskState,
    required this.addTaskVm,
  });

  final AddTaskState addTaskState;
  final AddTaskViewmodel addTaskVm;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2,
      children: List.generate(5, (index) {
        final value = index + 1;
        return Row(
          children: [
            Radio<int>(
              value: value,
              groupValue: addTaskState.importance,
              onChanged: (val) {
                if (val != null) {
                  addTaskVm.setImportance(val);
                }
              },
            ),
            Text(AddTaskFormWidget.importanceLevels[index]),
          ],
        );
      }),
    );
  }
}

class SaveAndAddTaskButton extends StatelessWidget {
  const SaveAndAddTaskButton({
    super.key,
    required this.theme,
    required this.addTaskState,
    required this.addTaskVm,
    required this.ref,
  });

  final ThemeData theme;
  final AddTaskState addTaskState;
  final AddTaskViewmodel addTaskVm;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        backgroundColor: theme.primaryColor,
      ),
      onPressed: () {
        if (addTaskState.title.isEmpty) {
          log("The user must enter the title!");
          return;
        }
        addTaskVm.saveTask();
        ref.watch(taskViewmodelProvider.notifier).refresh();
        Navigator.pop(context, true);
      },
      child: const Row(
        spacing: 5,
        children: [
          Icon(
            Icons.add,
            color: Colors.white,
          ),
          Text(
            "Add task",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
