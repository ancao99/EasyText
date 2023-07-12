import 'package:flutter/material.dart';
class SpamMessage extends StatelessWidget {
  const SpamMessage({super.key});

  @override
  Widget build(BuildContext context){
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Spam message'),
      ),
      body:
      ListView.builder(
        itemBuilder: (context,index){
          return GestureDetector(
            onTap:(){
              Navigator.pushNamed(context,'/chat');
            },
            child: ListTile(
              title:Text('Item $index',)
            )
          );
        },
      )
    );
  }

}