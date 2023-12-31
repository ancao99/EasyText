import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DefaultTheme {
  static const Color scaffoldBackgroundColor = Colors.white;
  static const MaterialColor primarySwatch = Colors.lightBlue;
}

String weatherAPIkey = "0ada24b016fe4d1b92a20955231907";

class MyRouter {
  static const String CoverPage = '/';
  static const String SignUpPage = '/signUp';
  static const String SignInPage = '/signIn';
  static const String HomePage = '/HomePage';
  static const String TaskPage = '/task';
  static const String ChatPage = '/chat';
  static const String ContactPage = '/contact';
}

class Profile {
  final String currentUserID;
  final MyUser userShowing;
  Profile(this.currentUserID, this.userShowing);
}

// Chats documents
class SMS {
  String? msgID;
  String? fromID;
  String senderName = "";
  String? data;
  String? timeSend;
  SMS({this.msgID, this.fromID, this.timeSend, this.data});
  Map<String, dynamic> toJson() {
    return {
      'msgID': msgID,
      'fromID': fromID,
      'data': data,
      'timeSend': timeSend,
    };
  }

//Firebase Cloud Data Decode Map
  factory SMS.fromFirestoreMap(Map<String, dynamic> data) {
    return SMS(
      msgID: data['msgID'],
      fromID: data['fromID'],
      timeSend: data['timeSend'],
      data: data['data'],
    );
  }
  //Firebase Cloud Data Decode
  factory SMS.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return SMS(
      msgID: data?['msgID'],
      fromID: data?['fromID'],
      timeSend: data?['timeSend'],
      data: data?['data'],
    );
  }
  //Firebase Cloud Data Encode Map
  Map<String, dynamic> toFirestore() {
    return {
      if (msgID != null) "msgID": msgID,
      if (fromID != null) "fromID": fromID,
      if (timeSend != null) "timeSend": timeSend,
      if (data != null) "data": data,
    };
  }
}
// Tasks Document

class MyTask {
  String? taskID;
  String? nameEvent;
  String? detail;
  String? ownerID;
  String? sharedID;
  String? note;
  String? dueDate;
  String? status;
  MyTask({
    this.taskID,
    this.nameEvent,
    this.detail,
    this.ownerID,
    this.sharedID,
    this.note,
    this.dueDate,
    this.status,
  });
  String getSubtitle() {
    String result =
        "Due date: $dueDate\nMission: ${(detail == null || detail == "") ? "unkown" : detail}\nNote: ${(note == null || note == "") ? "nothing" : note}\n";
    return result;
  }

  //Firebase Cloud Data Decode
  factory MyTask.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return MyTask(
      taskID: data?['taskID'],
      nameEvent: data?['nameEvent'],
      detail: data?['detail'],
      ownerID: data?['ownerID'],
      sharedID: data?['sharedID'],
      note: data?['note'],
      dueDate: data?['dueDate'],
      status: data?['status'],
    );
  }

  //Firebase Cloud Data Encode
  Map<String, dynamic> toFirestore() {
    return {
      if (taskID != null) "taskID": taskID,
      if (nameEvent != null) "nameEvent": nameEvent,
      if (detail != null) "detail": detail,
      if (ownerID != null) "ownerID": ownerID,
      if (sharedID != null) "sharedID": sharedID,
      if (note != null) "note": note,
      if (dueDate != null) "dueDate": dueDate,
      if (status != null) "status": status,
    };
  }

  DateTime getDueDateAsDateTime() {
    // Assuming the dueDate format is "MM/DD/YYYY"
    List<String> dateParts = dueDate!.split('/');
    int month = int.parse(dateParts[0]);
    int day = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]);
    return DateTime(year, month, day);
  }
}
// My User main tree

class MyUser {
  String? userID;
  String? email;
  String? name;
  String? pictureCode;
  String? chats;
  String? contacts;
  String? tasks;
  MyUser(
      {this.userID,
        this.email,
        this.name,
        this.pictureCode,
        this.chats,
        this.contacts,
        this.tasks});

  //Firebase Cloud Data Decode
  factory MyUser.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return MyUser(
      userID: data?['userID'],
      email: data?['email'],
      name: data?['name'],
      pictureCode: data?['pictureCode'],
      chats: data?['chats'],
      contacts: data?['contacts'],
      tasks: data?['tasks'],
    );
  }

  //Firebase Cloud Data Encode
  Map<String, dynamic> toFirestore() {
    return {
      if (userID != null) "userID": userID,
      if (email != null) "email": email,
      if (name != null) "name": name,
      if (pictureCode != null) "pictureCode": pictureCode,
      if (chats != null) "chats": chats,
      if (contacts != null) "contacts": contacts,
      if (tasks != null) "tasks": tasks,
    };
  }
}

class Screen {
  static double getMaxWidth(context) {
    return MediaQuery.of(context).size.width;
  }

  static double getMaxHeight(context) {
    return MediaQuery.of(context).size.height;
  }
}