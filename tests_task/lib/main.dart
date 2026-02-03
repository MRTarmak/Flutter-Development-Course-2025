import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'data/transaction_repository_impl.dart';
import 'domain/transaction_cubit.dart';
import 'domain/transaction_repository.dart';
import 'ui/main_page.dart';

void main() {
  runApp(const MoneyTrackerApp());
}

class MoneyTrackerApp extends StatelessWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TransactionRepository>(create: (_) => TransactionRepositoryImpl()),
      ],
      child: Builder(
        builder: (context) => BlocProvider(
          create: (_) => TransactionCubit(context.read<TransactionRepository>()),
          child: MaterialApp(
            title: 'Money Tracker',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              useMaterial3: true,
            ),
            home: const MainPage(),
          ),
        ),
      ),
    );
  }
}