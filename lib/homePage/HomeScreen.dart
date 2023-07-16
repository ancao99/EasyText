import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mess_app/chats/Chat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  // This controller will store the value of the search bar
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
      Navigator.pushNamed(context, '/');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/people');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Welcome to EasyText',
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
              leading: const Icon(Icons.contact_page_outlined),
              title: const Text('New People'),
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
              title: const Text('Account Setting'),
              onTap: () {
                Navigator.pushNamed(context, '/accountSetting');
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Chat(),
                ),
              );
            },
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text('Contact $index'),
            subtitle: const Text('Last message'),
            trailing: const Text('Time'),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[100],
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.red,
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
                    decoration: InputDecoration(
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