import 'package:flutter/material.dart';
class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.blue[100],
      ),
      body: Container(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
              children:[
                const Text(
                    'Username',
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold
                    )
                ),
                const TextField(
                  decoration: InputDecoration(
                      hintText: 'Enter your username'
                  ),
                ),
                const Text(
                    'Password',
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold
                    )
                ),
                const TextField(
                    decoration: InputDecoration(
                        hintText: 'Enter your password'
                    )
                ),
                ElevatedButton(onPressed: ()
                {
                  print('Log In');
                  Navigator.pushNamed(context,'/logIn');
                },
                  child: const Text('Log In'),
                ),
              ]
          )
      ),

    );
  }

}