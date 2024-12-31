
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget{
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: const Text('about')),
      body: const Column(
        children: [
          Text('about')
        ],
      ),
    );
  }
  
}