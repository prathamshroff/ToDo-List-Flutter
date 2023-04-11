// task_list_screen.dart
import 'package:flutter/material.dart';
import 'task.dart';
import 'task_widgets.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _taskInputFocusNode = FocusNode();
  
  DateTime? _selectedDueDate;
  
  List<Task> _filterTasks(String query) {
  if (query.isEmpty) {
    return _tasks;
  }

  return _tasks
      .where((task) => task.title.toLowerCase().contains(query.toLowerCase()))
      .toList();
  }

  
  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: _taskController.text, dueDate: _selectedDueDate));
        _tasks.sort((a, b) {
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      });
      _taskController.clear();
      _taskInputFocusNode.requestFocus();
      _selectedDueDate = null;
    }
  }


  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Task task = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, task);
      _tasks.sort((a, b) {
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    });
  }


    
  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filterTasks(_searchController.text);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 16.0),
          TaskSearchBar(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 16.0),
          TaskInputField(
            taskController: _taskController,
            onTaskAdded: _addTask,
            focusNode: _taskInputFocusNode,
            selectDueDate: _selectDueDate,
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: TaskList(
              tasks: filteredTasks,
              onTaskRemoved: _removeTask,
              onTasksReordered: _reorderTasks,
              onTaskToggled: (int index) {
                setState(() {
                  _tasks[index].toggleCompletion();
                });
              }
            ),
          ),
        ],
      ),
    );
  }   
}
