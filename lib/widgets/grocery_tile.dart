import 'package:flutter/material.dart';

import 'package:shopping_list/models/grocery_item.dart';

class GroceryTile extends StatelessWidget {
  const GroceryTile({
    super.key,
    required this.groceryItem,
    required this.editGrocery,
  });

  final GroceryItem groceryItem;
  final void Function() editGrocery;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        decoration: BoxDecoration(
          color: groceryItem.category.color,
          borderRadius: BorderRadius.circular(5),
        ),
        height: 24,
        width: 24,
      ),
      horizontalTitleGap: 30,
      title: Text(groceryItem.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(groceryItem.quantity.toString()),
          const SizedBox(
            width: 10,
          ),
          IconButton.filledTonal(
            onPressed: editGrocery,
            icon: const Icon(Icons.edit_rounded),
          )
        ],
      ),
      leadingAndTrailingTextStyle: TextStyle(
          fontSize: 16, color: Theme.of(context).colorScheme.inverseSurface),
    );
  }
}
