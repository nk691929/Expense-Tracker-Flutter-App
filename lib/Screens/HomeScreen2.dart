import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<TransactionModel> transactionBox;
  late Box<double> balanceBox;

  @override
  void initState() {
    super.initState();
    transactionBox = Hive.box<TransactionModel>('transactions');
    balanceBox = Hive.box<double>('balanceBox');
    if (balanceBox.isEmpty) {
      balanceBox.put('balance', 0.0);
    }
  }

  double get balance => balanceBox.get('balance', defaultValue: 0.0)!;
  double get totalIncome =>
      transactionBox.values.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);
  double get totalExpense =>
      transactionBox.values.where((t) => !t.isIncome).fold(0, (sum, t) => sum + t.amount);

  void _updateBalance(double amount, bool isIncome, {bool reverse = false}) {
    double currentBalance = balanceBox.get('balance')!;
    if (reverse) {
      currentBalance -= isIncome ? amount : -amount;
    } else {
      currentBalance += isIncome ? amount : -amount;
    }
    balanceBox.put('balance', currentBalance);
  }

  void _deleteTransaction(int index) {
    final deletedTransaction = transactionBox.getAt(index)!;

    transactionBox.deleteAt(index);
    _updateBalance(deletedTransaction.amount, deletedTransaction.isIncome, reverse: true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Deleted '${deletedTransaction.title}'"),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            final transactions = transactionBox.values.toList();
            transactions.insert(index, deletedTransaction);
            transactionBox.clear();
            transactionBox.addAll(transactions);
            _updateBalance(deletedTransaction.amount, deletedTransaction.isIncome);
          },
        ),
      ),
    );
  }

  void _addBalanceManually() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add Initial Balance", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Enter balance amount",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text) ?? 0.0;
              final currentBalance = balanceBox.get('balance')!;
              balanceBox.put('balance', currentBalance + value);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text("Add", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 5),
          Text("\$${amount.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  void _viewTransaction(TransactionModel t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Amount: \$${t.amount.toStringAsFixed(2)}"),
            Text("Type: ${t.isIncome ? "Income" : "Expense"}"),
            Text("Date: ${t.date.toLocal()}".split(' ')[0]),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text("Income");
                    case 1:
                      return const Text("Expense");
                    default:
                      return const Text("");
                  }
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalIncome, color: Colors.green, width: 30)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: totalExpense, color: Colors.red, width: 30)]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.account_balance_wallet), onPressed: _addBalanceManually),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Summary Cards
              SizedBox(
                height: 150,
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<double>('balanceBox').listenable(),
                  builder: (context, Box<double> box, _) {
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildSummaryCard("Income", totalIncome, Colors.green, Icons.arrow_downward),
                        _buildSummaryCard("Expense", totalExpense, Colors.red, Icons.arrow_upward),
                        _buildSummaryCard("Balance", balance, Colors.blue, Icons.account_balance_wallet),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Bar Chart
              ValueListenableBuilder(
                valueListenable: transactionBox.listenable(),
                builder: (context, _, __) => _buildBarChart(),
              ),

              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Transactions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),

              // ⬇️ IMPORTANT: No Expanded inside SingleChildScrollView
              ValueListenableBuilder(
                valueListenable: transactionBox.listenable(),
                builder: (context, Box<TransactionModel> box, _) {
                  if (box.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Text("No transactions added.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final t = box.getAt(index)!;
                      return Dismissible(
                        key: Key('${t.key}-$index'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteTransaction(index),
                        background: Container(
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(15)),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            onTap: () => _viewTransaction(t),
                            leading: CircleAvatar(
                              backgroundColor: t.isIncome ? Colors.green : Colors.red,
                              child: Icon(t.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
                            ),
                            title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${t.date.toLocal()}".split(' ')[0]),
                            trailing: Text(
                              "\$${t.amount.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: t.isIncome ? Colors.green : Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          final newTransaction = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
          if (newTransaction != null) {
            transactionBox.add(newTransaction);
            _updateBalance(newTransaction.amount, newTransaction.isIncome);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
