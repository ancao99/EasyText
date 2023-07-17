import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mess_app/homePage/CoverPage.dart';
import 'package:mess_app/homePage/HomePage.dart';

import 'firebase_options.dart';
import 'gobal_data.dart';
import 'homePage/SignInPage.dart';
import 'homePage/SignUpPage.dart';

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
        MyRouter.SignUpPage: (context) => const SignUpPage(),
        MyRouter.SignInPage: (context) => const SignInPage(),
        MyRouter.HomePage: (context) => const HomePage(),
      },
      initialRoute: MyRouter.CoverPage,
      title: "Project",
      theme: ThemeData(primaryColor: Colors.blue[100]),
    );
  }
}
