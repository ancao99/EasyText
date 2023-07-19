import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DeleteAccountPage extends StatelessWidget {
  const DeleteAccountPage({Key? key}) : super(key: key);

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
                      'Do you want to delete account? ',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          User? user = FirebaseAuth.instance.currentUser;
                          var db = FirebaseFirestore.instance;
                          final userCollection = db.collection("Users");
                          userCollection.doc(user!.uid).delete();
                          await user?.delete();
                          // If the deletion is successful, navigate to the login page.
                          Navigator.pushReplacementNamed(context, '/registerSigninPage');
                        } catch (e) {
                          // Handle any errors during the account deletion, if necessary.
                          print('Error deleting account: $e');
                        }
                      },
                      child: const Text('Delete'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Optionally, provide a cancel option to dismiss the delete account page
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
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