// task_widgets.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'task.dart';

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
