import 'package:flutter/material.dart';
import 'package:mess_app/homePage/Home.dart';
import 'package:mess_app/homePage/HomeScreen.dart';
import 'package:mess_app/drawer/LogIn.dart';
import 'package:mess_app/drawer/SignIn.dart';
import 'package:mess_app/drawer/LogOut.dart';
import 'package:mess_app/chats/Chat.dart';
import 'package:mess_app/homePage/SignInPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mess_app/homePage/deleteAccount.dart';
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      routes:{
        '/':(context) =>  const Home(),
        '/logIn':(context) => const LogIn(),
        '/signIn':(context) => const SignUp(),
        '/logOut':(context) => const LogOut(),
        '/chat':(context)=> Chat(),
        '/afterHome':(context)=>const HomeScreen(),
        '/registerPage':(context) =>const SignInPage(),
        '/deleteAccount':(context) => DeleteAccountPage(),



      },
      initialRoute: '/',
      title: "Project",
      theme: ThemeData(primaryColor: Colors.blue[100]),
    );
  }

}