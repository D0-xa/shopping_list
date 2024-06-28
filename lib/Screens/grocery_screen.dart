import 'package:flutter/material.dart';

import 'package:shopping_list/Screens/new_item.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/widgets/grocery_tile.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  void _addItem() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewItemScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        elevation: 5,
      ),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (context, index) =>
            GroceryTile(groceryItem: groceryItems[index]),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          right: 20,
          bottom: 24,
        ),
        child: FloatingActionButton(
          heroTag: 1,
          tooltip: 'Add new grocery item',
          onPressed: _addItem,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
