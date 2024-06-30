import 'package:flutter/material.dart';

import 'package:shopping_list/Screens/new_item.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/grocery_tile.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final List<GroceryItem> _groceryItems = groceryItems;

  void _addItem() async {
    final groceryItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItemScreen(),
      ),
    );

    if (groceryItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(groceryItem);
    });
  }

  void _dismissItem(int index, GroceryItem groceryItem) {
    setState(() {
      _groceryItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Grocery deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _groceryItems.insert(index, groceryItem);
            });
          },
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 16,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Image.asset(
            'assets/groceries_add.png',
            width: 250,
            height: 400,
          ),
        ),
        const Center(
          child: Text(
            'Once you add a new grocery, you\'ll see it listed here',
          ),
        ),
      ],
    );

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          background: Container(
            color: Theme.of(context).colorScheme.error,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.delete_sweep,
                  size: 32,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                const SizedBox(
                  width: 16,
                ),
              ],
            ),
          ),
          onDismissed: (direction) {
            _dismissItem(index, _groceryItems[index]);
          },
          child: GroceryTile(groceryItem: _groceryItems[index]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        elevation: 5,
      ),
      body: content,
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
