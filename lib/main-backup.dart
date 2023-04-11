import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TaskListScreen(title: 'To-Do List'),
    );
  }
}

class Task {
  Task({required this.title, this.dueDate, this.isCompleted = false});

  String title;
  DateTime? dueDate;
  bool isCompleted;

  void toggleCompletion() {
    isCompleted = !isCompleted;
  }
}

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

class TaskInputField extends StatelessWidget {
  const TaskInputField({
    Key? key,
    required this.taskController,
    required this.onTaskAdded,
    required this.focusNode,
    required this.selectDueDate,
  }) : super(key: key);

  final TextEditingController taskController;
  final VoidCallback onTaskAdded;
  final FocusNode focusNode;
  final Future<void> Function(BuildContext) selectDueDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: taskController,
              focusNode: focusNode,
              onSubmitted: (_) => onTaskAdded(),
              decoration: const InputDecoration(
                labelText: 'Enter task',
              ),
            ),
          ),
          IconButton(
            onPressed: () => selectDueDate(context),
            icon: const Icon(Icons.calendar_today),
          ),
          IconButton(
            onPressed: onTaskAdded,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  const TaskList({
    Key? key,
    required this.tasks,
    required this.onTaskRemoved,
    required this.onTasksReordered,
    required this.onTaskToggled,
  }) : super(key: key);

  final List<Task> tasks;
  final ValueChanged<int> onTaskRemoved;
  final Function(int, int) onTasksReordered;
  final ValueChanged<int> onTaskToggled;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) => onTasksReordered(oldIndex, newIndex),
      buildDefaultDragHandles: false,
      children: tasks.asMap().entries.map((entry) {
        final int index = entry.key;
        final Task task = entry.value;
        
        return TaskListItem(
          key: ValueKey(task),
          index: index,
          task: task,
          onRemove: () => onTaskRemoved(index),
          onReorder: (int newIndex) => onTasksReordered(index, newIndex),
          onTaskToggled: () => onTaskToggled(index),
        );
      }).toList(),
    );
  }
}

typedef TaskReorderCallback = void Function(int newIndex);

class TaskListItem extends StatelessWidget {
  const TaskListItem({
    Key? key,
    required this.task,
    required this.index,
    required this.onRemove,
    required this.onReorder,
    required this.onTaskToggled,
  }) : super(key: key);

  final Task task;
  final int index;
  final VoidCallback onRemove;
  final TaskReorderCallback onReorder;
  final VoidCallback onTaskToggled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.menu),
      ),
      title: Text(task.title,
          style: task.isCompleted
              ? TextStyle(decoration: TextDecoration.lineThrough)
              : null),
      subtitle: task.dueDate != null
          ? Text(DateFormat('yyyy-MM-dd').format(task.dueDate!))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: task.isCompleted,
            onChanged: (bool? value) {
              onTaskToggled();
            },
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}

class TaskSearchBar extends StatelessWidget {
  const TaskSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          labelText: 'Search tasks',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
