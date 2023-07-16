import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class People extends StatefulWidget {
  const People({Key? key}) : super(key: key);
  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<People> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to another page based on the selected index
    if (index == 0) {
      Navigator.pushNamed(context, '/afterHome');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/people');
    }
  }
  final textControler = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // Mock list of contacts
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('People',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.blue[100],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[100],
              ),
              child: const Row(
                children: [
                  Icon(Icons.person, color: Colors.black),
                  SizedBox(width: 10),
                  Text(
                    'Hello Username',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_rounded),
              title: const Text('Chats'),
              onTap: () {
                Navigator.pushNamed(context, '/afterHome');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Spam Massage'),
              onTap: () {
                Navigator.pushNamed(context, '/massageRequest');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Log Out'),
              onTap: () {
                Navigator.pushNamed(context, '/logOut');
              },
            ),
          ],
        ),
      ),
      body:Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('contact').snapshots(),
          builder: (context,AsyncSnapshot<QuerySnapshot> snapshot){
            if (snapshot.hasData){
              return ListView(
                children: snapshot.data!.docs.map((contact){
                  return Center(
                    child: ListTile(
                      title: Text(contact['name']),
                    ),
                  );
                }).toList(),
              );
            }else{
              return CircularProgressIndicator();
            }
          },
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[100],
        unselectedItemColor: Colors.red,
        selectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          //Chats item
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded),label:'chats'),
          //People item
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded),label: 'people'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show the bottom sheet with the search bar
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  height: 60,
                  child: TextField(
                    autofocus: false,
                    focusNode: _searchFocusNode,
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: Icon(Icons.search),
      ),
    );
  }
}