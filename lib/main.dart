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

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedTaskItem(removedTask, animation),
      duration: const Duration(milliseconds: 300),
    );

    setState(() {
      _taskList.removeAt(index);
    });
  }

  // remove animation
  Widget _buildRemovedTaskItem(Task task, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.vertical,
      child: Card(
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
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(6)),
                  color: _getPriorityColor(task.priority),
                  width: 8,
                  //height: double.infinity,
                ),
              ),
              const SizedBox(width: 8),
              Checkbox(value: task.isCompleted, onChanged: null),
            ],
          ),
          title: Text(
            task.name,
            style: const TextStyle(decoration: TextDecoration.lineThrough),
          ),
        ),
      ),
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

  Widget _buildTaskItem(
      BuildContext context, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.vertical,
      child: Card(
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
                  //height: double.infinity,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(_taskList[index].priority),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              Checkbox(
                  value: _taskList[index].isCompleted,
                  onChanged: (_) => _toggleTaskState(index)),
            ],
          ),
          title: Text(
            _taskList[index].name,
            style: TextStyle(
                decoration: _taskList[index].isCompleted
                    ? TextDecoration.lineThrough
                    : null),
          ),
          trailing: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            child: Center(
              child: IconButton(
                  color: Colors.white,
                  iconSize: 20,
                  onPressed: () => _removeDialog(context, index),
                  padding: const EdgeInsets.all(0),
                  icon: const Icon((Icons.remove))),
            ),
          ),
        ),
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Please enter a task',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<Priority>(
                  value: _selectedPriority,
                  onChanged: (Priority? newValue) {
                    setState(() {
                      _selectedPriority = newValue!;
                    });
                  },
                  items: Priority.values.map((Priority priority) {
                    return DropdownMenuItem<Priority>(
                      value: priority,
                      child: Text(_priorityToString(priority)),
                    );
                  }).toList(),
                ),
                ElevatedButton(onPressed: _addTask, child: const Text('Add'))
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
                  return _buildTaskItem(context, index, animation);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
