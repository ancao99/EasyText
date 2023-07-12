import 'package:flutter/material.dart';

class People extends StatelessWidget {
  const People({Key? key});

  @override
  Widget build(BuildContext context) {
    // Mock list of contacts
    final List<String> contacts = [
      'People 1',
      'People 2',
      'People 3',
      // Add more contacts as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(contact),
            onTap: () {
              Navigator.pushNamed(context,'/chat');
            },
          );
        },
      ),
    );
  }
}

