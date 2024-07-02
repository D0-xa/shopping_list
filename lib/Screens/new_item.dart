import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({
    super.key,
    this.selectedGrocery,
  });

  final GroceryItem? selectedGrocery;

  @override
  State<StatefulWidget> createState() => NewItemScreenState();
}

class NewItemScreenState extends State<NewItemScreen> {
  final _formKey = GlobalKey<FormState>();
  var _enteredId = '';
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedGrocery != null) {
      _enteredId = widget.selectedGrocery!.id;
      _enteredName = widget.selectedGrocery!.name;
      _enteredQuantity = widget.selectedGrocery!.quantity;
      _selectedCategory = widget.selectedGrocery!.category;
    }
  }

  void _showSnackBar(String info) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(info),
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

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });

      try {
        if (widget.selectedGrocery == null) {
          final url = Uri.https('flutter-prep-4022-default-rtdb.firebaseio.com',
              'shopping-list.json');
          final response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(
              {
                'name': _enteredName,
                'quantity': _enteredQuantity,
                'category': _selectedCategory.title,
              },
            ),
          );

          final Map<String, dynamic> idData = json.decode(response.body);
          _enteredId = idData['name'];
        } else {
          final url = Uri.https('flutter-prep-4022-default-rtdb.firebaseio.com',
              'shopping-list/$_enteredId.json');
          final response = await http.patch(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(
              {
                'name': _enteredName,
                'quantity': _enteredQuantity,
                'category': _selectedCategory.title,
              },
            ),
          );

          if (response.statusCode >= 400) {
            throw Exception('Not Found');
          }
        }

        if (!context.mounted) {
          return;
        }

        Navigator.of(context).pop(
          GroceryItem(
            id: _enteredId,
            name: _enteredName,
            quantity: _enteredQuantity,
            category: _selectedCategory,
          ),
        );
      } catch (error) {
        setState(() {
          _isSending = false;
        });

        _showSnackBar(
          'An error occured! Check internet connection',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New grocery item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                autofocus: true,
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                initialValue: _enteredName,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 to 50 characters long.';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _enteredName = newValue!.trim();
                },
              ), // instead of TextField()
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                      initialValue: _enteredQuantity.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid, positive integer.';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _enteredQuantity = int.parse(newValue!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: category.value.color,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  width: 16,
                                  height: 16,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(category.value.title),
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator.adaptive(),
                          )
                        : const Text('Add Grocery'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
