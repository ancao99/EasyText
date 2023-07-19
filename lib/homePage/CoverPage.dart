import 'package:flutter/material.dart';
import '../homePage/SignInPage.dart';
import 'RegisterSigInPage.dart';

class CoverPage extends StatelessWidget {
  const CoverPage({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegisterSignInPage(),
            ),
          );
        },
        child: Scaffold(
            body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/screen.png'), fit: BoxFit.cover),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 150, 0, 20),
                  child: Text('* click everywhere to continue *',
                      style: TextStyle(fontSize: 15))),
            )
          ],
        )));
  }
}
