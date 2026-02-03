part of 'transaction_cubit.dart';

enum TransactionStatus { initial, loading, loaded }
enum TransactionFilter { all, income, losses }

class TransactionState extends Equatable {
  final List<TransactionItem> transactions;
  final TransactionStatus status;
  final TransactionFilter filter;
  final String query;

  const TransactionState({
    required this.transactions,
    required this.status,
    required this.filter,
    required this.query,
  });

  factory TransactionState.initial() => const TransactionState(
        transactions: [],
        status: TransactionStatus.initial,
        filter: TransactionFilter.all,
        query: '',
      );

  TransactionState copyWith({
    List<TransactionItem>? transactions,
    TransactionStatus? status,
    TransactionFilter? filter,
    String? query,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      status: status ?? this.status,
      filter: filter ?? this.filter,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [transactions, status, filter, query];
}
