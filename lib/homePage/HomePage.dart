// Home Page is Task Page, show all task as default
// Drawer move to COntact or recent chat page
// Home page bottom is action

import 'dart:convert';
import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mess_app/gobal_data.dart';

import '../subPages/AccountPage.dart';
import '../subPages/ChatPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var db = FirebaseFirestore.instance;
  var firebaseAuth = FirebaseAuth.instance;

  var pageIndex = 0;
  bool isLoading = true;
  MyUser currentUser = MyUser();
  List<MyUser> listContacts = List<MyUser>.empty(growable: true);
  List<MyTask> listTasks = List<MyTask>.empty(growable: true);
  List<MyChat> listChats = List<MyChat>.empty(growable: true);
  List appBarAction = [
    [],
    [
      const PopupMenuItem<int>(value: 0, child: Text("Create Task")),
      const PopupMenuItem<int>(value: 1, child: Text("Sort by Due Date"))
    ],
    [
      const PopupMenuItem<int>(value: 0, child: Text("Add People")),
      const PopupMenuItem<int>(value: 1, child: Text("Delete People"))
    ],
    [],
  ];
  List appBarTitle = ["Loading", "Task List", "Contacts", "Recent Chat"];
  List appBarMap = [
    [],
    ["Create Task", "Sort by Due Date"],
    ["Add People", "Delete People"],
    [],
  ];

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
    }
  }

  @override
  Widget build(BuildContext context) {
    // let make page flexible change as state update by data and slected index
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // Auth get user id
      await loadingMyDataBase();
      //listUsers = await getAllUsers();
    });
    return Scaffold(appBar: myAppBar(), drawer: myDrawer(), body: myBody());
  }

  updateCurrentUser() async {
    try {
      //Mission loading my user and blindding data.
      final userCollection = db.collection("Users");
      // build my User
      await userCollection
          .doc(firebaseAuth.currentUser!.uid)
          .get()
          .then((value) {
        currentUser = MyUser.fromFirestore(value);
      });
      if (currentUser.userID.isNull || currentUser.userID == "") {
        messengeBoxShow("currentUser userid null");
        return;
      }
      messengeBoxShow("done current user");
    } catch (e) {
      messengeBoxShow("Current user Error $e");
    }
  }

  updateTaskList() async {
    try {
      final taskCollection = db.collection("Tasks");
      // build task
      if (currentUser.taks.isNull || currentUser.taks == "") {
        updateCurrentUser();
        if (currentUser.taks.isNull || currentUser.taks == "") {
          messengeBoxShow("Task List Empty");
        }
      } else {
        var tasksIndex = currentUser.taks!.split(",");
        List<MyTask> tmplistTasks = List<MyTask>.empty(growable: true);
        for (int i = 0; i < tasksIndex.length; i++) {
          await taskCollection.doc(tasksIndex[i]).get().then(
            (value) {
              MyTask tmp = MyTask.fromFirestore(value);
              tmplistTasks.add(tmp);
            },
          );
        }
        listTasks = tmplistTasks;
      }
      messengeBoxShow("done task");
      updateState();
    } catch (e) {
      messengeBoxShow("Task List Error $e");
    }
  }

  void updateState() {
    setState(() {
      pageIndex = pageIndex;
    });
  }

  updateContactList() async {
    try {
      final userCollection = db.collection("Users");
      // build contact
      if (currentUser.contacts.isNull || currentUser.contacts == "") {
        messengeBoxShow("Contact List Empty");
      } else {
        var contactsIndex = currentUser.contacts!.split(",");
        for (int i = 0; i < contactsIndex.length; i++) {
          await userCollection.doc(contactsIndex[i]).get().then(
            (value) {
              var tmp = MyUser.fromFirestore(value);
              listContacts.add(tmp);
            },
          );
        }
      }
      messengeBoxShow("done contact");
    } catch (e) {
      messengeBoxShow("Contact list Error $e");
    }
  }

  updateChatList() async {
    try {
      final userCollection = db.collection("Users");
      final msgCollection = db.collection("Messages");
      // build chat
      if (currentUser.chats.isNull || currentUser.chats == "") {
        messengeBoxShow("Chat List Empty");
      } else {
        var chatsIndex = currentUser.chats!.split(",");
        for (int i = 0; i < chatsIndex.length; i++) {
          await msgCollection.doc(chatsIndex[i]).get().then(
            (value) async {
              // get current chat
              var thisChat = MyChat.fromFirestore(value);
              var ownerIndex = thisChat.owner!.split(",");
              // get chat name
              for (var id in ownerIndex) {
                if (id.compareTo(currentUser.userID.toString()) != 0) {
                  await userCollection.doc(id).get().then((value) {
                    var thisUser = MyUser.fromFirestore(value);
                    thisChat.ownerDetail = thisUser;
                  });
                }
              }
              listChats.add(thisChat);
            },
          );
        }
      }
      messengeBoxShow("done chat");
    } catch (e) {
      messengeBoxShow("Chat list Error $e");
    }
  }

  Future<void> loadingMyDataBase() async {
    if (isLoading) {
      updateCurrentUser();
      updateTaskList();
      updateContactList();
      updateChatList();
      isLoading = false;
      setState(() {
        pageIndex = 1;
      });
    }
  }

  void appBarClick(int item) {
    switch (appBarMap[pageIndex][item]) {
      case "Create Task":
        showCreateTask();
        break;
      case "Sort by Due Date":
        sortTaskByDueDate();
        break;
      case "Add People":
        showAddPeople();
        break;
      case "Delete People":
        showDeletePeople();
        break;
    }
  }

  void sortTaskByDueDate() {
    listTasks.sort((task1, task2) {
      DateTime dueDate1 = task1.getDueDateAsDateTime();
      DateTime dueDate2 = task2.getDueDateAsDateTime();
      return dueDate2.compareTo(dueDate1);
    });
    setState(() {
      pageIndex = pageIndex;
    });
  }

  void showCreateTask() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var nameController = TextEditingController();
          var dateDueController = TextEditingController();
          var noteController = TextEditingController();
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
                dateDueController.text =
                    "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}";
              });
            }
          }

          return AlertDialog(
            scrollable: true,
            title: const Text('Create Task'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        icon: Icon(Icons.title),
                      ),
                    ),
                    TextFormField(
                      controller: dateDueController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Due Date (MM/DD/YYYY)',
                        icon: Icon(Icons.date_range),
                      ),
                      onTap: () {
                        selectDate(context);
                      },
                    ),
                    TextFormField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        icon: Icon(Icons.message),
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
                  var name = nameController.text;
                  var dateDue = dateDueController.text;
                  var note = noteController.text;
                  if (name == "" || dateDue == "" || note == "") {
                    messengeBoxShow("Invaild input");
                    return;
                  }

                  MyTask newTask = MyTask();
                  newTask.nameEvent = name;
                  newTask.note = note;
                  newTask.ownerID = currentUser.userID!.toString();
                  newTask.dueDate = dateDue;
                  newTask.sharedID = "";
                  newTask.status = "Pending";

                  try {
                    final taskCollection = db.collection("Tasks");
                    var tasks = taskCollection.doc();
                    newTask.taskID = tasks.id;
                    tasks.set(newTask.toFirestore());
                    final userCollection = db.collection("Users");
                    if (currentUser.taks.isNull || currentUser.taks == "") {
                      currentUser.taks = tasks.id;
                    } else {
                      currentUser.taks = "${currentUser.taks},${tasks.id}";
                    }
                    await userCollection
                        .doc(currentUser.userID)
                        .set(currentUser.toFirestore());
                    messengeBoxShow("Created Task.");
                    updateTaskList();
                    updateState();
                    Navigator.pop(context);
                  } catch (e) {
                    messengeBoxShow("Create Task Error $e");
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        });
  }

  void showAddPeople() {
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
                    messengeBoxShow("Enter Email you want to add");
                    return;
                  }
                  final userCollection = db.collection("Users");
                  try {
                    userCollection.where("email", isEqualTo: email).get().then(
                      (querySnapshot) {
                        if (querySnapshot.docs.isNotEmpty ||
                            email.compareTo(currentUser.email.toString()) ==
                                0) {
                          messengeBoxShow(
                              'This email in invaild. Try another one.');
                        } else {
                          MyUser newUser =
                              MyUser.fromFirestore(querySnapshot.docs[0]);
                          if (!currentUser.contacts!
                              .contains(newUser.userID.toString())) {
                            currentUser.contacts = (currentUser.contacts == ""
                                ? newUser.userID
                                : "${currentUser.contacts},${newUser.userID}");
                            newUser.contacts = (newUser.contacts == ""
                                ? currentUser.userID
                                : "${newUser.contacts},${currentUser.userID}");
                            userCollection
                                .doc(newUser.userID)
                                .set(newUser.toFirestore());
                            userCollection
                                .doc(currentUser.userID)
                                .set(currentUser.toFirestore());
                            messengeBoxShow("Add person sucessful.");
                            updateContactList();
                            setState(() {
                              pageIndex = pageIndex;
                            });
                            Navigator.pop(context);
                          } else {
                            messengeBoxShow("This email already in contacts");
                          }
                        }
                      },
                      onError: (e) =>
                          {messengeBoxShow("Create Error ${e.code}")},
                    );
                  } catch (e) {
                    messengeBoxShow("Create Error $e");
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        });
  }

  void showDeletePeople() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var emailController = TextEditingController();
          return AlertDialog(
            scrollable: true,
            title: const Text('Delete Person'),
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
                    messengeBoxShow("Enter Email your want to remove");
                    return;
                  }
                  final userCollection = db.collection("Users");
                  try {
                    userCollection.where("email", isEqualTo: email).get().then(
                      (querySnapshot) {
                        if (querySnapshot.docs.isEmpty ||
                            email.compareTo(currentUser.email.toString()) ==
                                0) {
                          messengeBoxShow('This email in invaild.');
                        } else {
                          MyUser newUser =
                              MyUser.fromFirestore(querySnapshot.docs[0]);

                          List<String> parts = currentUser.contacts!.split(',');
                          parts.remove(newUser.userID.toString());
                          currentUser.contacts = parts.join(',');

                          parts = newUser.contacts!.split(',');
                          parts.remove(currentUser.userID.toString());
                          newUser.contacts = parts.join(',');

                          newUser.contacts = (newUser.contacts == ""
                              ? currentUser.userID
                              : "${newUser.contacts},${currentUser.userID}");
                          userCollection
                              .doc(newUser.userID)
                              .set(newUser.toFirestore());
                          userCollection
                              .doc(currentUser.userID)
                              .set(currentUser.toFirestore());
                          messengeBoxShow("Delete person sucessful.");

                          updateContactList();
                          setState(() {
                            pageIndex = pageIndex;
                          });
                          Navigator.pop(context);
                        }
                      },
                      onError: (e) => {messengeBoxShow("Error ${e.code}")},
                    );
                  } catch (e) {}
                },
                child: const Text('Delete'),
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

  Widget widgetTaskList() {
    return ListView.builder(
      itemCount: listTasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(arguments: {
                    "taskID": listTasks[index].taskID.toString(),
                  }),
                ));
          },
          leading: const CircleAvatar(
            child: Icon(Icons.task),
          ),
          title: Text((listTasks[index].nameEvent == null
              ? "Task $index"
              : listTasks[index].nameEvent.toString())),
          subtitle: Text(listTasks[index].getSubtitle()),
        );
      },
    );
  }

  Widget widgetContactList() {
    return ListView.builder(
      itemCount: listContacts.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            String msID = "";
            for (int i = 0; i < listChats.length; i++) {
              if (listChats[i]
                      .ownerDetail
                      .userID!
                      .compareTo(listContacts[index].userID.toString()) ==
                  0) {
                msID = listChats[i].msgID.toString();
                break;
              }
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(arguments: {
                    "msID": msID,
                    "sendID": listContacts[index].userID.toString(),
                    "sendName": listContacts[index].name.toString()
                  }),
                ));
          },
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text((listContacts[index].name == null
              ? "Person $index"
              : listContacts[index].name.toString())),
          subtitle: Text((listContacts[index].email == null
              ? "No Email Found"
              : listContacts[index].email.toString())),
        );
      },
    );
  }

  Widget widgetChatList() {
    return ListView.builder(
      itemCount: listChats.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(arguments: {
                    "msID": listChats[index].msgID.toString(),
                    "sendID": listChats[index].ownerDetail.userID.toString(),
                    "sendName": listChats[index].ownerDetail.name.toString()
                  }),
                ));
          },
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text((listChats[index].ownerDetail.name == null
              ? "Chat Index $index"
              : listChats[index].ownerDetail.name.toString())),
          subtitle: Text((listChats[index].listMSG == null
              ? "No Found Last msg"
              : listChats[index].listMSG!.last.data.toString())),
          trailing: Text((listChats[index].listMSG == null
              ? "No Found Time"
              : listChats[index].listMSG!.last.timeSend.toString())),
        );
      },
    );
  }

  Widget myDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue[100],
            ),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.black),
              title: const Text('Account Setting'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountPage(),
                    ));
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.task),
            title: const Text('Task List'),
            onTap: () {
              updateTaskList();
              setState(() {
                pageIndex = 1;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.contacts),
            title: const Text('Contacts'),
            onTap: () {
              updateContactList();
              setState(() {
                pageIndex = 2;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Recent Chat'),
            onTap: () {
              updateChatList();
              setState(() {
                pageIndex = 3;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign Out'),
            onTap: () {
              firebaseAuth.signOut();
              Navigator.pushNamed(context, MyRouter.SignInPage);
            },
          ),
        ],
      ),
    );
  }

  Widget myBody() {
    switch (pageIndex) {
      case 0:
        return widgetLoading();
      case 1:
        return widgetTaskList();
      case 2:
        return widgetContactList();
      case 3:
        return widgetChatList();
      default:
        return const Text("Page not found");
    }
  }

  AppBar myAppBar() {
    return AppBar(
      title: Text(appBarTitle[pageIndex]),
      actions: <Widget>[
        PopupMenuButton<int>(
          onSelected: (item) => appBarClick(item),
          itemBuilder: (context) => appBarAction[pageIndex],
        ),
      ],
    );
  }
}
