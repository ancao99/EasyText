import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../gobal_data.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late FirebaseAuth firebaseAuth;
  @override
  void initState() {
    super.initState();
    // Check is login
    firebaseAuth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // Auth get user id
      if (firebaseAuth.currentUser != null) {
        // User already login, move to Home Page
        Navigator.pushReplacementNamed(context, MyRouter.HomePage);
      }
    });
    if (firebaseAuth.currentUser != null) {
      return widgetLoading();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sign In'),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: ListView(children: [
              const Text('Email',
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: 'Enter your email'),
              ),
              const Text('Password',
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(hintText: 'Enter your password')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                    if (context.mounted) {
                      Navigator.pushNamed(context, MyRouter.HomePage);
                    }
                  } on FirebaseAuthException catch (e) {
                    Fluttertoast.showToast(
                        msg: "Sign In Fail: $e.code",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.red, //text Color
                        fontSize: 16.0 //font size
                        );
                  }
                },
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pushNamed(context, MyRouter.SignUpPage);
                },
                child: const Text('Sign Up'),
              )
            ])),
      );
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
}
