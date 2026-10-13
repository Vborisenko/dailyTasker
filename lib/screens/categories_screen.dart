import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';
import 'create_task_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    _nameController.clear();
    final currentContext = context;
    final categoryProvider = currentContext.read<CategoryProvider>();
    
    showDialog(
      context: currentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Category'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              hintText: 'Enter category name',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a category name';
              }
              if (categoryProvider.categoryExists(value.trim())) {
                return 'Category with this name already exists';
              }
              return null;
            },
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addCategory(
              dialogContext, 
              categoryProvider, 
              () => _showErrorSnackBar(currentContext, 'Error adding category')
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCategory(BuildContext dialogContext, CategoryProvider categoryProvider, VoidCallback onError) async {
    if (_formKey.currentState!.validate()) {
      try {
        await categoryProvider.addCategory(_nameController.text);
        if (mounted) {
          Navigator.of(dialogContext).pop();
        }
      } catch (e) {
        if (mounted) {
          onError();
        }
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showEditCategoryDialog(TaskCategory category) {
    _nameController.text = category.name;
    final currentContext = context;
    final categoryProvider = currentContext.read<CategoryProvider>();
    
    showDialog(
      context: currentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Category'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              hintText: 'Enter category name',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a category name';
              }
              if (categoryProvider.categoryExists(value.trim()) &&
                  value.trim().toLowerCase() != category.name.toLowerCase()) {
                return 'Category with this name already exists';
              }
              return null;
            },
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateCategory(
              dialogContext, 
              categoryProvider, 
              category.id, 
              () => _showErrorSnackBar(currentContext, 'Error updating category')
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCategory(BuildContext dialogContext, CategoryProvider categoryProvider, int categoryId, VoidCallback onError) async {
    if (_formKey.currentState!.validate()) {
      try {
        await categoryProvider.updateCategory(categoryId, _nameController.text);
        if (mounted) {
          Navigator.of(dialogContext).pop();
        }
      } catch (e) {
        if (mounted) {
          onError();
        }
      }
    }
  }

  void _showDeleteConfirmation(TaskCategory category) {
    final currentContext = context;
    final categoryProvider = currentContext.read<CategoryProvider>();
    
    showDialog(
      context: currentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\n'
          'All tasks in this category will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteCategory(
              dialogContext, 
              categoryProvider, 
              category.id, 
              () => _showErrorSnackBar(currentContext, 'Error deleting category')
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

    Future<void> _deleteCategory(BuildContext dialogContext, CategoryProvider categoryProvider, int categoryId, VoidCallback onError) async {
    try {
      await categoryProvider.deleteCategory(categoryId);
      if (mounted) {
        Navigator.of(dialogContext).pop();
      }
    } catch (e) {
      if (mounted) {
        onError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.categories.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No categories yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first category to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categoryProvider.categories.length,
            itemBuilder: (context, index) {
              final category = categoryProvider.categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.category, color: Colors.orange),
                  title: Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Created: ${_formatDate(category.createdAt)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditCategoryDialog(category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(category),
                      ),
                    ],
                  ),
                  onLongPress: () => _showEditCategoryDialog(category),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: "add_task_button",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateTaskScreen(),
                ),
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add_task, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "add_category_button",
            onPressed: _showAddCategoryDialog,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
