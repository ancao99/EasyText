import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../gobal_data.dart';
import 'ChatPage.dart';

class TaskPage extends StatefulWidget {
  final Map<String, String> arguments;
  const TaskPage({super.key, required this.arguments});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  var db = FirebaseFirestore.instance;
  var firebaseAuth = FirebaseAuth.instance;
  MyTask currentTask = MyTask();
  MyUser currentUser = MyUser();
  MyUser ownerUser = MyUser();
  List<MyUser> sharedList = List.empty(growable: true);
  String taskID = "";

  // Firbase listen
  StreamSubscription<DocumentSnapshot>? listener;
  bool listenerCreated = false;
  bool isLoading = true;
  setUpListener() {
    final taskCollection = db.collection("Tasks");
    taskCollection.doc(taskID).snapshots().listen((event) async {
      messengeBoxShow("updating");
      try {
        setState(() {
          isLoading = true;
        });
        await updateTaskInfor();
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        //messengeBoxShow("Error $e");
      }
    });
  }

  @override
  void dispose() {
    listener?.cancel();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
  }

  updateTaskInfor() async {
    try {
      //Mission loading my user and blindding data.
      final userCollection = db.collection("Users");
      final taskCollection = db.collection("Tasks");
      // build my User
      await userCollection.doc(firebaseAuth.currentUser!.uid).get().then(
        (value) {
          currentUser = MyUser.fromFirestore(value);
        },
      );
      // build task
      await taskCollection.doc(taskID).get().then((value) {
        currentTask = MyTask.fromFirestore(value);
      });
      // build sharedlist
      if (currentTask.sharedID != null && currentTask.sharedID != "") {
        List<String> parts = currentTask.sharedID!.split(',').toSet().toList();
        List<MyUser> newSharedList = List<MyUser>.empty(growable: true);
        for (String id in parts) {
          await userCollection.doc(id).get().then((value) {
            MyUser tmpUser = MyUser.fromFirestore(value);
            newSharedList.add(tmpUser);
          });
        }
        sharedList = newSharedList;
      }
      // build owner
      if (currentTask.ownerID != null && currentTask.ownerID != "") {
        await userCollection.doc(currentTask.ownerID).get().then((value) {
          ownerUser = MyUser.fromFirestore(value);
        });
      } else {
        messengeBoxShow("This Task don`t have id");
      }
    } catch (e) {
      messengeBoxShow("Task error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      if (firebaseAuth.currentUser == null) {
        // User not login
        Navigator.pushReplacementNamed(context, MyRouter.SignInPage);
      } else {
        if (!listenerCreated) {
          if (widget.arguments['taskID'] == null) {
            Navigator.pop(context);
          }
          taskID = widget.arguments['taskID'].toString();
          listener = setUpListener();
          listenerCreated = true;
        }
      }
    });
    if (isLoading) {
      return Scaffold(body: widgetLoading());
    }
    return Scaffold(appBar: myAppBar(), body: widgetTaskInfor());
  }

  myAppBar() {
    return AppBar(
      title: const Text("Task Detail"),
      actions: <Widget>[
        PopupMenuButton<int>(
          onSelected: (item) {
            if (currentUser.userID!.compareTo(ownerUser.userID.toString()) !=
                0) {
              messengeBoxShow("Function only support for owner Task");
              return;
            }
            switch (item) {
              case 0:
                showShareAdd();
                break;
              case 1:
                showShareRemove();
                break;
              case 2:
                showRemoveTask();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<int>(value: 0, child: Text("Add Share")),
            const PopupMenuItem<int>(value: 1, child: Text("Delete Share")),
            const PopupMenuItem<int>(value: 2, child: Text("Delete Task"))
          ],
        ),
      ],
    );
  }

  // App bar action section
  void showRemoveTask() {
    //Delete Task Button Yes
    removeTask() async {
      // find all the userID to remove task
      final userCollection = db.collection("Users");
      try {
        for (int i = 0; i < sharedList.length; i++) {
          await userCollection
              .doc(sharedList[i].userID)
              .get()
              .then((value) async {
            MyUser targetUser = MyUser.fromFirestore(value);
            if (targetUser.taks != null && targetUser.taks != "") {
              List<String> parts =
                  targetUser.taks!.toString().split(',').toSet().toList();
              parts.remove(currentTask.taskID);
              targetUser.taks = parts.join(",");
              await userCollection
                  .doc(sharedList[i].userID)
                  .set(targetUser.toFirestore());
            }
          });
        }
        // delete in ownerUser user
        await userCollection.doc(ownerUser.userID).get().then((value) async {
          MyUser targetUser = MyUser.fromFirestore(value);
          List<String> parts =
              targetUser.taks!.toString().split(',').toSet().toList();
          parts.remove(currentTask.taskID);
          targetUser.taks = parts.join(",");
          await userCollection
              .doc(ownerUser.userID)
              .set(targetUser.toFirestore());
        });
        // Remove this task.
        if (listener != null) {
          listener!.cancel();
        }

        final taskCollection = db.collection("Tasks");
        taskCollection.doc(taskID).delete();
        messengeBoxShow("Remove Task successful");
        return true;
      } catch (e) {
        messengeBoxShow("Remove share error $e");
      }
      return false;
    }

    removeTaskButton() {
      removeTask().then((value) {
        if (value == true) {
          if (listenerCreated && listener != null) {
            listener!.cancel();
          }
          Navigator.pop(context);
          Navigator.pop(context);
        }
      });
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Delete task'),
            content: const Text('Are you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: removeTaskButton,
                child: const Text('Yes'),
              ),
            ],
          );
        });
  }

  void showShareRemove() {
    var emailController = TextEditingController();
    // Share remove button
    shareRemove() async {
      var email = emailController.text;
      if (email == "") {
        messengeBoxShow("Enter Email your want to remove");
        return false;
      }
      // check target in current Share List
      int targetIndex = -1;
      for (int i = 0; i < sharedList.length; i++) {
        if (email.compareTo(sharedList[i].email.toString()) == 0) {
          targetIndex = i;
          break;
        }
      }
      if (targetIndex == -1) {
        messengeBoxShow("This email is not in share list");
        return false;
      }

      // remove target
      try {
        final taskCollection = db.collection("Tasks");
        final userCollection = db.collection("Users");
        await userCollection
            .doc(sharedList[targetIndex].userID)
            .get()
            .then((value) async {
          MyUser targetUser = MyUser.fromFirestore(value);
          if (targetUser.taks != null && targetUser.taks != "") {
            List<String> parts = targetUser.taks!.split(',');
            parts.remove(taskID);
            targetUser.taks = parts.join(',');
            // push data
            await userCollection
                .doc(sharedList[targetIndex].userID)
                .set(targetUser.toFirestore());
          }
          // push data
          await taskCollection.doc(taskID).delete();
          return true;
        });
        messengeBoxShow("Remove share successful");
      } catch (e) {
        messengeBoxShow("Remove share error $e");
      }
      return false;
    }

    shareRemoveButton() {
      shareRemove().then((value) {
        if (value == true) {
          Navigator.pop(context);
        }
      });
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Remove Person'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        icon: Icon(Icons.email),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: shareRemoveButton,
                child: const Text('Remove'),
              ),
            ],
          );
        });
  }

  void showShareAdd() {
    var emailController = TextEditingController();
    //Share add button
    shareAdd() async {
      var email = emailController.text;
      if (email == "") {
        messengeBoxShow("Enter Email your want to add");
        return false;
      }
      for (var sharedID in sharedList) {
        if (email.compareTo(sharedID.email.toString()) == 0) {
          messengeBoxShow("This email shared");
          return false;
        }
      }
      // find the userID to share
      try {
        final taskCollection = db.collection("Tasks");
        final userCollection = db.collection("Users");
        var querySnapshot =
            await userCollection.where("email", isEqualTo: email).get();
        if (querySnapshot.docs.isEmpty) {
          messengeBoxShow('This email in invaild. Try another one.');
          return false;
        }
        // add Task to target
        MyUser newUser = MyUser.fromFirestore(querySnapshot.docs[0]);
        if (newUser.taks == null || newUser.taks == "") {
          newUser.taks = taskID;
        } else {
          List<String> parts = newUser.taks!.toString().split(',');
          parts.add(taskID);
          newUser.taks = parts.toSet().toList().join(",");
        }
        // add Target to ShareList
        if (currentTask.sharedID == null || currentTask.sharedID == "") {
          currentTask.sharedID = newUser.userID;
        } else {
          List<String> parts = currentTask.sharedID!.toString().split(',');
          parts.add(newUser.userID.toString());
          currentTask.sharedID = parts.toSet().toList().join(",");
        }
        // push data
        await userCollection.doc(newUser.userID).set(newUser.toFirestore());
        await taskCollection
            .doc(currentTask.taskID)
            .set(currentTask.toFirestore());
        messengeBoxShow("Create successful");
        return true;
      } catch (e) {
        messengeBoxShow("Error $e");
      }
      return false;
    }

    shareAddButton() {
      shareAdd().then((value) {
        if (value == true) {
          Navigator.pop(context);
        }
      });
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Add Person'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        icon: Icon(Icons.email),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: shareAddButton,
                child: const Text('Create'),
              ),
            ],
          );
        });
  }

  // Widget section
  Widget widgetLoading() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 1.3,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget widgetTaskInfor() {
    TextEditingController nameEventController =
        TextEditingController(text: currentTask.nameEvent);
    TextEditingController detailController =
        TextEditingController(text: currentTask.detail);
    TextEditingController noteController =
        TextEditingController(text: currentTask.note);
    TextEditingController dueDateController =
        TextEditingController(text: currentTask.dueDate);
    TextEditingController sharedIDController =
        TextEditingController(text: getSharedEmail());
    TextEditingController ownerIDController =
        TextEditingController(text: ownerUser.email);
    List<String> status = ['Pending', 'Working', 'Complete'];

    // Set Date button
    DateTime? selectedDate;
    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2023),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          dueDateController.text =
              "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}";
        });
      }
    }

    var readOnly = true;
    try {
      readOnly =
          (currentUser.userID!.compareTo(ownerUser.userID!.toString()) != 0);
    } catch (e) {
      messengeBoxShow("This task have error : $e");
      if (listenerCreated && listener != null) {
        listener!.cancel();
      }
      Navigator.pop(context);
    }
    // Update button
    updateButton() async {
      //action when click
      final taskCollection = db.collection("Tasks");
      currentTask.note = noteController.text;
      if (!readOnly) {
        currentTask.nameEvent = nameEventController.text;
        currentTask.detail = detailController.text;
      }
      await taskCollection
          .doc(currentTask.taskID)
          .set(currentTask.toFirestore());
      messengeBoxShow("Update Successful");
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: nameEventController,
            decoration: const InputDecoration(labelText: 'Task Name'),
            readOnly: readOnly,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: detailController,
            decoration: const InputDecoration(labelText: 'Task Mission'),
            readOnly: readOnly,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: dueDateController,
            decoration:
                const InputDecoration(labelText: 'Due Date (MM/DD/YYY)'),
            readOnly: readOnly,
            onTap: () {
              selectDate(context);
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          const SizedBox(height: 20),
          const Text('Status: '),
          DropdownButton<String>(
            value: currentTask.status,
            items: status.map((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                currentTask.status = newValue ?? '';
              });
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: ownerIDController,
            decoration: const InputDecoration(labelText: 'Owner ID'),
            readOnly: true,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: sharedIDController,
            decoration: const InputDecoration(labelText: 'Shared ID'),
            readOnly: true,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: updateButton,
                child: const Text('Update'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (listenerCreated && listener != null) {
                    listener!.cancel();
                  }
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatPage(arguments: {
                                "taskID": currentTask.taskID.toString()
                              })));
                },
                child: const Text('Group Chat'),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Useful function
  String getSharedEmail() {
    String result = "";
    for (int i = 0; i < sharedList.length; i++) {
      result = "$result,${sharedList[i].email}";
    }
    return result;
  }

  void messengeBoxShow(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.red, //text Color
        fontSize: 16.0 //font size
        );
  }
}
