import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../gobal_data.dart';

class ChatPage extends StatefulWidget {
  final Map<String, String> arguments;
  const ChatPage({super.key, required this.arguments});
  //const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  var db = FirebaseFirestore.instance;
  var firebaseAuth = FirebaseAuth.instance;

  MyTask currentTask = MyTask();
  String taskID = "";
  String currentID = "";
  List<SMS> listSMS = List<SMS>.empty(growable: true);
  // sert up listener
  StreamSubscription<DocumentSnapshot>? listener;
  bool listenerCreated = false;
  bool isLoading = true;

  setUpListener() {
    final listSMSCollection = FirebaseFirestore.instance
        .collection('Messages')
        .doc(taskID)
        .collection("listSMS");
    listSMSCollection.snapshots().listen((querySnapshot) async {
      try {
        await updateListSMS(querySnapshot);
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        //do nothing
      }
    });
  }

  updateListSMS(var querySnapshot) async {
    final taskCollection = db.collection("Tasks");
    // Update task infor
    await taskCollection.doc(taskID).get().then((value) {
      currentTask = MyTask.fromFirestore(value);
    });
    // Update SMS
    final userCollection = db.collection("Users");
    for (var docChange in querySnapshot.docChanges) {
      // data first
      SMS newSMS = SMS.fromFirestore(docChange.doc);
      await userCollection.doc(newSMS.fromID).get().then((value) {
        MyUser tmpUser = MyUser.fromFirestore(value);
        newSMS.senderName = tmpUser.name.toString();
      });
      // handel
      if (docChange.type == DocumentChangeType.added) {
        // add to list

        listSMS.add(newSMS);
      } else if (docChange.type == DocumentChangeType.modified) {
        // edit to list
        var i = listSMS.indexWhere((sms) => sms.msgID == newSMS.msgID);
        if (i >= 0) {
          listSMS[i] = newSMS;
        }
      } else if (docChange.type == DocumentChangeType.removed) {
        // remove at list
        listSMS.removeWhere((sms) => sms.msgID == newSMS.msgID);
      }
    }
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
          currentID = firebaseAuth.currentUser!.uid;
          listener = setUpListener();
          listenerCreated = true;
        }
      }
    });
    if (isLoading) {
      return Scaffold(body: widgetLoading());
    }
    return Scaffold(appBar: myAppBar(), body: widgetChatingList());
  }

  myAppBar() {
    return AppBar(
      title: Text(currentTask.nameEvent.toString()),
    );
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

  Widget widgetChatingList() {
    TextEditingController textEditingController = TextEditingController();

    // Button Send
    send() async {
      try {
        final msgCollection = db.collection("Messages");
        final smsCollection =
            msgCollection.doc(taskID).collection("listSMS").doc();
        // Create SMS
        SMS newSMS = SMS(
            msgID: smsCollection.id,
            fromID: currentID,
            data: textEditingController.text,
            timeSend: DateTime.now().millisecondsSinceEpoch.toString());
        // Push data
        smsCollection.set(newSMS.toFirestore());
        return true;
      } catch (e) {
        messengeBoxShow("Chat Send Error $e");
      }
      return false;
    }

    sendButton() {
      String text = textEditingController.text.trim();
      if (text.isNotEmpty) {
        // Analyzing msg, call Weather API
        // Push data
        send().then((value) {
          if (value == true) {
            textEditingController.clear();
          }
        });
      }
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: listSMS.length,
            itemBuilder: (context, index) {
              // Build your list item here using the data from the documents.
              SMS newSMS = listSMS[index];
              bool isMe = newSMS.fromID!.compareTo(currentID) == 0;
              return ListTile(
                title: Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            newSMS.senderName.toString(),
                            style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            newSMS.data.toString(),
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      )),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: sendButton,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // USeful function
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
