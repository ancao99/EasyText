import 'package:flutter/material.dart';
class LogOut extends StatelessWidget {
  const LogOut({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100], // Set the background color here
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'You are logged out',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'Do you want to log in? ',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    print('Log In');
                    Navigator.pushNamed(context, '/logIn');
                  },
                  child: const Text('Log In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}