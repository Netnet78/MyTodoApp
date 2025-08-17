import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do_app/viewmodels/viewmodels.dart';
import 'package:to_do_app/data/models/task_model.dart';
import '../core/utils/utils.dart';

/// Create the task sheet section 
/// where it's being shown after 
/// clicking the arrow at the end of each tasks
Future<Task?> showTaskInfo(BuildContext context, Task task) async {
  // Responsive styles variables
  final theme = Theme.of(context);
  final sheetHeight = MediaQuery.of(context).size.height * 0.9;
  final sheetWidth = MediaQuery.of(context).size.width * 0.8;
  const double boxRadius = 24.0;

  // Controllers for input fields
  final TextEditingController titleController = TextEditingController(
    text: task.title
  );
  final TextEditingController descController = TextEditingController(
    text: task.description ?? ""
  );
  String currentStatus = task.isCompleted ? "Completed" : "Pending"; 
  int taskImportance = task.importance;

  // Helper variables
  List<String> importanceLevels = [
      "Least concerned", "Minor", "Normal", "Important", "Critical"
    ];

  return await showModalBottomSheet<Task?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    sheetAnimationStyle: const AnimationStyle(
        curve: Curves.easeInOut, 
        duration: Duration(milliseconds: 600)
      ),
    builder: (context) {
      // ignore: prefer_const_constructors
      return StatefulBuilder(
        builder: (context, setState) {
          return Center(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: sheetHeight,
                  width: sheetWidth,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(boxRadius)),
                    color: theme.cardColor,
                    border: Border.all(
                      color: theme.dividerColor,
                      width: 2.5,
                    )
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CustomPaint(
                    painter: GridBackgroundPainter(
                      gridSize: 25,
                      lineColor: const Color.fromARGB(75, 158, 158, 158),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 18.0, top: 50.0, right: 18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 1,
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              labelText: "✏️ Title",
                            ),
                            controller: titleController,
                          ),
                          const SizedBox(height: 21, width: 1,),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: "📃 Description",
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            controller: descController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 6,
                          ),
                          const SizedBox(height: 21, width: 1,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("📊 Status"),
                              DropdownButton<String>(
                                value: currentStatus,
                                isExpanded: true,
                                items: ["Pending","Completed"].map((status) => DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status),
                                )).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    currentStatus = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          Wrap(
                            alignment: WrapAlignment.start, // center items horizontally
                            spacing: 16, // space between items
                            runSpacing: 8, // space between rows if they wrap
                            children: List.generate(5, (index) {
                              final value = index + 1;
                              return Row(
                                mainAxisSize: MainAxisSize.min, // don’t stretch full width
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Radio<int>(
                                    value: value,
                                    groupValue: taskImportance,
                                    onChanged: (value) {
                                      setState(() {
                                        taskImportance = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                    importanceLevels[index],
                                    style: GoogleFonts.inter().copyWith(fontSize: 12),
                                  ),
                                ],
                              );
                            }),
                          ),
                          // Save button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                            ),
                            onPressed: () {
                              bool isCompleted = currentStatus == "Completed";
                              Task updatedTask = Task(
                                id: task.id,
                                title: titleController.text,
                                description: descController.text,
                                isCompleted: isCompleted,
                                importance: taskImportance,
                              );
                              Navigator.pop(context, updatedTask);
                            },
                            child: Text(
                              "Save changes",
                              style: GoogleFonts.inter().copyWith(
                                color: Colors.white
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                // "Go back" button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(sheetWidth,0),
                    backgroundColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.directional(
                        topStart: Radius.circular(boxRadius),
                        topEnd: Radius.circular(boxRadius),
                      ),
                    )
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 12,
                    children: [
                      const Icon(Icons.arrow_back, color: Colors.white,),
                      Text("Go back", style: GoogleFonts.inter().copyWith(
                        color: Colors.white
                      ),),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
        }
      );
    },
  );
}
