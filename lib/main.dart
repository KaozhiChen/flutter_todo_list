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

class Task {
  String name;
  bool isCompleted;

  Task({required this.name, this.isCompleted = false});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _inputController = TextEditingController();
  final List<Task> _taskList = [];

  void _addTask() {
    setState(() {
      if (_inputController.text.isNotEmpty) {
        _taskList.add(Task(name: _inputController.text));
        _inputController.clear();
      }
    });
  }

  void _toggleTaskState(int index) {
    setState(() {
      _taskList[index].isCompleted = !_taskList[index].isCompleted;
    });
  }

  void _removeTask(int index) {
    setState(() {
      _taskList.removeAt(index);
    });
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
                ElevatedButton(onPressed: _addTask, child: const Text('Add'))
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _taskList.length,
              itemBuilder: (context, index) {
                return ListTile(
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
                  trailing: IconButton(
                      onPressed: () => _removeTask(index),
                      icon: const Icon((Icons.remove))),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
