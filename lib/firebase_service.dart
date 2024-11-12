import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Task>> getTasks(String userId) {
    return _db.collection('tasks')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addTask(Task task, String userId) {
    return _db.collection('tasks').add({
      'name': task.name,
      'isCompleted': task.isCompleted,
      'priority': task.priority,
      'userId': userId,
    });
  }

  Future<void> updateTask(Task task) {
    return _db.collection('tasks').doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) {
    return _db.collection('tasks').doc(taskId).delete();
  }
}
