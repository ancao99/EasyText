import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../otherstuff/AuthService.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _isPasswordVisible = false;
  User? _user;
  final AuthService _authService = AuthService();
  String email='';
  String password='';
  String? _errorMessage;

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
                width: 200,
                height: 300,
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
                    ElevatedButton(
                      onPressed: () async{
                        if (email.isEmpty||password.isEmpty){
                          setState(() {
                            _errorMessage='Please enter both email and password!';
                          });
                          return;
                        }
                        setState(() {
                          _errorMessage = null;
                        });
                        UserCredential? userCredential =await _authService.signUpWithEmailAndPassword(email, password);
                        if(userCredential!=null){
                          _user =userCredential.user;
                          Navigator.pushNamed(context,'/logIn');
                        }
                        else{
                          setState(() {
                            _errorMessage='Invalid email of password. Please try again';
                          });
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