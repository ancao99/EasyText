import 'dart:convert';
import 'dart:io';
import 'dart:js_interop';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../gobal_data.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  var db = FirebaseFirestore.instance;
  var firebaseAuth = FirebaseAuth.instance;
  MyUser currentUser = MyUser();
  int pageIndex = 0;
  File? imageFile;
  bool isLoading = true;
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
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // Auth get user id
      await loadingMyDataBase();
      //listUsers = await getAllUsers();
    });
    return Scaffold(appBar: myAppBar(), body: myBody());
  }

  updateCurrentUser() async {
    try {
      final userCollection = db.collection("Users");
      await userCollection.doc(firebaseAuth.currentUser!.uid).get().then(
        (value) {
          currentUser = MyUser.fromFirestore(value);
        },
      );
    } catch (e) {
      messengerBoxShow("Current user Error $e");
    }
  }

  updateState() {
    setState(() {
      pageIndex = pageIndex;
    });
  }

  Future<void> loadingMyDataBase() async {
    setState(() {
      pageIndex = 1;
    });
    if (isLoading) {
      final userCollection = db.collection("Users");
      // add listen for user:
      await userCollection
          .doc(firebaseAuth.currentUser!.uid)
          .snapshots()
          .listen((event) {
        updateCurrentUser();
      });
      isLoading = false;
    }
  }

  Widget widgetLoading() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 1.3,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  myAppBar() {
    return AppBar(
      title: const Text("My Profile"),
    );
  }

  myBody() {
    switch (pageIndex) {
      case 0:
        return widgetLoading();
      case 1:
        return widgetProfileList();
      default:
        return const Text("Page not found");
    }
  }

  Future<String> convertToBase64(File file) async {
    List<int> imageBytes = await file.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    try {
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        currentUser.pictureCode = await convertToBase64(imageFile);
        setState(() {
          imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      messengerBoxShow("Image error $e");
    }
  }

  Widget widgetProfileList() {
    TextEditingController emailController =
        TextEditingController(text: currentUser.email.toString());
    TextEditingController nameController =
        TextEditingController(text: currentUser.name.toString());
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Email:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextFormField(
            controller: emailController,
            readOnly: true,
          ),
          const SizedBox(height: 16),
          const Text(
            'Name:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextFormField(
            controller: nameController,
          ),
          const SizedBox(height: 16),
          const Text(
            'Profile Picture:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          // Add profile picture selection widget here (e.g., ImagePicker)
          if (!(currentUser.pictureCode.isNull ||
              currentUser.pictureCode == ""))
            Container(
              width: 80,
              padding: const EdgeInsets.all(10),
              child: Image.memory(
                base64Decode(currentUser.pictureCode.toString()),
                fit: BoxFit.fill,
                width: 80,
              ),
            ),
          if (currentUser.pictureCode == "")
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Choose from Gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),

          const SizedBox(height: 16),
          const Text(
            'Change Password:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextFormField(
            controller: currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Current Password'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text == "") {
                messengerBoxShow("Name can not be empty");
                return;
              }
              // let update name and picture first
              currentUser.name = nameController.text;
              final userCollection = db.collection("Users");
              await userCollection
                  .doc(currentUser.userID)
                  .set(currentUser.toFirestore());
              if (newPasswordController.text != "" &&
                  currentPasswordController.text != "") {
                try {
                  AuthCredential credential = EmailAuthProvider.credential(
                      email: currentUser.email!,
                      password: currentPasswordController.text);
                  await firebaseAuth.currentUser!
                      .reauthenticateWithCredential(credential);
                  await firebaseAuth.currentUser!
                      .updatePassword(newPasswordController.text);
                } catch (e) {
                  messengerBoxShow("Can not update password. Error:$e");
                }
              }
              messengerBoxShow("Updated succesful");
              updateCurrentUser();
              updateState();
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void messengerBoxShow(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}
