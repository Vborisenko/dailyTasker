import 'package:flutter/material.dart';
import '../models/sub_task.dart';

class SubtaskListWidget extends StatelessWidget {
  final List<SubTask> subtasks;
  final Function(int subtaskId, bool isCompleted)? onSubtaskStatusChanged;
  final Function(int index, bool isCompleted)? onSubtaskStatusChangedByIndex;
  final Function(int oldIndex, int newIndex)? onReorder;
  final Function(int index)? onEditSubtask;
  final Function(int index)? onDeleteSubtask;
  final bool showDragHandle;
  final bool showDeleteButton;
  final bool showEditButton;
  final bool isReorderable;
  final String? emptyMessage;
  final EdgeInsets? itemPadding;
  final double? itemSpacing;

  const SubtaskListWidget({
    super.key,
    required this.subtasks,
    this.onSubtaskStatusChanged,
    this.onSubtaskStatusChangedByIndex,
    this.onReorder,
    this.onEditSubtask,
    this.onDeleteSubtask,
    this.showDragHandle = true,
    this.showDeleteButton = true,
    this.showEditButton = false,
    this.isReorderable = true,
    this.emptyMessage,
    this.itemPadding,
    this.itemSpacing,
  });

  @override
  Widget build(BuildContext context) {
    if (subtasks.isEmpty) {
      return Center(
        child: Text(
          emptyMessage ?? 'No subtasks available',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    if (isReorderable) {
      return ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: subtasks.length,
        onReorder: onReorder ?? (oldIndex, newIndex) {},
        itemBuilder: (context, index) {
          return _buildSubtaskItem(context, index);
        },
      );
    } else {
      return Column(
        children: List.generate(subtasks.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: itemSpacing ?? 2),
            child: _buildSubtaskItem(context, index),
          );
        }),
      );
    }
  }

  Widget _buildSubtaskItem(BuildContext context, int index) {
    final subtask = subtasks[index];
    
    return Card(
      key: ValueKey('subtask_${subtask.id}_${subtask.order}'),
      margin: itemPadding ?? const EdgeInsets.only(bottom: 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spread elements to edges
          children: [
            // Left side: drag handle and title
            Expanded(
              child: Row(
                children: [
                  // Drag handle (if enabled)
                  if (showDragHandle && isReorderable)
                    ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle, color: Colors.grey, size: 20),
                    ),
                  if (showDragHandle && isReorderable)
                    const SizedBox(width: 8),
                  // Title
                  Expanded(
                    child: GestureDetector(
                      onTap: showEditButton && onEditSubtask != null
                          ? () => onEditSubtask!(index)
                          : null,
                      child: Text(
                        subtask.title,
                        style: TextStyle(
                          decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                          color: subtask.isCompleted ? Colors.grey : Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Right side: controls (checkbox, edit, delete)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Round checkbox
                SizedBox(
                  width: 16,
                  height: 16,
                  child: Checkbox(
                    key: ValueKey('subtask_checkbox_${subtask.id}_$index'),
                    value: subtask.isCompleted,
                    onChanged: (value) {
                      if (onSubtaskStatusChangedByIndex != null) {
                        onSubtaskStatusChangedByIndex!(index, value ?? false);
                      } else if (onSubtaskStatusChanged != null) {
                        onSubtaskStatusChanged!(subtask.id, value ?? false);
                      }
                    },
                    activeColor: Colors.orange,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Make checkbox round
                    ),
                  ),
                ),
                // Edit button (if enabled)
                if (showEditButton && onEditSubtask != null) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue, size: 16),
                      onPressed: () => onEditSubtask!(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
                // Delete button (if enabled)
                if (showDeleteButton && onDeleteSubtask != null) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                      onPressed: () => onDeleteSubtask!(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
