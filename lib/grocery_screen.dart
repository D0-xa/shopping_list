import 'package:flutter/material.dart';

import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/widgets/grocery_tile.dart';

class GroceryScreen extends StatelessWidget {
  const GroceryScreen({super.key});

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
    );
  }
}
