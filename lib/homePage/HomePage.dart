// Home Page is Task Page, show all task as default
// Drawer move to COntact or recent chat page
// Home page bottom is action

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../gobal_data.dart';

import '../subPages/AccountPage.dart';
import '../subPages/TaskPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var db = FirebaseFirestore.instance;
  var firebaseAuth = FirebaseAuth.instance;
  StreamSubscription<DocumentSnapshot>? listener;
  bool listenerCreate = false;
  var pageIndex = 0;
  bool isLoading = true;
  MyUser currentUser = MyUser();
  List<MyUser> listContacts = List<MyUser>.empty(growable: true);
  List<MyTask> listTasks = List<MyTask>.empty(growable: true);
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
  ];
  List appBarTitle = ["Loading", "Task List", "Contacts"];
  List appBarMap = [
    [""],
    ["Create Task", "Sort by Due Date"],
    ["Add People", "Delete People"],
  ];

  setUpListener() {
    final userCollection = db.collection("Users");
    userCollection
        .doc(firebaseAuth.currentUser!.uid)
        .snapshots()
        .listen((event) async {
      messengeBoxShow("updating");
      try {
        setState(() {
          isLoading = true;
        });
        await updateCurrentUser();
        await updateTaskList();
        await updateContactList();
        setState(() {
          isLoading = false;
          pageIndex = (pageIndex == 0 ? 1 : pageIndex);
        });
      } catch (e) {}
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

  @override
  Widget build(BuildContext context) {
    // let make page flexible change as state update by data and slected index
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // Auth get user id
      if (firebaseAuth.currentUser == null) {
        // User not login
        Navigator.pushReplacementNamed(context, MyRouter.SignInPage);
      } else {
        if (!listenerCreate) {
          listener = setUpListener();
          listenerCreate = true;
        }
      }
    });
    if (isLoading) {
      return Scaffold(body: widgetLoading());
    } else {
      return Scaffold(appBar: myAppBar(), drawer: myDrawer(), body: myBody());
    }
  }

  AppBar myAppBar() {
    if (appBarMap[pageIndex][0] == "") {
      return AppBar(title: Text(appBarTitle[pageIndex]));
    } else {
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

  Widget myPicture() {
    if (currentUser.pictureCode != null && currentUser.pictureCode != "") {
      return Container(
        width: 80,
        padding: const EdgeInsets.all(10),
        child: Image.memory(
          base64Decode(currentUser.pictureCode.toString()),
          fit: BoxFit.fill,
          width: 80,
        ),
      );
    } else {
      return const Icon(Icons.person, color: Colors.black);
    }
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
              leading: myPicture(),
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
              Navigator.pop(context);
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
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign Out'),
            onTap: () async {
              await firebaseAuth.signOut();
              setState(() {
                listener!.cancel();
              });
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
      default:
        return const Text("Page not found");
    }
  }

// Update Database section
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
      if (currentUser.userID == null || currentUser.userID == "") {
        // Let create this user
        userCollection.doc(firebaseAuth.currentUser!.uid).set(MyUser(
                userID: firebaseAuth.currentUser!.uid,
                email: firebaseAuth.currentUser!.email,
                name: "Auto Create",
                chats: "",
                contacts: "",
                pictureCode: "",
                taks: "")
            .toFirestore());
        return;
      }
    } catch (e) {
      //messengeBoxShow("Current user Error $e");
    }
  }

  updateTaskList() async {
    try {
      final taskCollection = db.collection("Tasks");
      // build task
      if (currentUser.taks == null || currentUser.taks == "") {
        await updateCurrentUser();
        if (currentUser.taks == null || currentUser.taks == "") {
          messengeBoxShow("Task List Empty");
        }
      } else {
        var tasksIndex = currentUser.taks!.split(",");
        bool needCorrection = false;
        var tasksIndexCorrection = currentUser.taks!.split(",");
        List<MyTask> tmplistTasks = List<MyTask>.empty(growable: true);
        for (int i = 0; i < tasksIndex.length; i++) {
          await taskCollection.doc(tasksIndex[i]).get().then(
            (value) {
              MyTask tmp = MyTask.fromFirestore(value);
              if (tmp.taskID == null || tmp.taskID == "") {
                needCorrection = true;
                tasksIndexCorrection.remove(tasksIndex[i]);
              } else {
                tmplistTasks.add(tmp);
              }
            },
          );
        }
        listTasks = tmplistTasks;
        // run correction
        if (needCorrection) {
          currentUser.taks = tasksIndexCorrection.toSet().toList().join(",");

          final userCollection = db.collection("Users");
          await userCollection
              .doc(currentUser.userID)
              .set(currentUser.toFirestore());
        }
      }
    } catch (e) {
      //messengeBoxShow("Task List Error $e");
    }
  }

  updateContactList() async {
    try {
      final userCollection = db.collection("Users");
      // build contact
      if (currentUser.contacts == null || currentUser.contacts == "") {
        //messengeBoxShow("Contact List Empty");
      } else {
        var contactsIndex = currentUser.contacts!.split(",");
        bool needCorrection = false;
        var contactsIndexCorrection = currentUser.contacts!.split(",");
        List<MyUser> tmplistContacts = List<MyUser>.empty(growable: true);
        for (int i = 0; i < contactsIndex.length; i++) {
          await userCollection.doc(contactsIndex[i]).get().then(
            (value) {
              var tmp = MyUser.fromFirestore(value);
              if (tmp.userID == null || tmp.userID == "") {
                needCorrection = true;
                contactsIndexCorrection.remove(contactsIndex[i]);
              } else {
                tmplistContacts.add(tmp);
              }
            },
          );
        }
        listContacts = tmplistContacts;
        // run correction
        if (needCorrection) {
          currentUser.contacts =
              contactsIndexCorrection.toSet().toList().join(",");
          final userCollection = db.collection("Users");
          await userCollection
              .doc(currentUser.userID)
              .set(currentUser.toFirestore());
        }
      }
    } catch (e) {
      messengeBoxShow("Contact list Error $e");
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

// Action Bar action Section
  showCreateTask() {
    var nameController = TextEditingController();
    var dateDueController = TextEditingController();
    var detailController = TextEditingController();
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

    createTask() async {
      var name = nameController.text;
      var dateDue = dateDueController.text;
      var detail = detailController.text;
      if (name == "" || dateDue == "" || detail == "") {
        messengeBoxShow("Invalid input");
        return false;
      }

      MyTask newTask = MyTask();
      newTask.nameEvent = name;
      newTask.detail = detail;
      newTask.ownerID = currentUser.userID;
      newTask.dueDate = dateDue;
      newTask.sharedID = "";
      newTask.note = "";
      newTask.status = "Pending";

      try {
        final taskCollection = db.collection("Tasks");
        var tasks = taskCollection.doc();
        newTask.taskID = tasks.id;
        tasks.set(newTask.toFirestore());
        if (currentUser.taks == null || currentUser.taks == "") {
          currentUser.taks = tasks.id;
        } else {
          currentUser.taks = "${currentUser.taks},${tasks.id}";
        }

        final userCollection = db.collection("Users");
        userCollection.doc(currentUser.userID).set(currentUser.toFirestore());
        messengeBoxShow("Created Task.");
        return true;
      } catch (e) {
        messengeBoxShow("Create Task Error $e");
      }
      return false;
    }

    createTaskButton() {
      createTask().then((value) {
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
                    controller: detailController,
                    decoration: const InputDecoration(
                      labelText: 'Mission',
                      icon: Icon(Icons.message),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: createTaskButton,
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  showAddPeople() {
    var emailController = TextEditingController();
    addPeople() async {
      var email = emailController.text;
      if (email == "") {
        messengeBoxShow("Enter Email you want to add");
        return false;
      }
      if (email.compareTo(currentUser.email.toString()) == 0) {
        messengeBoxShow('Can not add yourselft');
        return false;
      }
      try {
        final userCollection = db.collection("Users");
        var querySnapshot =
            await userCollection.where("email", isEqualTo: email).get();
        if (querySnapshot.docs.isEmpty) {
          messengeBoxShow('Not found this Preson');
          return false;
        }
        MyUser newUser = MyUser.fromFirestore(querySnapshot.docs[0]);
        // check is in contact
        if (currentUser.contacts != null) {
          if (currentUser.contacts!.contains(newUser.userID.toString())) {
            messengeBoxShow("This email already in contact");
            return false;
          }
        }
        // add target to me
        if (currentUser.contacts == null || currentUser.contacts == "") {
          currentUser.contacts = newUser.userID;
        } else {
          List<String> parts = currentUser.contacts!.split(',');
          parts.add(newUser.userID.toString());
          currentUser.contacts = parts.toSet().toList().join(',');
        }
        // add me to target
        if (newUser.contacts == null || newUser.contacts == "") {
          newUser.contacts = currentUser.userID;
        } else {
          List<String> parts = newUser.contacts!.split(',');
          parts.add(currentUser.userID.toString());
          newUser.contacts = parts.toSet().toList().join(',');
        }
        // push to target
        userCollection.doc(newUser.userID).set(newUser.toFirestore());
        // push to me
        userCollection.doc(currentUser.userID).set(currentUser.toFirestore());
        messengeBoxShow("Add person sucessful.");
        return true;
      } catch (e) {
        messengeBoxShow("Create Error $e");
      }
      return false;
    }

    addPeopleButton() {
      addPeople().then((value) {
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
                onPressed: addPeopleButton,
                child: const Text('Create'),
              ),
            ],
          );
        });
  }

  showDeletePeople() {
    var emailController = TextEditingController();
    // Button set up
    deletePeople() async {
      var email = emailController.text;
      if (email == "") {
        messengeBoxShow("Enter Email your want to remove");
        return false;
      }
      if (email.compareTo(currentUser.email.toString()) == 0) {
        messengeBoxShow('Yourself is not in contact');
        return false;
      }
      try {
        final userCollection = db.collection("Users");
        var querySnapshot =
            await userCollection.where("email", isEqualTo: email).get();
        if (querySnapshot.docs.isEmpty) {
          messengeBoxShow('Not found this Person');
          return false;
        }
        MyUser newUser = MyUser.fromFirestore(querySnapshot.docs[0]);
        if (currentUser.contacts == null || currentUser.contacts == "") {
          messengeBoxShow("This people not in contact");
          return false;
        }
        // delete  target in me
        List<String> parts = currentUser.contacts!.split(',');
        parts.remove(newUser.userID.toString());
        currentUser.contacts = parts.toSet().toList().join(',');
        // delete me in target
        if (newUser.contacts == null) {
          newUser.contacts = "";
        } else {
          parts = newUser.contacts!.split(',');
          parts.remove(currentUser.userID.toString());
          newUser.contacts = parts.toSet().toList().join(',');
        }
        // push to target
        userCollection.doc(newUser.userID).set(newUser.toFirestore());
        //push to me
        userCollection.doc(currentUser.userID).set(currentUser.toFirestore());
        messengeBoxShow("Delete person sucessful.");
        return true;
      } catch (e) {
        messengeBoxShow("Delete Preson error $e");
      }
      return false;
    }

    deletePeopleButton() {
      deletePeople().then((value) {
        if (value == true) {
          Navigator.pop(context);
        }
      });
    }

    // Sow Dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
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
                onPressed: deletePeopleButton,
                child: const Text('Delete'),
              ),
            ],
          );
        });
  }

  showContactOption(index) {
    String addTaskID = "";
    MyUser targetUser = listContacts[index];
    // Delete current people
    deletePeople() async {
      try {
        final userCollection = db.collection("Users");
        // delete  target in me
        List<String> parts = currentUser.contacts!.split(',');
        parts.remove(targetUser.userID.toString());
        currentUser.contacts = parts.toSet().toList().join(',');
        // delete me in target
        if (targetUser.contacts == null) {
          targetUser.contacts = "";
        } else {
          parts = targetUser.contacts!.split(',');
          parts.remove(currentUser.userID.toString());
          targetUser.contacts = parts.toSet().toList().join(',');
        }
        // push to target
        userCollection.doc(targetUser.userID).set(targetUser.toFirestore());
        //push to me
        userCollection.doc(currentUser.userID).set(currentUser.toFirestore());
        messengeBoxShow("Delete person sucessful.");
        return true;
      } catch (e) {
        messengeBoxShow("Create Error $e");
      }
      return false;
    }

    deletePeopleButton() {
      deletePeople().then((value) {
        if (value == true) {
          Navigator.pop(context);
        }
      });
    }

    // Add to Task
    addToTask() async {
      try {
        final taskCollection = db.collection("Tasks");
        final userCollection = db.collection("Users");

        // add Task to target
        if (targetUser.taks == null || targetUser.taks == "") {
          targetUser.taks = addTaskID;
        } else {
          List<String> parts = targetUser.taks!.toString().split(',');
          parts.add(addTaskID);
          targetUser.taks = parts.toSet().toList().join(",");
        }
        // add Target to ShareList
        MyTask currentTask = listTasks[listTasks.indexWhere(
            (element) => element.taskID!.compareTo(addTaskID) == 0)];

        if (currentTask.sharedID == null || currentTask.sharedID == "") {
          currentTask.sharedID = targetUser.userID;
        } else {
          List<String> parts = currentTask.sharedID!.toString().split(',');
          parts.add(targetUser.userID.toString());
          currentTask.sharedID = parts.toSet().toList().join(",");
        }
        // push data
        await userCollection
            .doc(targetUser.userID)
            .set(targetUser.toFirestore());
        await taskCollection
            .doc(currentTask.taskID)
            .set(currentTask.toFirestore());
        messengeBoxShow("Add to Task Success");
        return true;
      } catch (e) {
        messengeBoxShow("Create Error $e");
      }
      return false;
    }

    addToTaskButton() {
      addToTask().then((value) {
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
            title: Text(listContacts[index].email.toString()),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(children: <Widget>[
                  DropdownButton<String>(
                    icon: const Icon(Icons.task),
                    items: listTasks
                        .where((MyTask thisTask) =>
                            thisTask.ownerID!
                                .compareTo(currentUser.userID.toString()) ==
                            0)
                        .map((MyTask thisTask) {
                      return DropdownMenuItem<String>(
                        value: thisTask.taskID,
                        child: Text(thisTask.nameEvent.toString()),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        addTaskID = newValue ?? '';
                      });
                    },
                  ),
                ]),
              ),
            ),
            actions: [
              TextButton(
                onPressed: addToTaskButton,
                child: const Text('Add to Task'),
              ),
              TextButton(
                onPressed: deletePeopleButton,
                child: const Text('Delete People'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        });
  }

// BOdy render section
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
                  builder: (context) => TaskPage(arguments: {
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
            // Show personal information
            showContactOption(index);
          },
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(((listContacts[index].name == null ||
                  listContacts[index].name == "")
              ? "Person $index"
              : listContacts[index].name.toString())),
          subtitle: Text((listContacts[index].email == null
              ? "No Email Found"
              : listContacts[index].email.toString())),
        );
      },
    );
  }

// Useful function
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
