import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../gobal_data.dart';
import '../otherstuff/AuthService.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  bool _isPasswordVisible = false;
  User? _user;
  final AuthService _authService = AuthService();
  String email='';
  String password='';
  String name='';
  String? _errorMessage;
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
        tasks: taks)
        .toFirestore());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.blue[100],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/screen1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: 350,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      onChanged: (value){
                        email=value;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                      onChanged: (value){
                        password=value;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      onChanged: (value){
                        name=value;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async{
                        try {
                          if (email.isEmpty||password.isEmpty){
                            setState(() {
                              _errorMessage='Please enter both email and password!';
                            });
                            return;
                          }
                          setState(() {
                            _errorMessage = null;
                          });
                          final credential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          // First time
                          createUserData(credential.user!.uid, email,
                              name, "", "", "", "");
                          Navigator.pop(context);
                          Navigator.pushNamed(context, MyRouter.HomePage);

                        }
                         catch (e) {
                           setState(() {
                             _errorMessage =
                             'Invalid email of password. Please try again';
                           });
                          print("Sign Up Fail $e.code");
                        }

                      },
                      child: const Text('Sign Up'),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}