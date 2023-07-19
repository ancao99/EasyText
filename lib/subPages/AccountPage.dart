import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

  // Firbase listen
  StreamSubscription<DocumentSnapshot>? _listener;
  bool listenerCreated = false;
  bool isLoading = true;
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
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        messengeBoxShow("Error $e");
      }
    });
  }

  updateCurrentUser() async {
    final userCollection = db.collection("Users");
    await userCollection.doc(firebaseAuth.currentUser!.uid).get().then(
      (value) {
        currentUser = MyUser.fromFirestore(value);
      },
    );
  }

  @override
  void dispose() {
    _listener?.cancel();
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
          _listener = setUpListener();
          listenerCreated = true;
        }
      }
    });

    if (isLoading) {
      return Scaffold(body: widgetLoading());
    } else {
      return Scaffold(appBar: myAppBar(), body: widgetProfileList());
    }
  }

  myAppBar() {
    return AppBar(
      title: const Text("My Profile"),
    );
  }

  // Widget Section
  Widget widgetLoading() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 1.3,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget widgetProfileList() {
    TextEditingController emailController =
        TextEditingController(text: currentUser.email);
    TextEditingController nameController =
        TextEditingController(text: currentUser.name);
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();

    saveChange() async {
      if (nameController.text == "") {
        messengeBoxShow("Name can not be empty");
        return;
      }

      // Update password
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
          messengeBoxShow("Can not update password. Error:$e");
          return;
        }
      }
      // let update name and picture
      currentUser.name = nameController.text;
      // Push data
      try {
        final userCollection = db.collection("Users");
        await userCollection
            .doc(currentUser.userID)
            .set(currentUser.toFirestore());
        messengeBoxShow("Updated succesful");
      } catch (e) {
        messengeBoxShow("Can not update information. Error:$e");
      }
    }

    saveChangeButton() {
      saveChange().then((value) {});
    }

    //Pick image button
    Future<String> convertToBase64(File file) async {
      List<int> imageBytes = await file.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      return base64Image;
    }

    Future<void> pickImage(ImageSource source) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      try {
        if (pickedFile != null) {
          File imageFile = File(pickedFile.path);
          currentUser.pictureCode = await convertToBase64(imageFile);
        }
      } catch (e) {
        messengeBoxShow("Image error $e");
      }
      Navigator.pop(context);
    }

    return SingleChildScrollView(
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
            decoration: const InputDecoration(labelText: 'Your Name'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Profile Picture:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // Add profile picture selection widget here (e.g., ImagePicker)
          if (currentUser.pictureCode != null && currentUser.pictureCode != "")
            Container(
              width: 80,
              padding: const EdgeInsets.all(10),
              child: Image.memory(
                base64Decode(currentUser.pictureCode.toString()),
                fit: BoxFit.fill,
                width: 80,
              ),
            ),
          if (currentUser.pictureCode == null || currentUser.pictureCode == "")
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Choose from Gallery'),
              onTap: () {
                pickImage(ImageSource.gallery);
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
            decoration: const InputDecoration(labelText: 'New Password'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: saveChangeButton,
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  // Useful Function Section

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
