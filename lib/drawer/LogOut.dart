import 'package:flutter/material.dart';

class LogOut extends StatelessWidget {
  const LogOut({Key? key}) : super(key: key);

  // Function to handle the log-out process
  void _handleLogOut(BuildContext context) {
    // TODO: Add your log-out logic here (e.g., clear authentication tokens, reset app state)
    // For demonstration purposes, this example simply navigates back to the login page.
    Navigator.pushNamedAndRemoveUntil(context, '/loginPage', (route) => false);
  }

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Do you want to log out?',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Call the log-out function when the "Log Out" button is pressed.
                  _handleLogOut(context);
                },
                child: const Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
