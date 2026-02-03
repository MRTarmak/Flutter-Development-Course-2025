import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:tests_task/domain/transaction_cubit.dart';
import 'package:tests_task/data/transaction_item.dart';
import 'package:tests_task/domain/transaction_repository.dart';

class FakeTransactionRepository implements TransactionRepository {
  List<TransactionItem> _items = [];

  @override
  Future<List<TransactionItem>> loadTransactions() async => List.of(_items);

  @override
  Future<void> saveTransactions(List<TransactionItem> transactions) async {
    _items = List.of(transactions);
  }

  Future<void> clear() async {
    _items.clear();
  }
}

void main() {
  group('TransactionCubit', () {
    late FakeTransactionRepository repo;
    late TransactionCubit cubit;

    setUp(() {
      repo = FakeTransactionRepository();
      cubit = TransactionCubit(repo);
    });

    tearDown(() async {
      await repo.clear();
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state.transactions, isEmpty);
      expect(cubit.state.filter, TransactionFilter.all);
      expect(cubit.state.query, '');
    });

    blocTest<TransactionCubit, TransactionState>(
      'add transaction',
      build: () => cubit,
      act: (c) async {
        final item = TransactionItem(
          date: DateTime(2024, 1, 1),
          category: 'Food',
          name: 'Lunch',
          amount: 10,
          isIncome: false,
        );
        await c.add(item);
      },
      expect: () => [
        isA<TransactionState>().having((s) => s.transactions.length, 'transactions', 1),
      ],
    );

    blocTest<TransactionCubit, TransactionState>(
      'filter income',
      build: () => cubit,
      act: (c) async {
        await c.add(TransactionItem(
          date: DateTime(2024, 1, 1),
          category: 'Salary',
          name: 'Job',
          amount: 1000,
          isIncome: true,
        ));
        await c.add(TransactionItem(
          date: DateTime(2024, 1, 2),
          category: 'Food',
          name: 'Lunch',
          amount: 10,
          isIncome: false,
        ));
        c.setFilter(TransactionFilter.income);
      },
      verify: (c) {
        final filtered = c.state.transactions.where((t) => t.isIncome).toList();
        expect(filtered.length, 1);
        expect(filtered.first.name, 'Job');
      },
      expect: () => [],
    );

    blocTest<TransactionCubit, TransactionState>(
      'search by name',
      build: () => cubit,
      act: (c) async {
        await c.add(TransactionItem(
          date: DateTime(2024, 1, 1),
          category: 'Salary',
          name: 'Job',
          amount: 1000,
          isIncome: true,
        ));
        await c.add(TransactionItem(
          date: DateTime(2024, 1, 2),
          category: 'Food',
          name: 'Lunch',
          amount: 10,
          isIncome: false,
        ));
        c.setQuery('Lunch');
      },
      verify: (c) {
        final filtered = c.state.transactions.where((t) => t.name.toLowerCase().contains('lunch')).toList();
        expect(filtered.length, 1);
        expect(filtered.first.name, 'Lunch');
      },
      expect: () => [],
    );
  });
}
