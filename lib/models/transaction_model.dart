import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  double amount;

  @HiveField(2)
  bool isIncome;

  @HiveField(3)
  DateTime date;

  TransactionModel({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.date,
  });
}
