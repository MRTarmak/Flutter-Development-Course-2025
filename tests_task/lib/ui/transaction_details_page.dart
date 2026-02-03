import 'package:flutter/material.dart';
import '../../data/transaction_item.dart';

class TransactionDetailsPage extends StatelessWidget {
  final TransactionItem item;
  const TransactionDetailsPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final dateText = item.date.toLocal().toString().split(' ').first;
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Category: ${item.category}'),
                const SizedBox(height: 8),
                Text('Date: $dateText'),
                const SizedBox(height: 8),
                Text('Amount: ${item.isIncome ? '+' : '-'}${item.amount.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text(item.isIncome ? 'Type: Income' : 'Type: Loss'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
