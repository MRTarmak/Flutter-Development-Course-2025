import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/transaction_item.dart';
import '../../domain/transaction_cubit.dart';
import 'add_transaction_page.dart';
import 'transaction_details_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final filtered = _filtered(state);
        final balance = _balance(filtered);
        return Scaffold(
          appBar: AppBar(title: const Text('Money Tracker')),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.of(context).push<TransactionItem>(
                MaterialPageRoute(builder: (_) => const AddTransactionPage()),
              );
              if (result != null) {
                context.read<TransactionCubit>().add(result);
              }
            },
            child: const Icon(Icons.add),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text('Balance', style: TextStyle(fontSize: 18)),
                        const Spacer(),
                        Text(
                          balance.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: balance >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => context.read<TransactionCubit>().setQuery(value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: state.filter == TransactionFilter.all,
                        onSelected: (_) => context.read<TransactionCubit>().setFilter(TransactionFilter.all),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Income'),
                        selected: state.filter == TransactionFilter.income,
                        onSelected: (_) => context.read<TransactionCubit>().setFilter(TransactionFilter.income),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Losses'),
                        selected: state.filter == TransactionFilter.losses,
                        onSelected: (_) => context.read<TransactionCubit>().setFilter(TransactionFilter.losses),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: state.status == TransactionStatus.loading
                      ? const Center(child: CircularProgressIndicator())
                      : filtered.isEmpty
                          ? const Center(child: Text('No transactions'))
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                return ListTile(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TransactionDetailsPage(item: item),
                                    ),
                                  ),
                                  title: Text(item.name),
                                  subtitle: Text(
                                    '${item.category} • ${item.date.toLocal().toString().split(' ').first}',
                                  ),
                                  trailing: Text(
                                    (item.isIncome ? '+' : '-') + item.amount.toStringAsFixed(2),
                                    style: TextStyle(
                                      color: item.isIncome ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<TransactionItem> _filtered(TransactionState state) {
    return state.transactions.where((t) {
      final matchesFilter = state.filter == TransactionFilter.all ||
          (state.filter == TransactionFilter.income && t.isIncome) ||
          (state.filter == TransactionFilter.losses && !t.isIncome);
      final q = state.query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          t.name.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  double _balance(List<TransactionItem> transactions) {
    double total = 0;
    for (final t in transactions) {
      total += t.isIncome ? t.amount : -t.amount;
    }
    return total;
  }
}
