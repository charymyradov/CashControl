import 'package:shared_preferences/shared_preferences.dart';

import 'features/finance/data/datasources/finance_local_data_source.dart';
import 'features/finance/data/repositories/finance_repository_impl.dart';
import 'features/finance/domain/repositories/finance_repository.dart';
import 'features/finance/domain/usecases/clear_finance_data.dart';
import 'features/finance/domain/usecases/delete_transaction.dart';
import 'features/finance/domain/usecases/delete_custom_category.dart';
import 'features/finance/domain/usecases/get_finance_data.dart';
import 'features/finance/domain/usecases/import_transactions.dart';
import 'features/finance/domain/usecases/save_transaction.dart';
import 'features/finance/domain/usecases/save_custom_category.dart';
import 'features/finance/domain/usecases/set_balance_visibility.dart';

class AppDependencies {
  const AppDependencies({
    required this.getFinanceData,
    required this.saveTransaction,
    required this.deleteTransaction,
    required this.setBalanceVisibility,
    required this.clearFinanceData,
    required this.importTransactions,
    required this.saveCustomCategory,
    required this.deleteCustomCategory,
  });

  /// Builds the whole app on top of the local storage of the device.
  factory AppDependencies.local(SharedPreferences preferences) {
    final repository = FinanceRepositoryImpl(
      FinanceLocalDataSource(preferences),
    );
    return AppDependencies.fromRepository(repository);
  }

  factory AppDependencies.fromRepository(FinanceRepository repository) {
    return AppDependencies(
      getFinanceData: GetFinanceData(repository),
      saveTransaction: SaveTransaction(repository),
      deleteTransaction: DeleteTransaction(repository),
      setBalanceVisibility: SetBalanceVisibility(repository),
      clearFinanceData: ClearFinanceData(repository),
      importTransactions: ImportTransactions(repository),
      saveCustomCategory: SaveCustomCategory(repository),
      deleteCustomCategory: DeleteCustomCategory(repository),
    );
  }

  final GetFinanceData getFinanceData;
  final SaveTransaction saveTransaction;
  final DeleteTransaction deleteTransaction;
  final SetBalanceVisibility setBalanceVisibility;
  final ClearFinanceData clearFinanceData;
  final ImportTransactions importTransactions;
  final SaveCustomCategory saveCustomCategory;
  final DeleteCustomCategory deleteCustomCategory;
}
