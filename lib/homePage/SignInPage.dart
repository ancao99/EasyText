import 'package:flutter/material.dart';
import 'package:mess_app/homePage/HomeScreen.dart';
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image:AssetImage('assets/screen1.jpg'),
                  fit:BoxFit.cover
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.login_rounded),
                  title: const Text('Log In',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                  onTap: () {
                    Navigator.pushNamed(context, '/logIn');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.login_rounded),
                  title: const Text('Sign Up',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                  onTap: () {
                    Navigator.pushNamed(context, '/signIn');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}