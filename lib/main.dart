import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../homePage/CoverPage.dart';
import '../homePage/HomePage.dart';

import 'firebase_options.dart';
import 'gobal_data.dart';
import 'homePage/RegisterSigInPage.dart';
import 'homePage/SignInPage.dart';
import 'homePage/SignUpPage.dart';
import 'homePage/deleteAccount.dart';
import 'homePage/logOut.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        MyRouter.CoverPage: (context) => const CoverPage(),
        MyRouter.HomePage: (context) => const HomePage(),
        '/Home':(context) => const HomePage(),
        '/logIn':(context) => const SignInPage(),
        '/signIn':(context) => const SignUpPage(),
        '/logOut':(context) => const LogOut(),
        '/deleteAccount':(context) => DeleteAccountPage(),
        '/registerSigninPage':(context) => RegisterSignInPage(),


      },
      initialRoute: MyRouter.CoverPage,
      title: "Project",
      theme: ThemeData(primaryColor: Colors.blue[100]),
    );
  }
}
