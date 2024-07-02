import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list/Screens/new_item.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/grocery_tile.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen(
    this.isInitial, {
    super.key,
    this.groceryList = const [],
  });

  final bool isInitial;
  final List<GroceryItem> groceryList;

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  final _url = Uri.https(
      'flutter-prep-4022-default-rtdb.firebaseio.com', 'shopping-list.json');
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.isInitial) {
      _isLoading = false;
      _groceryItems = widget.groceryList;
      return;
    }
    _loadItems();
  }

  void _loadItems() async {
    try {
      final response = await http.get(_url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to load data. Please try again later!';
        });
        return;
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

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
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later!';
      });
    }
  }

  void _addItem(int? index, GroceryItem? groceryEdit) async {
    final groceryItem =
        await Navigator.of(context).push<GroceryItem>(PageRouteBuilder(
      transitionDuration: Durations.long4,
      reverseTransitionDuration: Durations.long4,
      pageBuilder: (context, animation, secondaryAnimation) => NewItemScreen(
        selectedGrocery: groceryEdit,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Stack(
          alignment: Alignment.topLeft,
          children: [
            SlideTransition(
              position: animation.drive(
                Tween(
                  begin: Offset.zero,
                  end: const Offset(-0.3, 0),
                ).chain(
                  CurveTween(curve: Curves.easeInOut),
                ),
              ),
              child: GroceryScreen(
                true,
                groceryList: _groceryItems,
              ),
            ),
            SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).chain(
                  CurveTween(curve: Curves.easeInOut),
                ),
              ),
              child: child,
            )
          ],
        );
      },
    ));

    if (groceryItem == null) {
      return;
    }

    if (groceryEdit == null && index == null) {
      setState(() {
        _groceryItems.add(groceryItem);
      });
    } else {
      setState(() {
        _groceryItems.removeAt(index!);
        _groceryItems.insert(index, groceryItem);
      });
    }
  }

  void _showSnackBar(String info, String label, void Function() action) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(info),
        action: SnackBarAction(
          label: label,
          onPressed: action,
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

  void _dismissItem(int index, GroceryItem groceryItem) {
    setState(() {
      _groceryItems.removeAt(index);
    });

    _showSnackBar(
      'Grocery deleted',
      'Undo',
      () {
        setState(() {
          _groceryItems.insert(index, groceryItem);
        });
      },
    );

    Timer(
      const Duration(seconds: 5),
      () async {
        if (!_groceryItems.contains(groceryItem)) {
          try {
            final urlDelete = Uri.https(
                'flutter-prep-4022-default-rtdb.firebaseio.com',
                'shopping-list/${groceryItem.id}.json');

            final response = await http.delete(urlDelete);

            if (response.statusCode >= 400) {
              throw Exception('Not found');
            }
          } catch (error) {
            setState(() {
              _groceryItems.insert(index, groceryItem);
            });

            _showSnackBar(
              'An error occured when trying to delete grocery!',
              'Retry',
              () {
                _dismissItem(index, groceryItem);
              },
            );
          }
        }
      },
    );
  }

  void _editItem(int index, GroceryItem groceryItem) {
    _addItem(index, groceryItem);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      heightFactor: 2,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.asset(
            'assets/groceries_add.png',
            width: 250,
            height: 400,
          ),
          const Text(
            'Once you add a new grocery, you\'ll see it listed here',
          ),
        ],
      ),
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
          child: GroceryTile(
            groceryItem: _groceryItems[index],
            editGrocery: () {
              _editItem(index, _groceryItems[index]);
            },
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.red,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          tooltip: 'Add new grocery item',
          onPressed: _error == null
              ? () {
                  _addItem(null, null);
                }
              : null,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
