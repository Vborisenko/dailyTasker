import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../models/sub_task.dart';
import '../widgets/subtask_list_widget.dart';
import 'create_task_screen.dart';
import 'edit_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final allTasks = taskProvider.tasks;
          final todayTasks = taskProvider.todayTasks;
          final stats = taskProvider.getTaskStatistics();
          
          // Debug information
          debugPrint('HomeScreen: All tasks count: ${allTasks.length}');
          debugPrint('HomeScreen: Today tasks count: ${todayTasks.length}');
          debugPrint('HomeScreen: Stats: $stats');
          debugPrint('HomeScreen: Task IDs: ${allTasks.map((t) => t.id).toList()}');
          
          if (allTasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first task to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Task statistics
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total', stats['total']!, Colors.blue),
                    _buildStatItem('Completed', stats['completed']!, Colors.green),
                    _buildStatItem('Pending', stats['pending']!, Colors.orange),
                  ],
                ),
              ),
              
              // All tasks
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8), // Set horizontal padding to 8px
                  itemCount: allTasks.length,
                  itemBuilder: (context, index) {
                    final task = allTasks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                                              child: Card(
                          margin: EdgeInsets.zero, // Remove card margins to use full width
                          child: Stack(
                          children: [
                          // Priority circle in top-right corner
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: task.priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          // Main content
                          GestureDetector(
                            onTap: () async {
                              // Navigate to edit task screen
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EditTaskScreen(task: task),
                                ),
                              );
                            },
                            onLongPress: () {
                              // Show edit options
                              _showEditOptions(context, task);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0, right: 0, top: 8, bottom: 8), // No horizontal padding to maximize space
                              child: Row(
                                children: [
                                  // Round checkbox on the left with minimal margin and smaller size
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: task.isCompleted,
                                      onChanged: (value) async {
                                        try {
                                          await taskProvider.toggleTaskCompletion(task.id);
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Error updating task: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      activeColor: Colors.orange,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce checkbox padding
                                      visualDensity: VisualDensity.compact, // Make checkbox more compact
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12), // Make checkbox round
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Task content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: TextStyle(
                                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                            color: task.isCompleted ? Colors.grey : Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (task.description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            task.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                        if (task.hasSubtasks) ...[
                                          const SizedBox(height: 8),
                                          GestureDetector(
                                            onTap: () {
                                              _showSubtasksDialog(context, task);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.orange.withValues(alpha: 0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '${task.completedSubtasksCount}/${task.totalSubtasksCount} subtasks',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.orange,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  const Icon(
                                                    Icons.expand_more,
                                                    size: 18,
                                                    color: Colors.orange,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Show all subtasks inline with drag&drop and status controls
                                          Padding(
                                            padding: const EdgeInsets.only(left: 0), // No left padding to move subtasks closer to left edge
                                            child: SubtaskListWidget(
                                              subtasks: task.subtasks,
                                              onSubtaskStatusChangedByIndex: (index, isCompleted) async {
                                                try {
                                                  await context.read<TaskProvider>().updateSubTaskCompletionByIndex(
                                                    task.id,
                                                    index,
                                                    isCompleted,
                                                  );
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Error updating subtask: $e'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              onReorder: (oldIndex, newIndex) async {
                                                try {
                                                  if (oldIndex < newIndex) {
                                                    newIndex -= 1;
                                                  }
                                                  
                                                  // Get sorted subtasks for reordering
                                                  final sortedSubtasks = List<SubTask>.from(task.subtasks)
                                                    ..sort((a, b) => a.order.compareTo(b.order));
                                                  
                                                  // Create a copy of subtasks for reordering
                                                  final updatedSubtasks = List<SubTask>.from(sortedSubtasks);
                                                  final item = updatedSubtasks.removeAt(oldIndex);
                                                  updatedSubtasks.insert(newIndex, item);
                                                  
                                                  // Update order values
                                                  for (int i = 0; i < updatedSubtasks.length; i++) {
                                                    updatedSubtasks[i] = updatedSubtasks[i].copyWith(order: i);
                                                  }
                                                  
                                                  // Update the task with new subtask order
                                                  final updatedTask = task.copyWith(subtasks: updatedSubtasks);
                                                  await context.read<TaskProvider>().updateTask(updatedTask);
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Error reordering subtasks: $e'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              showDragHandle: true,
                                              showDeleteButton: false,
                                              showEditButton: false,
                                              isReorderable: true,
                                              itemPadding: const EdgeInsets.only(left: 0, right: 0, bottom: 2), // No right padding to move checkbox to the right edge
                                              itemSpacing: 2,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "home_add_task_button",
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateTaskScreen(),
            ),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  void _showEditOptions(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Task', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditTaskScreen(task: task),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Task', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteConfirmation(context, task);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Task', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${task.title}"?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await context.read<TaskProvider>().deleteTask(task.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting task: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSubtasksDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          // Get the latest task data and ensure subtasks are properly ordered
          final currentTask = taskProvider.tasks.firstWhere((t) => t.id == task.id, orElse: () => task);
          
          // Sort subtasks by order to ensure correct display
          final sortedSubtasks = List<SubTask>.from(currentTask.subtasks)
            ..sort((a, b) => a.order.compareTo(b.order));
          
          final taskWithSortedSubtasks = currentTask.copyWith(subtasks: sortedSubtasks);
          
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Subtasks: ${taskWithSortedSubtasks.title}',
              style: const TextStyle(color: Colors.white),
            ),
            content: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
                minHeight: 100,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (taskWithSortedSubtasks.subtasks.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No subtasks available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ]
                  else ...[
                    Flexible(
                      child: SingleChildScrollView(
                        child: SubtaskListWidget(
                          subtasks: taskWithSortedSubtasks.subtasks,
                          onSubtaskStatusChangedByIndex: (index, isCompleted) async {
                            try {
                              await context.read<TaskProvider>().updateSubTaskCompletionByIndex(
                                taskWithSortedSubtasks.id,
                                index,
                                isCompleted,
                              );
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isCompleted
                                        ? 'Subtask marked as complete' 
                                        : 'Subtask marked as incomplete'
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error updating subtask: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          onReorder: (oldIndex, newIndex) async {
                            try {
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }
                              
                              // Create a copy of subtasks for reordering
                              final updatedSubtasks = List<SubTask>.from(taskWithSortedSubtasks.subtasks);
                              final item = updatedSubtasks.removeAt(oldIndex);
                              updatedSubtasks.insert(newIndex, item);
                              
                              // Update order values
                              for (int i = 0; i < updatedSubtasks.length; i++) {
                                updatedSubtasks[i] = updatedSubtasks[i].copyWith(order: i);
                              }
                              
                              // Update the task with new subtask order
                              final updatedTask = taskWithSortedSubtasks.copyWith(subtasks: updatedSubtasks);
                              await context.read<TaskProvider>().updateTask(updatedTask);
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Subtasks reordered successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error reordering subtasks: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          showDragHandle: true,
                          showDeleteButton: false,
                          showEditButton: false,
                          isReorderable: true,
                          emptyMessage: 'No subtasks available',
                          itemPadding: const EdgeInsets.only(bottom: 2),
                          itemSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }
}
