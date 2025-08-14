import 'package:expense_tracker/Screens/HomeScreen2.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/transaction_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important for async code

  await Hive.initFlutter(); // Initialize Hive for Flutter
  Hive.registerAdapter(TransactionModelAdapter()); // Register the adapter
await Hive.openBox<TransactionModel>('transactions');
await Hive.openBox<double>('balanceBox'); // new box for balance

  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
