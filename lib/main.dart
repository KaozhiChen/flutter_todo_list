import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo List',
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

// enumeration priority
enum Priority { low, medium, high }

// Task class
class Task {
  String name;
  bool isCompleted;
  Priority priority;
  Task({required this.name, this.isCompleted = false, required this.priority});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _inputController = TextEditingController();
  final List<Task> _taskList = [];

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  Priority _selectedPriority = Priority.low;

  // function to add a task
  void _addTask() {
    setState(() {
      if (_inputController.text.isNotEmpty) {
        Task newTask =
            Task(name: _inputController.text, priority: _selectedPriority);
        _taskList.add(newTask);
        _listKey.currentState?.insertItem(_taskList.length - 1);
        _inputController.clear();
        _sortTasks();
      }
    });
  }

  // function to toggle tasks' state
  void _toggleTaskState(int index) {
    setState(() {
      _taskList[index].isCompleted = !_taskList[index].isCompleted;
    });
  }

  // function to remove a task with animation
  void _removeTask(int index) {
    Task removedTask = _taskList[index];

    // renew task list after remove animation
    setState(() {
      _taskList.removeAt(index);
    });

    // triggering animation
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _removeTaskAnimation(removedTask, animation),
      duration: const Duration(milliseconds: 300),
    );
  }

  // remove animation
  Widget _removeTaskAnimation(Task task, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.vertical,
      child: _buildTaskItem(task, isRemoving: true),
    );
  }

  // add animation
  Widget _addTaskAnimation(
      BuildContext context, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.vertical,
      child: _buildTaskItem(_taskList[index], index: index, key: UniqueKey()),
    );
  }

  // function to get priority color
  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.redAccent;
      case Priority.medium:
        return Colors.orangeAccent;
      case Priority.low:
      default:
        return Colors.greenAccent;
    }
  }

  // function to switch priority to string
  String _priorityToString(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }

  Future<void> _removeDialog(BuildContext context, index) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Confirmation'),
          content: const Text(
            'Are you sure to remove this task?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Remove'),
              onPressed: () {
                Navigator.of(context).pop();
                _removeTask(index);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // function to sort taskList
  void _sortTasks() {
    _taskList.sort((a, b) => b.priority.index.compareTo(a.priority.index));
  }

  // Widget to build task item Layout
  Widget _buildTaskItem(Task task,
      {int? index, bool isRemoving = false, Key? key}) {
    return Card(
      key: key,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      color: Colors.grey[850],
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                width: 8,
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (!isRemoving)
              Checkbox(
                value: task.isCompleted,
                onChanged:
                    index != null ? (_) => _toggleTaskState(index) : null,
              ),
          ],
        ),
        title: Text(
          task.name,
          style: task.isCompleted
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : const TextStyle(),
        ),
        trailing: !isRemoving && index != null
            ? IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removeDialog(context, index),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Todo List',
          style: TextStyle(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Enter task',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.task, color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButton<Priority>(
                    value: _selectedPriority,
                    dropdownColor: Colors.black,
                    underline: Container(),
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                    onChanged: (Priority? newValue) {
                      setState(() {
                        _selectedPriority = newValue!;
                      });
                    },
                    items: Priority.values.map((Priority priority) {
                      return DropdownMenuItem<Priority>(
                        value: priority,
                        child: Text(
                          _priorityToString(priority),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),

          // AnimatedList to display tasks
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: AnimatedList(
                key: _listKey,
                initialItemCount: _taskList.length,
                itemBuilder: (context, index, animation) {
                  return _addTaskAnimation(context, index, animation);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
