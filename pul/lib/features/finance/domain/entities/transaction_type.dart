enum TransactionType {
  income,
  expense;

  String get label => switch (this) {
    TransactionType.income => 'Girdeji',
    TransactionType.expense => 'Çykdajy',
  };
}
