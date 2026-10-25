import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/clear_finance_data.dart';
import '../../domain/usecases/delete_custom_category.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_finance_data.dart';
import '../../domain/usecases/import_transactions.dart';
import '../../domain/usecases/save_transaction.dart';
import '../../domain/usecases/save_custom_category.dart';
import '../../domain/usecases/set_balance_visibility.dart';
import 'finance_event.dart';
import 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  FinanceBloc(
    this._getFinanceData,
    this._saveTransaction,
    this._deleteTransaction,
    this._setBalanceVisibility,
    this._clearFinanceData,
    this._importTransactions,
    this._saveCustomCategory,
    this._deleteCustomCategory,
  ) : super(const FinanceState()) {
    on<FinanceStarted>(_onStarted, transformer: _sequential());
    on<TransactionSaved>(_onTransactionSaved, transformer: _sequential());
    on<TransactionDeleted>(_onTransactionDeleted, transformer: _sequential());
    on<BalanceVisibilityToggled>(
      _onBalanceVisibilityToggled,
      transformer: _sequential(),
    );
    on<FinanceDataCleared>(_onFinanceDataCleared, transformer: _sequential());
    on<LedgerImported>(_onLedgerImported, transformer: _sequential());
    on<CustomCategorySaved>(_onCustomCategorySaved, transformer: _sequential());
    on<CustomCategoryDeleted>(
      _onCustomCategoryDeleted,
      transformer: _sequential(),
    );
  }

  final GetFinanceData _getFinanceData;
  final SaveTransaction _saveTransaction;
  final DeleteTransaction _deleteTransaction;
  final SetBalanceVisibility _setBalanceVisibility;
  final ClearFinanceData _clearFinanceData;
  final ImportTransactions _importTransactions;
  final SaveCustomCategory _saveCustomCategory;
  final DeleteCustomCategory _deleteCustomCategory;

  Future<void> _onStarted(
    FinanceStarted event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(status: FinanceStatus.loading, clearError: true));

    try {
      final snapshot = await _getFinanceData();
      emit(
        state.copyWith(
          status: FinanceStatus.ready,
          transactions: snapshot.transactions,
          customCategories: snapshot.customCategories,
          isBalanceHidden: snapshot.isBalanceHidden,
          clearError: true,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: FinanceStatus.failure,
          errorMessage: 'Maglumatlary ýüklemek başartmady.',
        ),
      );
    }
  }

  Future<void> _onTransactionSaved(
    TransactionSaved event,
    Emitter<FinanceState> emit,
  ) async {
    emit(
      state.copyWith(isSaving: true, clearError: true, clearLastSavedId: true),
    );

    try {
      await _saveTransaction(event.transaction);
      final snapshot = await _getFinanceData();
      emit(
        state.copyWith(
          status: FinanceStatus.ready,
          transactions: snapshot.transactions,
          isBalanceHidden: snapshot.isBalanceHidden,
          isSaving: false,
          lastSavedId: event.transaction.id,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Amaly ýatda saklamak başartmady.',
        ),
      );
    }
  }

  Future<void> _onTransactionDeleted(
    TransactionDeleted event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      await _deleteTransaction(event.id);
      final snapshot = await _getFinanceData();
      emit(
        state.copyWith(
          status: FinanceStatus.ready,
          transactions: snapshot.transactions,
          isBalanceHidden: snapshot.isBalanceHidden,
          isSaving: false,
          lastDeletedId: event.id,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Amaly pozmak başartmady.',
        ),
      );
    }
  }

  Future<void> _onBalanceVisibilityToggled(
    BalanceVisibilityToggled event,
    Emitter<FinanceState> emit,
  ) async {
    final nextValue = !state.isBalanceHidden;
    emit(state.copyWith(isBalanceHidden: nextValue, clearError: true));

    try {
      await _setBalanceVisibility(nextValue);
    } on Object {
      emit(
        state.copyWith(
          isBalanceHidden: !nextValue,
          errorMessage: 'Sazlamany ýatda saklamak başartmady.',
        ),
      );
    }
  }

  Future<void> _onFinanceDataCleared(
    FinanceDataCleared event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      await _clearFinanceData();
      final snapshot = await _getFinanceData();
      emit(
        state.copyWith(
          status: FinanceStatus.ready,
          transactions: snapshot.transactions,
          isBalanceHidden: snapshot.isBalanceHidden,
          isSaving: false,
          clearLastSavedId: true,
          clearLastDeletedId: true,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Maglumatlary öçürmek başartmady.',
        ),
      );
    }
  }

  Future<void> _onLedgerImported(
    LedgerImported event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      await _importTransactions(event.transactions);
      if (event.customCategories != null) {
        final current = await _getFinanceData();
        for (final category in current.customCategories) {
          await _deleteCustomCategory(category.id);
        }
        for (final category in event.customCategories!) {
          await _saveCustomCategory(category);
        }
      }
      final snapshot = await _getFinanceData();
      emit(
        state.copyWith(
          status: FinanceStatus.ready,
          transactions: snapshot.transactions,
          customCategories: snapshot.customCategories,
          isBalanceHidden: snapshot.isBalanceHidden,
          isSaving: false,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Maglumatlary getirmek başartmady.',
        ),
      );
    }
  }

  Future<void> _onCustomCategorySaved(
    CustomCategorySaved event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _saveCustomCategory(event.category);
      final snapshot = await _getFinanceData();
      emit(
        state.copyWith(
          customCategories: snapshot.customCategories,
          isSaving: false,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Kategoriýany ýatda saklamak başartmady.',
        ),
      );
    }
  }

  Future<void> _onCustomCategoryDeleted(
    CustomCategoryDeleted event,
    Emitter<FinanceState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _deleteCustomCategory(event.id);
      final snapshot = await _getFinanceData();
      emit(
        state.copyWith(
          customCategories: snapshot.customCategories,
          isSaving: false,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Kategoriýany pozmak başartmady.',
        ),
      );
    }
  }
}

/// Processes the events of one handler one after the other.
///
/// The default behaviour of bloc runs the events concurrently, which lets a
/// quick second action read the storage before the first one finished
/// writing it.
EventTransformer<Event> _sequential<Event>() {
  return (events, mapper) => events.asyncExpand(mapper);
}
