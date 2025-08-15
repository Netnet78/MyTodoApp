import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A card that displays information about a specific task.
/// Use [onNormalTap] to handle the trailing icon press (e.g., navigate or edit).
/// There are two states: ["normal"] & ["editing"]
class TaskCardWidget extends StatefulWidget {
  const TaskCardWidget({
    super.key,
    this.taskTitle = 'Task title',
    this.taskDesc = 'Task description',
    this.onNormalTap,
    this.onCardTap,
    this.cardColor,
    this.state = "normal", // Can be 'normal' or 'editing'
    required this.onDeleteTap,
  });

  /// Title of the task
  final String taskTitle;

  /// Short task description
  final String taskDesc;

  /// Called when the trailing action is pressed
  final VoidCallback? onNormalTap;

  final VoidCallback? onCardTap;

  final Color? cardColor;

  final String state;
  
  final VoidCallback onDeleteTap;

  @override
  State<TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<TaskCardWidget> {
  late bool isNormalState;

  @override
  void initState() {
    super.initState();
    isNormalState = widget.state == "normal";
  }

  @override
  Widget build(BuildContext context) {
    isNormalState = widget.state == "normal";
    final theme = Theme.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;

    // Base text styles using GoogleFonts.inter (can be tuned)
    final titleStyle = GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.primary
    );

    final descStyle = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: theme.colorScheme.secondary,
    );

    return Align(
      alignment: Alignment.center,
      child: SafeArea(
        child: GestureDetector(
          onTap: widget.onCardTap,
          child: Container(
            width: cardWidth,
            height: 100,
            constraints: BoxConstraints(
              minWidth: 50,
              minHeight: 80,
              maxWidth: cardWidth,
              maxHeight: 100,
            ),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: BoxBorder.all(color: theme.dividerColor, width: 1.8),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 4,
                  color: Color.fromARGB(79, 33, 33, 33),
                  offset: Offset(3, 4),
                ),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Title + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        widget.taskTitle,
                        style: titleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
          
                      const SizedBox(height: 6),
          
                      // Description
                      Text(
                        widget.taskDesc,
                        style: descStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
          
                const SizedBox(width: 12),
          
                // Trailing action button
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Material(
                    color: isNormalState ? theme.primaryColor : Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: isNormalState ? widget.onNormalTap : widget.onDeleteTap,
                      child: Icon(
                        isNormalState ? Icons.arrow_forward : Icons.delete,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
