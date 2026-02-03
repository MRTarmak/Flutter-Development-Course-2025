import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'transaction_item.dart';
import '../domain/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  static const String _prefsKey = 'transactions';

  @override
  Future<List<TransactionItem>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKey) ?? [];
    return stored
        .map((raw) => TransactionItem.fromMap(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveTransactions(List<TransactionItem> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = transactions.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList(_prefsKey, stored);
  }
}
