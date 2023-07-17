import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mess_app/chats/Chat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskController = TextEditingController();
  final CollectionReference _tasksCollection =
  FirebaseFirestore.instance.collection('tasks');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to EasyText',
        style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.blue[100],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[100],
              ),
              child: const Row(
                children: [
                  Icon(Icons.person, color: Colors.black),
                  SizedBox(width: 10),
                  Text(
                    'Hello Username',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_rounded),
              title: const Text('Task'),
              onTap: () {
                Navigator.pushNamed(context, '/afterHome');
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Log out'),
              onTap: () {
                Navigator.pushNamed(context, '/logOut');
              },
            ),ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text('Delete Account'),
              onTap: () {
                Navigator.pushNamed(context, '/deleteAccount');
              },
            ),
          ],
        ),
      ),
      body:
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Step 4: Connect to Firestore
        //stream: _tasksCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No tasks yet.'),
            );
          }

          // Step 5: Display Tasks from Firestore
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final task = snapshot.data!.docs[index].data()['task'];
              final taskId = snapshot.data!.docs[index].id;

              return ListTile(
                title: Text(task),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteTask(taskId), // Step 7: Delete Tasks from Firestore
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add New Task'),
                content: TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    hintText: 'Enter your task...',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Step 6: Add Tasks to Firestore
                      _addTask();
                      Navigator.pop(context);
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
  void _addTask() async {
    String task = _taskController.text.trim();
    if (task.isNotEmpty) {
      _taskController.clear();
      await _tasksCollection.add({'task': task});
    }

  }

  void _deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }
}