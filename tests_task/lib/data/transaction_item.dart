class TransactionItem {
  final DateTime date;
  final String category;
  final String name;
  final double amount;
  final bool isIncome;

  TransactionItem({
    required this.date,
    required this.category,
    required this.name,
    required this.amount,
    required this.isIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'name': name,
      'amount': amount,
      'isIncome': isIncome,
    };
  }

  static TransactionItem fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      category: map['category'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      isIncome: map['isIncome'] as bool,
    );
  }
}
