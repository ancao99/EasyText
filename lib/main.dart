import 'package:flutter/material.dart';
import 'package:mess_app/homePage/Home.dart';
import 'package:mess_app/homePage/HomeScreen.dart';
import 'package:mess_app/drawer/LogIn.dart';
import 'package:mess_app/drawer/MassageRequest.dart';
import 'package:mess_app/drawer/SignIn.dart';
import 'package:mess_app/drawer/LogOut.dart';
import 'package:mess_app/chats/Chat.dart';
import 'package:mess_app/chats/People.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      routes:{
        '/':(context) => const Home(),
        '/massageRequest':(context) => const SpamMessage(),
        '/logIn':(context) => const LogIn(),
        '/signIn':(context) => const SignIn(),
        '/logOut':(context) => const LogOut(),
        '/chat':(context)=> const Chat(),
        '/people':(context)=>const People(),
      },
      initialRoute: '/',
      title: "Project",
      theme: ThemeData(primaryColor: Colors.blue[100]),
    );
  }
}