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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
  Priority _selectedPriority = Priority.low;

  // function to add a task
  void _addTask() {
    setState(() {
      if (_inputController.text.isNotEmpty) {
        _taskList.add(
            Task(name: _inputController.text, priority: _selectedPriority));
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

  // function to remove a task
  void _removeTask(int index) {
    setState(() {
      _taskList.removeAt(index);
    });
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

  // function to sort taskList
  void _sortTasks() {
    _taskList.sort((a, b) => b.priority.index.compareTo(a.priority.index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Todo List'),
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
                      labelText: 'Please enter a task',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
          Expanded(
            child: ListView.builder(
              itemCount: _taskList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      leading: Checkbox(
                          value: _taskList[index].isCompleted,
                          onChanged: (_) => _toggleTaskState(index)),
                      title: Text(
                        _taskList[index].name,
                        style: TextStyle(
                            decoration: _taskList[index].isCompleted
                                ? TextDecoration.lineThrough
                                : null),
                      ),
                      subtitle: Text(
                          ' ${_priorityToString(_taskList[index].priority)} Priority'),
                      trailing: IconButton(
                          onPressed: () => _removeTask(index),
                          icon: const Icon((Icons.remove))),
                    ),
                    const Divider(height: 0)
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
