import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mess_app/gobal_data.dart';

class TaskPage extends StatefulWidget {
  final Map<String, String> arguments;
  const TaskPage({super.key, required this.arguments});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var db = FirebaseFirestore.instance;
  var firebaseAuth = FirebaseAuth.instance;
  MyTask currentTask = MyTask();
  MyUser currentUser = MyUser();
  MyUser ownerUser = MyUser();
  List<MyUser> sharedList = List.empty();

  String taskID = "";
  int pageIndex = 0;
  bool loading = true;
  @override
  initState() {
    super.initState();
    // Auth get user id
    if (firebaseAuth.currentUser == null) {
      // User not login
      Navigator.pushNamed(context, MyRouter.SignInPage);
    } else {
      // User login as Email pass, email no pass, phone number.
      //currentUserID = firebaseAuth.currentUser!.uid;
      taskID = widget.arguments['taskID'].toString();
    }
  }

  updateTask() async {
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
    } catch (e) {
      messengerBoxShow("Task error $e");
    }
  }

  updateState() {
    setState(() {
      pageIndex = pageIndex;
    });
  }

  Future<void> loadingMyDataBase() async {
    if (loading) {
      updateTask();
      loading = false;
    }
    //final taskCollection = db.collection("Tasks");
    // add listen for user:
    //taskCollection.doc(currentTask.taskID).snapshots().listen((event) {
    //  updateTask();
    //});
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // Auth get user id
      await loadingMyDataBase();
      //listUsers = await getAllUsers();
    });
    return Scaffold(key: _scaffoldKey, appBar: myAppBar(), body: myBody());
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
                showShareInput();
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

  void showRemoveTask() {
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
                onPressed: () async {
                  // find all the userID to remove task
                  final userCollection = db.collection("Users");
                  try {
                    for (int i = 0; i < sharedList.length; i++) {
                      await userCollection
                          .doc(sharedList[i].userID)
                          .get()
                          .then((value) async {
                        MyUser targetUser = MyUser.fromFirestore(value);
                        List<String> parts = targetUser.taks!.split(',');
                        parts.remove(currentTask.taskID);
                        targetUser.taks = parts.join(',');
                        await userCollection
                            .doc(sharedList[i].userID)
                            .set(targetUser.toFirestore());
                      });
                    }
                    await userCollection
                        .doc(ownerUser.userID)
                        .get()
                        .then((value) async {
                      MyUser targetUser = MyUser.fromFirestore(value);
                      List<String> parts = targetUser.taks!.split(',');
                      parts.remove(currentTask.taskID);
                      targetUser.taks = parts.join(',');
                      await userCollection
                          .doc(ownerUser.userID)
                          .set(targetUser.toFirestore());
                    });
                    messengeBoxShow("Remove Task successful");
                    updateTask();
                    updateState();
                  } catch (e) {
                    messengeBoxShow("Remove share error $e");
                  }
                },
                child: const Text('Yes'),
              ),
            ],
          );
        });
  }

  void showShareRemove() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var emailController = TextEditingController();

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
                onPressed: () async {
                  var email = emailController.text;
                  if (email == "") {
                    messengeBoxShow("Enter Email your want to remove");
                    return;
                  }
                  int targetIndex = -1;
                  for (int i = 0; i < sharedList.length; i++) {
                    if (email.compareTo(sharedList[i].email.toString()) == 0) {
                      targetIndex = i;
                      break;
                    }
                  }
                  if (targetIndex == -1) {
                    messengeBoxShow("This email is not in share list");
                    return;
                  }

                  // find the userID to remove task
                  final userCollection = db.collection("Users");
                  final taskCollection = db.collection("Tasks");
                  try {
                    await userCollection
                        .doc(sharedList[targetIndex].userID)
                        .get()
                        .then((value) async {
                      MyUser targetUser = MyUser.fromFirestore(value);
                      List<String> parts = targetUser.taks!.split(',');
                      parts.remove(sharedList[targetIndex].userID.toString());
                      targetUser.taks = parts.join(',');
                      await userCollection
                          .doc(sharedList[targetIndex].userID)
                          .set(targetUser.toFirestore());
                      taskCollection.doc(currentTask.taskID).delete();
                    });
                    messengeBoxShow("Remove share successful");
                    updateTask();
                    updateState();
                  } catch (e) {
                    messengeBoxShow("Remove share error $e");
                  }
                },
                child: const Text('Remove'),
              ),
            ],
          );
        });
  }

  void showShareInput() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var emailController = TextEditingController();

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
                onPressed: () {
                  var email = emailController.text;
                  if (email == "") {
                    messengeBoxShow("Enter Email your want to add");
                    return;
                  }
                  for (var sharedID in sharedList) {
                    if (email.compareTo(sharedID.email.toString()) == 0) {
                      messengeBoxShow("This email shared");
                      return;
                    }
                  }
                  // find the userID to share
                  final userCollection = db.collection("Users");
                  final taskCollection = db.collection("Tasks");
                  try {
                    userCollection
                        .where("email", isEqualTo: email)
                        .get()
                        .then((querySnapshot) async {
                      if (querySnapshot.docs.isEmpty) {
                        messengeBoxShow(
                            'This email in invaild. Try another one.');
                      } else {
                        MyUser newUser =
                            MyUser.fromFirestore(querySnapshot.docs[0]);
                        if (currentTask.sharedID.isNull ||
                            currentTask.sharedID == "") {
                          currentTask.sharedID = newUser.userID;
                        } else {
                          currentTask.sharedID =
                              "${currentTask.sharedID},${newUser.userID}";
                        }
                        await taskCollection
                            .doc(currentTask.taskID)
                            .set(currentTask.toFirestore());
                        messengeBoxShow("Create successful");
                        updateTask();
                        updateState();
                        Navigator.pop(context);
                      }
                    });
                  } catch (e) {
                    messengeBoxShow("Error $e");
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        });
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

  Widget widgetLoading() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 1.3,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  myBody() {
    switch (pageIndex) {
      case 0:
        return widgetLoading();
      case 1:
        return widgetTaskInfor();
      default:
        return const Text("Page not found");
    }
  }

  String getSharedEmail() {
    String result = "";
    for (int i = 0; i < sharedList.length; i++) {
      result = "$result,${sharedList[i].email}";
    }
    return result;
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
    DateTime? selectedDate;
    String selectedstatus = "";

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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameEventController,
              decoration: const InputDecoration(labelText: 'Task Name'),
              readOnly: (currentUser.userID!
                      .compareTo(ownerUser.userID!.toString()) !=
                  0),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: detailController,
              decoration: const InputDecoration(labelText: 'Task Mission'),
              readOnly: (currentUser.userID!
                      .compareTo(ownerUser.userID!.toString()) !=
                  0),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dueDateController,
              decoration:
                  const InputDecoration(labelText: 'Due Date (MM/DD/YYY)'),
              readOnly: (currentUser.userID!
                      .compareTo(ownerUser.userID!.toString()) !=
                  0),
              onTap: () {
                if (currentUser.userID!
                        .compareTo(ownerUser.userID.toString()) ==
                    0) {
                  selectDate(context);
                }
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
                  selectedstatus = newValue ?? '';
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
            ElevatedButton(
              onPressed: () async {
                //action when click
                final taskCollection = db.collection("Tasks");
                currentTask.note = noteController.text;
                if (selectedstatus != "") {
                  currentTask.status = selectedstatus;
                }
                if (currentUser.userID!
                        .compareTo(ownerUser.userID.toString()) ==
                    0) {
                  currentTask.nameEvent = nameEventController.text;
                  currentTask.detail = detailController.text;
                }
                await taskCollection
                    .doc(currentTask.taskID)
                    .set(currentTask.toFirestore());
                setState(() {});
                messengerBoxShow("Update Successful");
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void messengerBoxShow(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}
