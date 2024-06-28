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
    final String quantityType = groceryItem.quantity.runtimeType == double
        ? ' Kg'
        : groceryItem.quantity > 1
            ? ' Items'
            : 'Item';

    return ListTile(
      leading: Container(
        color: groceryItem.category.color,
        height: 24,
        width: 24,
      ),
      horizontalTitleGap: 30,
      title: Text(groceryItem.name),
      trailing: Text(groceryItem.quantity.toString() + quantityType),
      leadingAndTrailingTextStyle: const TextStyle(fontSize: 16),
    );
  }
}
