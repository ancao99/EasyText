import 'package:flutter/material.dart';
class RegisterSignInPage extends StatelessWidget {
  const RegisterSignInPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/screen1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.pushNamed(context, '/logIn');
                  },
                  child:Container(
                    width: 145.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Image.asset(
                                'assets/signin.png',
                                width: 30.0,
                                height: 30.0,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/logIn');
                              },
                            ),
                            const Text('Sign in',
                              style: TextStyle(
                                fontSize: 18,
                              ),),
                          ],
                        )
                    ),),
                ),
                SizedBox(height: 20.0),
                GestureDetector(
                  onTap: (){
                    Navigator.pushNamed(context, '/signIn');
                  },
                  child:Container(
                    width: 150.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Image.asset(
                                'assets/signup.png',
                                width: 30.0,
                                height: 30.0,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/signIn');
                              },
                            ),
                            const Text('Register',
                              style: TextStyle(
                                fontSize: 18,
                              ),),
                          ],
                        )
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}