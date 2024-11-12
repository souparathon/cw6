import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _selectedPriority = 'Low';
  String _sortOption = 'Priority';
  String _filterOption = 'All';

  // Add a new task to Firebase
  void _addTask(String taskName) {
    final uid = _auth.currentUser?.uid;
    if (uid != null && taskName.isNotEmpty) {
      _db.collection('tasks').add({
        'name': taskName,
        'isCompleted': false,
        'priority': _selectedPriority,
        'userId': uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _taskController.clear();
    }
  }

  // Toggle task completion status
  void _toggleTaskCompletion(String taskId, bool isCompleted) {
    _db.collection('tasks').doc(taskId).update({'isCompleted': !isCompleted});
  }

  // Delete a task from Firebase
  void _deleteTask(String taskId) {
    _db.collection('tasks').doc(taskId).delete();
  }

  // Sort tasks based on selected criteria
  Stream<QuerySnapshot> _getTasks() {
    Query tasksQuery = _db.collection('tasks')
      .where('userId', isEqualTo: _auth.currentUser?.uid);

    if (_filterOption != 'All') {
      tasksQuery = tasksQuery.where('priority', isEqualTo: _filterOption);
    }

    switch (_sortOption) {
      case 'Priority':
        tasksQuery = tasksQuery.orderBy('priority');
        break;
      case 'Due Date':
        tasksQuery = tasksQuery.orderBy('timestamp');
        break;
      case 'Completion':
        tasksQuery = tasksQuery.orderBy('isCompleted');
        break;
    }

    return tasksQuery.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          DropdownButton<String>(
            value: _filterOption,
            items: ['All', 'High', 'Medium', 'Low']
              .map((filter) => DropdownMenuItem(value: filter, child: Text(filter)))
              .toList(),
            onChanged: (value) {
              setState(() {
                _filterOption = value!;
              });
            },
          ),
          DropdownButton<String>(
            value: _sortOption,
            items: ['Priority', 'Due Date', 'Completion']
              .map((sort) => DropdownMenuItem(value: sort, child: Text(sort)))
              .toList(),
            onChanged: (value) {
              setState(() {
                _sortOption = value!;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Task Name',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedPriority,
                  items: ['Low', 'Medium', 'High']
                      .map((priority) => DropdownMenuItem(value: priority, child: Text(priority)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value!;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTask(_taskController.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _getTasks(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final tasks = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task['name']),
                      leading: Checkbox(
                        value: task['isCompleted'],
                        onChanged: (value) =>
                          _toggleTaskCompletion(task.id, task['isCompleted']),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            task['priority'],
                            style: TextStyle(
                              color: task['priority'] == 'High' ? Colors.red :
                                     task['priority'] == 'Medium' ? Colors.orange : Colors.green,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteTask(task.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}
