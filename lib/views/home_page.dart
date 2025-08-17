import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app/components/components.dart';
import 'package:to_do_app/data/models/task_model.dart';
import 'package:to_do_app/viewmodels/viewmodels.dart';
import 'package:to_do_app/views/edit_task_form.dart';

class HomePageWidget extends ConsumerStatefulWidget {
  const HomePageWidget({super.key});

  @override
  ConsumerState<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends ConsumerState<HomePageWidget> {
  bool _isEditModeEnabled = false;
  bool _isDarkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    // Load tasks on widget init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskViewmodelProvider.notifier).get();
    });
    _loadSettings();
  }

  @override dispose() {
    super.dispose();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkModeEnabled = prefs.getBool('darkMode') ?? false;
    });  
  }

  Future<bool> showMessageBox(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        if (Platform.isIOS) {
          // iOS style
          return IOSMessageBox(
            title: "Delete task",
            subtitle: "Are you sure you want to delete this task?",
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Delete"),
              ),
            ],
          );
        } else {
          // Android/Web/Windows/Linux
          return NativeMessageBox(
            title: "Delete task",
            subtitle: "Are you sure you want to delete this task?",
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Delete"),
              ),
            ],
          );
        }
      },
    ) ?? false; // Return false if dismissed
  }

  Future<String?> showEditAndDeleteOptions(BuildContext context, Task task) async {
    final theme = Theme.of(context);
    final sheetHeight = MediaQuery.of(context).size.height * 0.35;
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
          curve: Curves.easeInOut, 
          duration: Duration(milliseconds: 600)
        ),
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: sheetHeight,
            width: MediaQuery.of(context).size.width * 1,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    task.title, 
                    style: GoogleFonts.inter().copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 350
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 20,
                    children: [
                      // Gesture detector for edit card
                      GestureDetector(
                        onTap: () => Navigator.pop(context, "edit"),
                        child: MyCard(  
                          backgroundColor: theme.cardColor,
                          width: double.infinity,
                          height: 78,
                          borderColor: theme.dividerColor,
                          borderRadius: 12.5,
                          child: Container(
                            padding: const EdgeInsets.only(left: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 12,
                                children: [
                                  MyCardLabel(
                                      title: "Edit this task", 
                                      subtitle: "Edit and save changes!",
                                      icon: Icons.edit,
                                      textColor: theme.colorScheme.primary,
                                      iconColor: theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Gesture detector for delete card
                      GestureDetector(
                        onTap: () => Navigator.pop(context, "delete"),
                        child: MyCard(
                          backgroundColor: Colors.red,
                          width: double.infinity,
                          height: 78,
                          borderColor: theme.dividerColor,
                          borderRadius: 12.5,
                          child: Container(
                            padding: const EdgeInsets.only(left: 12),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 12,
                                children: [
                                  MyCardLabel(
                                      title: "Delete this task", 
                                      subtitle: "Delete this task from the list!",
                                      icon: Icons.delete,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ), 
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskViewmodelProvider);
    final vm = ref.read(taskViewmodelProvider.notifier);

    return Scaffold(
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: [
                  Image.asset(
                  _isDarkModeEnabled ? 
                  "assets/images/icons/note-sleeping-dark.png" :
                  "assets/images/icons/note-sleeping.png",
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const Text("No tasks available right now.\nCreate one?", textAlign: TextAlign.center,),
                ],
              )
            )
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: TaskCardWidget(
                    state: _isEditModeEnabled ? "editing" : "normal",
                    taskTitle: task.title,
                    taskDesc: task.description.toString(),
                    onNormalTap: () {
                      log("Pressed 'show more' task ${task.id}");
                    },
                    onCardTap: () async {
                      log("Pressed the card widget for task ${task.id}");
                      String? choice = await showEditAndDeleteOptions(context, task);

                      if (choice == "delete" && context.mounted) {
                        bool confirmed = await showMessageBox(context);
                        if (confirmed == true) {
                          _deleteTask(vm, task);
                        }
                      } else if (choice == "edit" && context.mounted) {
                        Task? updatedTask = await showTaskInfo(context, task);
                        if (updatedTask != null) {
                          await vm.update(updatedTask);
                          ref.watch(taskViewmodelProvider.notifier).refresh();
                        }
                      }
                    },
                    onDeleteTap: () async {
                      log("Pressed delete task ${task.id}");
                      bool confirmed = await showMessageBox(context);
                      if (confirmed == true) {
                        _deleteTask(vm, task);
                      } else {
                        log("Cancelled the deletion of the task");
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: (!kIsWeb && !(Platform.isAndroid || Platform.isIOS)) ? FABDeleteTaskButton(
        onPressed: () {
          setState(() {
            _isEditModeEnabled = !_isEditModeEnabled;
          });
          if (!_isEditModeEnabled) {
            log("Toggled the delete task button");
          }
          log("Untoggled the delete task button!");
        },
      ) : null
    );
  }

  void _deleteTask(TaskViewmodel vm, Task task) {
    vm.delete(task.id!.toInt());
    ref.watch(taskViewmodelProvider.notifier).refresh();
    log("Deleted the task!");
  }
}

class MyCardLabel extends StatelessWidget {
  const MyCardLabel({
    super.key,
    this.title = "",
    this.subtitle = "",
    this.icon = Icons.abc,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color textColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Icon(icon, color: iconColor,),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 0,
          children: [
            Text(title, style: GoogleFonts.inter().copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
            textAlign: TextAlign.left,),
            Text(subtitle, style: GoogleFonts.inter().copyWith(
              fontWeight: FontWeight.normal,
              fontSize:12,
              color: textColor,
            ),
            textAlign: TextAlign.left,)
          ],
        ),
      ],
    );
  }
}

class FABDeleteTaskButton extends StatefulWidget {
  const FABDeleteTaskButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  State<FABDeleteTaskButton> createState() => _FABDeleteTaskButtonState();
}

class _FABDeleteTaskButtonState extends State<FABDeleteTaskButton> {
  bool isHovering = false;
  bool deleteToggle = false;
  
  void _setIsHoveringTo(bool value) {
    setState(() {
      isHovering = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onHover:(event) => _setIsHoveringTo(true),
      onExit:(event) => _setIsHoveringTo(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: deleteToggle ? Colors.red : isHovering ? Colors.red : Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              blurRadius: 2,
              offset: Offset(2, 4),
              color: Colors.black26
            )
          ]
        ),
        child: IconButton(
            icon: Icon(
                deleteToggle ? Icons.close : Icons.delete, 
                color: deleteToggle ? Colors.white : isHovering ? Colors.white : theme.primaryColor,
              ),
            padding: const EdgeInsets.all(20),
            onPressed: () {
              widget.onPressed();
              setState(() {
                deleteToggle = !deleteToggle;
              });
            },
          ),
      ),
    );
  }
}
