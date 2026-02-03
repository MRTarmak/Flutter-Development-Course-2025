import '../data/transaction_item.dart';

abstract class TransactionRepository {
  Future<List<TransactionItem>> loadTransactions();
  Future<void> saveTransactions(List<TransactionItem> transactions);
}