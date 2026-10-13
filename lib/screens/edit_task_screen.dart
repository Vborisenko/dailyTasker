import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/sub_task.dart';
import '../providers/task_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/subtask_list_widget.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  late TaskPriority _selectedPriority;
  late int? _selectedCategoryId;
  late List<SubTask> _subtasks;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _selectedPriority = widget.task.priority;
    _selectedCategoryId = widget.task.categoryId;
    _subtasks = List<SubTask>.from(widget.task.subtasks);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addSubTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subtask'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Subtask Title',
                hintText: 'Enter subtask title',
              ),
              onSubmitted: (title) {
                if (title.trim().isNotEmpty) {
                  final subtask = SubTask(
                    id: 0, // Temporary ID, will be replaced when saving
                    title: title.trim(),
                    description: '',
                    order: _subtasks.length,
                    createdAt: DateTime.now(),
                  );
                  setState(() {
                    _subtasks.add(subtask);
                  });
                  Navigator.of(context).pop();
                  
                  // Save changes immediately after adding subtask
                  _saveTaskChanges();
                }
              },
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Добавляем подзадачу с текстом длиной 20 символов
              final subtask = SubTask(
                id: 0, // Temporary ID, will be replaced when saving
                title: 'Test subtask 20 chars',
                description: 'This is a test subtask with exactly 20 characters in title',
                order: _subtasks.length,
                createdAt: DateTime.now(),
              );
              setState(() {
                _subtasks.add(subtask);
              });
              Navigator.of(context).pop();
              
              // Save changes immediately after adding subtask
              _saveTaskChanges();
              
              // Показываем уведомление о добавлении
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test subtask added!'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Test'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _editSubTaskTitle(int index) {
    final subtask = _subtasks[index];
    final controller = TextEditingController(text: subtask.title);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Subtask Title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Subtask Title',
            hintText: 'Enter subtask title',
          ),
          onSubmitted: (title) {
            if (title.trim().isNotEmpty) {
              setState(() {
                _subtasks[index] = subtask.copyWith(title: title.trim());
              });
              Navigator.of(context).pop();
              
              // Save changes immediately after editing subtask title
              _saveTaskChanges();
            }
          },
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                setState(() {
                  _subtasks[index] = subtask.copyWith(title: title);
                });
                Navigator.of(context).pop();
                
                // Save changes immediately after editing subtask title
                _saveTaskChanges();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _removeSubTask(int index) {
    setState(() {
      _subtasks.removeAt(index);
      // Reorder remaining subtasks
      for (int i = 0; i < _subtasks.length; i++) {
        _subtasks[i] = _subtasks[i].copyWith(order: i);
      }
    });
    
    // Save changes immediately after removing subtask
    _saveTaskChanges();
  }

  Future<void> _saveTaskChanges() async {
    try {
      // Only save if there are actual changes
      if (_subtasks.isNotEmpty) {
        final updatedTask = widget.task.copyWith(
          subtasks: _subtasks,
        );

        await context.read<TaskProvider>().updateTask(updatedTask);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving changes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Update IDs for new subtasks and ensure proper ordering
        final updatedSubtasks = _subtasks.asMap().entries.map((entry) {
          final index = entry.key;
          final subtask = entry.value;
          
          if (subtask.id == 0) {
            // This is a new subtask, get next ID from provider
            final nextId = context.read<TaskProvider>().getNextSubTaskId();
            return subtask.copyWith(
              id: nextId,
              order: index,
            );
          } else {
            // Existing subtask, update order
            return subtask.copyWith(order: index);
          }
        }).toList();

        // Save the complete task with all changes
        final updatedTask = widget.task.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          categoryId: _selectedCategoryId,
          subtasks: updatedSubtasks,
        );

        await context.read<TaskProvider>().updateTask(updatedTask);
        
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating task: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title *',
                hintText: 'Enter task title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Priority selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Priority',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: TaskPriority.values.map((priority) {
                        final isSelected = _selectedPriority == priority;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPriority = priority;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? _getPriorityColor(priority) : Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? _getPriorityColor(priority) : Colors.grey[600]!,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                _getPriorityName(priority),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[300],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Subtasks section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtasks',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addSubTask,
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    if (_subtasks.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SubtaskListWidget(
                        subtasks: _subtasks,
                        onSubtaskStatusChangedByIndex: (index, isCompleted) async {
                          setState(() {
                            _subtasks[index] = _subtasks[index].copyWith(
                              isCompleted: isCompleted,
                            );
                          });
                          
                          // Save changes immediately after updating subtask status
                          await _saveTaskChanges();
                        },
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final item = _subtasks.removeAt(oldIndex);
                            _subtasks.insert(newIndex, item);
                            
                            // Update order values
                            for (int i = 0; i < _subtasks.length; i++) {
                              _subtasks[i] = _subtasks[i].copyWith(order: i);
                            }
                          });
                          
                          // Save changes immediately after reordering
                          _saveTaskChanges();
                        },
                        onEditSubtask: (index) => _editSubTaskTitle(index),
                        onDeleteSubtask: (index) => _removeSubTask(index),
                        showDragHandle: true,
                        showDeleteButton: true,
                        showEditButton: true,
                        isReorderable: true,
                        itemPadding: const EdgeInsets.only(bottom: 2),
                        itemSpacing: 2,
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Text(
                        'No subtasks added yet',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Category selection
            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                // Check if selected category still exists
                if (_selectedCategoryId != null) {
                  final categoryExists = categoryProvider.categories.any((cat) => cat.id == _selectedCategoryId);
                  if (!categoryExists) {
                    // Category was deleted, reset to null
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _selectedCategoryId = null;
                      });
                    });
                  }
                }

                if (categoryProvider.categories.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No categories available. You can edit tasks without categories.',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedCategoryId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select category (optional)',
                          ),
                          items: [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text('No category'),
                            ),
                            ...categoryProvider.categories.map((category) {
                              return DropdownMenuItem<int>(
                                value: category.id,
                                child: Text(category.name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String _getPriorityName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }
}
