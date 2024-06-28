import 'package:flutter/material.dart';
import 'package:shopping_list/grocery_screen.dart';

final kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 106, 219, 247),
  surface: const Color.fromARGB(255, 102, 125, 146),
);

final kdarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 147, 229, 250),
  brightness: Brightness.dark,
  surface: const Color.fromARGB(255, 42, 51, 59),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: kColorScheme,
        scaffoldBackgroundColor: const Color.fromARGB(255, 114, 130, 137),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: kdarkColorScheme,
        scaffoldBackgroundColor: const Color.fromARGB(255, 50, 58, 60),
      ),
      title: 'Flutter Groceries',
      home: const GroceryScreen(),
    );
  }
}