import 'package:flutter/material.dart';

class LogOut extends StatelessWidget {
  const LogOut({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Log Out',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.blue[100],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/logout.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'You are logged out',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    const Text(
                      'Do you want to sign in? ',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print('Sign In');
                        Navigator.pushNamed(context, '/registerPage');
                      },
                      child: const Text('Sign In'),
                    ),
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