import 'package:flutter/material.dart';
import 'package:mess_app/homePage/HomeScreen.dart';
import 'package:mess_app/homePage/SignInPage.dart';
class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context)=> const SignInPage(),),);
      },
      child: Scaffold(
        body:Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image:AssetImage('assets/screen.png'),
                    fit:BoxFit.cover
                ),
              ),),
            const Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 150, 0, 20),
                child: Text('* click everywhere to continue *',
                style: TextStyle(fontSize: 15))
             ),
            )
          ],
        )
      )
    );
  }
}