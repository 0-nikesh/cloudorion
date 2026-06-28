import 'package:flutter/material.dart';

import '../features/group_expense/presentation/group_expense_page.dart';
import '../features/party_transaction/presentation/party_transaction_page.dart';
import '../features/personal_expense/presentation/personal_expense_page.dart';

class AppRoutes {
  static const home = '/';
  static const partyTransaction = '/party-transaction';
  static const personalExpense = '/personal-expense';
  static const groupExpense = '/group-expense';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) {
        switch (settings.name) {
          case partyTransaction:
            return const PartyTransactionPage();
          case personalExpense:
            return const PersonalExpensePage();
          case groupExpense:
            return const GroupExpensePage();
          case home:
          default:
            return const HomePage();
        }
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        title: 'Add Party Transaction',
        subtitle: 'Received or given money',
        icon: Icons.swap_vert_rounded,
        route: AppRoutes.partyTransaction,
      ),
      (
        title: 'Add Personal Expense',
        subtitle: 'Income and daily spending',
        icon: Icons.account_balance_wallet_rounded,
        route: AppRoutes.personalExpense,
      ),
      (
        title: 'Add Group Expense',
        subtitle: 'Shared split among members',
        icon: Icons.groups_rounded,
        route: AppRoutes.groupExpense,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Orion Assessment')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                minVerticalPadding: 18,
                leading: CircleAvatar(child: Icon(item.icon)),
                title: Text(item.title),
                subtitle: Text(item.subtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).pushNamed(item.route),
              ),
            );
          },
        ),
      ),
    );
  }
}
