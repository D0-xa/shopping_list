import 'package:flutter/material.dart';

import 'package:shopping_list/models/grocery_item.dart';

class GroceryTile extends StatelessWidget {
  const GroceryTile({
    super.key,
    required this.groceryItem,
  });

  final GroceryItem groceryItem;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Row(
      children: [
        Container(
          color: groceryItem.category.color,
          height: 24,
          width: 24,
        ),
        const SizedBox(
          width: 40,
        ),
        Text(groceryItem.name),
        const Spacer(),
        Text('${groceryItem.quantity}'),
      ],
    ));
  }
}
