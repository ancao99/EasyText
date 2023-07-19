import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global_data.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  createUserData(
      userID, email, name, pictureCode, chats, contacts, taks) async {
    var db = FirebaseFirestore.instance;
    await db.collection("Users").doc(userID.toString()).set(MyUser(
            userID: userID,
            email: email,
            name: name,
            pictureCode: pictureCode,
            chats: chats,
            contacts: contacts,
            taks: taks)
        .toFirestore());
  }

  @override
  void initState() {
    super.initState();
    // Check is login
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    if (firebaseAuth.currentUser != null) {
      // User already login, move to Home Page
      Navigator.pushNamed(context, MyRouter.HomePage);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.blue[100],
      ),
      body: Container(
          padding: const EdgeInsets.all(20.0),
          child: ListView(children: [
            const Text('Email',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(hintText: 'Enter your Email'),
            ),
            const Text('Password',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            TextField(
                controller: passwordController,
                decoration:
                    const InputDecoration(hintText: 'Enter your password')),
            const Text('Name',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Enter your Name'),
            ),
            const SizedBox(height: 16),
            // Picuture
            ElevatedButton(
              onPressed: () {},
              child: Container(
                width: 80,
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'assets/default.png',
                  width: 80,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  final credential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  // First time
                  createUserData(credential.user!.uid, emailController.text,
                      nameController.text, "", "", "", "");

                  if (context.mounted) {
                    Navigator.pushNamed(context, MyRouter.HomePage);
                  }
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    messengeBoxShow('The password provided is too weak.');
                  } else if (e.code == 'email-already-in-use') {
                    messengeBoxShow(
                        'The account already exists for that email.');
                  }
                } catch (e) {
                  messengeBoxShow("Sign Up Fail $e.code");
                }
              },
              child: const Text('Register'),
            ),
          ])),
    );
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
