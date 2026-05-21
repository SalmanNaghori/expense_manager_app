import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/calculation/rule_engine.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/adaptive_dialog.dart';
import '../../../../core/widgets/adaptive_text_field.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../../../settings/presentation/bloc/theme_cubit.dart';
import '../../../settings/presentation/bloc/theme_state.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../screens/add_transaction_screen.dart';

class DashboardHomeView extends StatelessWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ruleEngine = getIt<RuleEngine>();
    final platform = Theme.of(context).platform;
    final isCupertino = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final Color expenseColor = isLight ? Colors.red.shade700 : Colors.redAccent;
    final Color incomeColor = isLight ? Colors.green.shade700 : Colors.greenAccent;
    final Color antigravityColor = isLight ? Colors.amber.shade800 : Colors.amberAccent;
    final Color antigravityBadgeBg = isLight ? Colors.amber.shade100 : Colors.amberAccent.withOpacity(0.15);
    final Color antigravityBadgeBorder = isLight ? Colors.amber.shade300 : Colors.amberAccent.withOpacity(0.3);

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, financeState) {
            if (financeState.isLoading && financeState.accounts.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryNeon),
              );
            }

            final accounts = financeState.accounts;
            final recentTransactions = financeState.transactions;

            // Compute global balances
            double totalBalance = 0.0;
            if (accounts.isNotEmpty) {
              totalBalance = accounts.fold(0.0, (sum, acc) => sum + acc.currentBalance);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<FinanceBloc>().add(LoadFinanceData());
                },
                color: AppColors.primaryNeon,
                backgroundColor: AppColors.getCardBackground(context),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Dynamic premium header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.appTitle,
                                  style: TextStyle(
                                    color: AppColors.getTextPrimary(context),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Strategic Multi-ledger Tracking',
                                  style: TextStyle(
                                    color: AppColors.getTextSecondary(context),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            // Profile Avatar with dynamic gradient glow and optional Cupertino add action
                            Row(
                              children: [
                                if (isCupertino) ...[
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(
                                      CupertinoIcons.add_circled_solid,
                                      color: AppColors.secondaryNeon,
                                      size: 32,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const AddTransactionScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 14),
                                ],
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.getSecondaryGradient(context),
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.getBackground(context),
                                    child: Icon(Icons.person_rounded, color: AppColors.getTextPrimary(context), size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Elegant Glassmorphic Total Balance Card
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          gradient: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkCardGradient
                              : LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.grey.shade100,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.getBorderColor(context),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL NET WORTH',
                              style: TextStyle(
                                color: AppColors.getTextSecondary(context),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              CurrencyFormatter.format(
                                totalBalance,
                                themeState.currency,
                                locale: themeState.locale.languageCode,
                              ),
                              style: TextStyle(
                                color: AppColors.getTextPrimary(context),
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Quick breakdown indicators
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildLedgerStat(
                                  context,
                                  title: 'ACTIVE ACCOUNTS',
                                  value: accounts.length.toString(),
                                  icon: Icons.account_balance_wallet_outlined,
                                  iconColor: AppColors.secondaryNeon,
                                ),
                                _buildLedgerStat(
                                  context,
                                  title: 'TRANSACTIONS',
                                  value: recentTransactions.length.toString(),
                                  icon: Icons.history_toggle_off_rounded,
                                  iconColor: Colors.purpleAccent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Title section - Ledger Accounts
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'LEDGERS',
                              style: TextStyle(
                                color: AppColors.getTextPrimary(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showAddAccountDialog(context),
                              child: Row(
                                children: const [
                                  Icon(Icons.add_rounded, size: 16, color: AppColors.secondaryNeon),
                                  SizedBox(width: 4),
                                  Text(
                                    'New Ledger',
                                    style: TextStyle(
                                      color: AppColors.secondaryNeon,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Horizontal Accounts / Ledgers List
                    accounts.isEmpty
                        ? SliverToBoxAdapter(
                            child: _buildEmptyState(
                              context,
                              message: 'No ledger accounts registered yet.',
                              actionLabel: 'Create custom account',
                              onActionTap: () => _showAddAccountDialog(context),
                            ),
                          )
                        : SliverToBoxAdapter(
                            child: SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: accounts.length,
                                itemBuilder: (context, index) {
                                  final acc = accounts[index];
                                  final isAntigravityAccount = ruleEngine.isAntigravity(acc.accountId, '', []);

                                  return Container(
                                    width: 170,
                                    margin: const EdgeInsets.only(right: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.getCardBackground(context),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isAntigravityAccount
                                            ? Colors.purpleAccent.withOpacity(0.3)
                                            : AppColors.getBorderColor(context),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                acc.accountName,
                                                style: TextStyle(
                                                  color: AppColors.getTextPrimary(context),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isAntigravityAccount)
                                              Icon(
                                                Icons.bolt_rounded,
                                                color: antigravityColor,
                                                size: 18,
                                              ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              CurrencyFormatter.format(
                                                acc.currentBalance,
                                                acc.currency,
                                                locale: themeState.locale.languageCode,
                                              ),
                                              style: TextStyle(
                                                color: isAntigravityAccount
                                                    ? antigravityColor
                                                    : AppColors.getTextPrimary(context),
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              acc.accountType.toUpperCase(),
                                              style: TextStyle(
                                                color: AppColors.getTextMuted(context),
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                    // Title section - Recent Transactions
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'RECENT TRANSACTIONS',
                              style: TextStyle(
                                color: AppColors.getTextPrimary(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Vertical Transaction Ledger History List
                    recentTransactions.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: _buildEmptyState(
                                context,
                                message: 'No recorded transaction ledger entries.',
                                actionLabel: 'Add transaction entry',
                                onActionTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const AddTransactionScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final tx = recentTransactions[index];
                                final account = tx.accountRef.target;
                                final String accountId = account?.accountId ?? '';
                                final isAntigravityTx = ruleEngine.isAntigravity(
                                  accountId,
                                  tx.category,
                                  tx.tagsList,
                                );

                                return Dismissible(
                                  key: Key('tx_${tx.id}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    padding: const EdgeInsets.only(right: 20),
                                    alignment: Alignment.centerRight,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 28),
                                  ),
                                  onDismissed: (direction) {
                                    context.read<FinanceBloc>().add(DeleteTransactionEvent(tx.id));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Transaction record deleted successfully.'),
                                        backgroundColor: AppColors.getCardBackground(context),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: AppColors.getCardBackground(context),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isAntigravityTx
                                            ? Colors.purpleAccent.withOpacity(0.2)
                                            : AppColors.getBorderColor(context),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Dynamic Inverted Indicator Circle Badge
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isAntigravityTx
                                                ? Colors.purple.withOpacity(0.15)
                                                : tx.transactionType == 'expense'
                                                    ? Colors.red.withOpacity(0.1)
                                                    : Colors.green.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isAntigravityTx
                                                  ? Colors.purpleAccent.withOpacity(0.3)
                                                  : Colors.transparent,
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            isAntigravityTx
                                                ? Icons.bolt_rounded
                                                : tx.transactionType == 'expense'
                                                    ? Icons.arrow_outward_rounded
                                                    : Icons.call_received_rounded,
                                            color: isAntigravityTx
                                                ? antigravityColor
                                                : tx.transactionType == 'expense'
                                                    ? expenseColor
                                                    : incomeColor,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        
                                        // Transaction Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tx.category.replaceAll('_', ' ').toUpperCase(),
                                                style: TextStyle(
                                                  color: AppColors.getTextPrimary(context),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                account?.accountName ?? 'Default Account',
                                                style: TextStyle(
                                                  color: AppColors.getTextSecondary(context),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Transaction Math
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${tx.transactionType == 'expense' ? '-' : '+'}${CurrencyFormatter.format(
                                                tx.amount,
                                                account?.currency ?? 'INR',
                                                locale: themeState.locale.languageCode,
                                              )}',
                                              style: TextStyle(
                                                color: tx.transactionType == 'expense'
                                                    ? expenseColor
                                                    : incomeColor,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            if (isAntigravityTx)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: antigravityBadgeBg,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: antigravityBadgeBorder),
                                                ),
                                                child: Text(
                                                  'INVERTED',
                                                  style: TextStyle(
                                                    color: antigravityColor,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              )
                                            else
                                              Text(
                                                _formatDate(tx.date),
                                                style: TextStyle(
                                                  color: AppColors.getTextMuted(context),
                                                  fontSize: 10,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: recentTransactions.length,
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLedgerStat(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onActionTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorderColor(context)),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: AppColors.getTextMuted(context).withOpacity(0.4), size: 40),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onActionTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.secondaryNeon.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(color: AppColors.secondaryNeon, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  void _showAddAccountDialog(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String accountType = 'checking';
    String currency = 'INR';

    AdaptiveDialog.show(
      context: context,
      title: Text(
        'CREATE NEW LEDGER',
        style: TextStyle(
          color: AppColors.getTextPrimary(context),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AdaptiveTextField(
                controller: nameController,
                labelText: 'Ledger Name (e.g. Chase Bank)',
                placeholder: 'Enter account name',
              ),
              const SizedBox(height: 12),
              AdaptiveTextField(
                controller: balanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                labelText: 'Starting Balance',
                placeholder: '0.00',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ledger Type:',
                    style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13),
                  ),
                  DropdownButton<String>(
                    dropdownColor: AppColors.getCardBackground(context),
                    value: accountType,
                    style: TextStyle(color: AppColors.getTextPrimary(context)),
                    onChanged: (val) {
                      if (val != null) setState(() => accountType = val);
                    },
                    items: ['checking', 'savings', 'speculation', 'debt_settlement']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e.toUpperCase(),
                                style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 12),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Currency Ledger:',
                    style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13),
                  ),
                  DropdownButton<String>(
                    dropdownColor: AppColors.getCardBackground(context),
                    value: currency,
                    style: TextStyle(color: AppColors.getTextPrimary(context)),
                    onChanged: (val) {
                      if (val != null) setState(() => currency = val);
                    },
                    items: ['INR', 'USD', 'EUR', 'GBP']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 12),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        AdaptiveDialogAction(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: AppColors.getTextSecondary(context))),
        ),
        AdaptiveDialogAction(
          isDefaultAction: true,
          onPressed: () {
            final name = nameController.text.trim();
            final balance = double.tryParse(balanceController.text.trim()) ?? 0.0;
            if (name.isNotEmpty) {
              final String customStringId = 'acc_${name.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecond}';
              
              context.read<FinanceBloc>().add(
                    AddAccountEvent(
                      accountId: customStringId,
                      accountName: name,
                      accountType: accountType,
                      currency: currency,
                      startingBalance: balance,
                    ),
                  );
              Navigator.pop(context);
            }
          },
          child: const Text('Save Ledger', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
