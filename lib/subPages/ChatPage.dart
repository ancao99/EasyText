import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mess_app/gobal_data.dart';

class ChatPage extends StatefulWidget {
  final Map<String, String> arguments;
  const ChatPage({super.key, required this.arguments});
  //const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var db = FirebaseFirestore.instance;
  var firebaseAuth = FirebaseAuth.instance;
  MyChat currentChat = MyChat();
  String sendID = "";
  String sendName = "";
  String currentID = "";
  String msgID = "";
  int page_index = 0;

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
      sendID = widget.arguments['sendID'].toString();
      sendName = widget.arguments['sendName'].toString();
      msgID = widget.arguments['msID'].toString();
      currentID = firebaseAuth.currentUser!.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    currentChat = ModalRoute.of(context)!.settings.arguments as MyChat;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // Auth get user id
      await loadingMyDataBase();
      //listUsers = await getAllUsers();
    });
    return Scaffold(key: _scaffoldKey, appBar: myAppBar(), body: myBody());
  }

  Future<void> updateAll() async {
    //Mission loading my user and blindding data.
    final msgCollection = db.collection("Messages");
    if (msgID == "") {
      //new chat box
      currentChat.msgID = "";
      currentChat.owner = "${firebaseAuth.currentUser!.uid},$sendID";
      currentChat.listMSG = List.empty();
    } else {
      //loading previous messenge
      await msgCollection.doc(msgID).get().then((value) {
        currentChat = MyChat.fromFirestore(value);
      });
    }
    setState(() {
      page_index = 1;
    });
  }

  Future<void> loadingMyDataBase() async {
    updateAll();
    final msgCollection = db.collection("Messages");
    // add listen for user:
    msgCollection.doc(currentChat.msgID).snapshots().listen((event) {
      updateAll();
    });
  }

  myAppBar() {
    return AppBar(
      title: Text(sendName),
    );
  }

  Future<void> addMessage(String text, bool isSender) async {
    final userCollection = db.collection("Users");
    final msgCollection = db.collection("Messages");
    if (currentChat.msgID == "") {
      //new one, let initail msgID
      var newID = msgCollection.doc();
      currentChat.msgID = newID.id.toString();
      currentChat.listMSG!.add(MSG(
          msgID: msgID,
          fromID: currentID,
          data: text,
          timeSend: DateTime.now().millisecondsSinceEpoch.toString()));
      newID.set(currentChat.toFirestore());
      // add msgID to UserData
      await userCollection.doc(sendID).get().then(
        (value) {
          MyUser sender = MyUser.fromFirestore(value);
          sender.chats = (sender.chats == ""
              ? currentChat.msgID
              : "${sender.chats},${currentChat.msgID}");
        },
      );
      await userCollection.doc(currentID).get().then(
        (value) {
          MyUser me = MyUser.fromFirestore(value);
          me.chats = (me.chats == ""
              ? currentChat.msgID
              : "${me.chats},${currentChat.msgID}");
        },
      );
    } else {
      currentChat.listMSG!.add(MSG(
          msgID: msgID,
          fromID: currentID,
          data: text,
          timeSend: DateTime.now().millisecondsSinceEpoch.toString()));
      await userCollection
          .doc(currentChat.msgID)
          .set(currentChat.toFirestore());
    }
    setState(() {
      page_index = 1;
    });
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
    switch (page_index) {
      case 0:
        return widgetLoading();
      case 1:
        return widgetChatingList();
      default:
        return const Text("Page not found");
    }
  }

  Widget widgetChatingList() {
    TextEditingController textEditingController = TextEditingController();
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: currentChat.listMSG!.length,
            itemBuilder: (context, index) {
              MSG cur = currentChat.listMSG![index];
              return ListTile(
                title: Align(
                  alignment: sendID.compareTo(cur.fromID.toString()) == 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: sendID.compareTo(cur.fromID.toString()) == 0
                          ? Colors.blue
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      cur.data.toString(),
                      style: TextStyle(
                        color: sendID.compareTo(cur.fromID.toString()) == 0
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
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
                onPressed: () {
                  String text = textEditingController.text.trim();
                  if (text.isNotEmpty) {
                    addMessage(text, true); // Set isSender to true
                    textEditingController.clear(); // Clear the input field
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
