import 'package:flutter/material.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<StatefulWidget> createState() => NewItemScreenState();
}

class NewItemScreenState extends State<NewItemScreen> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New grocery item'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                  validator: (value) {
                    return 'Demo...';
                  },
                ), // instead of TextField()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
