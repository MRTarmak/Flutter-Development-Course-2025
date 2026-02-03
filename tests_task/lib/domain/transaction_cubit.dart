import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/transaction_item.dart';
import '../../domain/transaction_repository.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository repository;

  TransactionCubit(this.repository) : super(TransactionState.initial()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(status: TransactionStatus.loading));
    final items = await repository.loadTransactions();
    emit(state.copyWith(
      status: TransactionStatus.loaded,
      transactions: items,
    ));
  }

  Future<void> add(TransactionItem item) async {
    final updated = [item, ...state.transactions];
    emit(state.copyWith(transactions: updated));
    await repository.saveTransactions(updated);
  }

  void setFilter(TransactionFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  void setQuery(String query) {
    emit(state.copyWith(query: query));
  }
}
