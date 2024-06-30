import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list/Screens/new_item.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/grocery_tile.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  final url = Uri.https(
      'flutter-prep-4022-default-rtdb.firebaseio.com', 'shopping-list.json');

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final response = await http.get(url);
    final Map<String, dynamic> groceryData = json.decode(response.body);
    final List<GroceryItem> loadedGroceries = [];
    for (final grocery in groceryData.entries) {
      final category = categories.entries
          .firstWhere(
            (category) => category.value.title == grocery.value['category'],
          )
          .value;
      loadedGroceries.add(
        GroceryItem(
          id: grocery.key,
          name: grocery.value['name'],
          quantity: grocery.value['quantity'],
          category: category,
        ),
      );
    }

    setState(() {
      _groceryItems = loadedGroceries;
      _isLoading = false;
    });
  }

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

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

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
