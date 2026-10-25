import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_dependencies.dart';
import 'core/theme/app_theme.dart';
import 'features/finance/presentation/bloc/finance_bloc.dart';
import 'features/finance/presentation/bloc/finance_event.dart';
import 'features/finance/presentation/pages/dashboard_page.dart';

class PulApp extends StatelessWidget {
  const PulApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FinanceBloc(
        dependencies.getFinanceData,
        dependencies.saveTransaction,
        dependencies.deleteTransaction,
        dependencies.setBalanceVisibility,
        dependencies.clearFinanceData,
        dependencies.importTransactions,
        dependencies.saveCustomCategory,
        dependencies.deleteCustomCategory,
      )..add(const FinanceStarted()),
      child: MaterialApp(
        title: 'PUL',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('tr'),
        supportedLocales: const [Locale('tr')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const DashboardPage(),
      ),
    );
  }
}
