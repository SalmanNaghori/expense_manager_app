import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/calculation/rule_engine.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/adaptive_scaffold.dart';
import '../../../../core/widgets/adaptive_text_field.dart';
import '../../../../core/widgets/adaptive_button.dart';
import '../../data/models/bank_account.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../widgets/antigravity_badge.dart';

/// **Presentation Layer - Add Transaction Screen**
/// 
/// Serves as the user entry pane for logging new transaction data.
/// Connects user gestures with [FinanceBloc] boundaries and renders 
/// dynamic Antigravity Mode details using context calculations.
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagController = TextEditingController();

  String _transactionType = 'expense'; // expense, income
  BankAccount? _selectedAccount;
  String _selectedCategory = 'dining_food';
  final List<String> _tags = [];
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'dining_food',
    'shopping',
    'entertainment',
    'travel',
    'loan_repayment',
    'cashback_reward',
    'salary',
    'investment',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  bool _checkAntigravityStatus() {
    if (_selectedAccount == null) return false;
    final ruleEngine = getIt<RuleEngine>();
    return ruleEngine.isAntigravity(
      _selectedAccount!.accountId,
      _selectedCategory,
      _tags,
    );
  }

  void _addTag() {
    final rawTag = _tagController.text.trim().toLowerCase().replaceAll('#', '');
    if (rawTag.isNotEmpty && !_tags.contains(rawTag)) {
      setState(() {
        _tags.add(rawTag);
        _tagController.clear();
      });
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ruleEngine = getIt<RuleEngine>();

    return AdaptiveScaffold(
      backgroundColor: AppColors.getBackground(context),
      title: Text(
        l10n.addTransaction,
        style: TextStyle(color: AppColors.getTextPrimary(context), fontWeight: FontWeight.bold, fontSize: 18),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: Icon(
            Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.macOS
                ? CupertinoIcons.back
                : Icons.arrow_back_ios_new_rounded,
            color: AppColors.getTextPrimary(context),
            size: 20,
          ),
        ),
      ),
      body: Hero(
        tag: 'add_transaction_fab',
        child: Material(
          type: MaterialType.transparency,
          child: BlocBuilder<FinanceBloc, FinanceState>(
            builder: (context, state) {
              final accounts = state.accounts;

              // Default set first account if not preselected
              if (_selectedAccount == null && accounts.isNotEmpty) {
                _selectedAccount = accounts.first;
              }

              final bool isAntigravityActive = _checkAntigravityStatus();
              final double activeAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
              final String activeCurrency = _selectedAccount?.currency ?? 'INR';

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Transaction Type Segmented Toggle
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _transactionType = 'expense'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: _transactionType == 'expense'
                                      ? AppColors.getPrimaryGradient(context)
                                      : null,
                                  color: _transactionType == 'expense'
                                      ? null
                                      : AppColors.getCardBackground(context),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _transactionType == 'expense'
                                        ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                                        : AppColors.getBorderColor(context),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    l10n.expense,
                                    style: TextStyle(
                                      color: _transactionType == 'expense'
                                          ? Colors.white
                                          : AppColors.getTextSecondary(context),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _transactionType = 'income'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: _transactionType == 'income'
                                      ? AppColors.getSecondaryGradient(context)
                                      : null,
                                  color: _transactionType == 'income'
                                      ? null
                                      : AppColors.getCardBackground(context),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _transactionType == 'income'
                                        ? Theme.of(context).colorScheme.secondary.withOpacity(0.5)
                                        : AppColors.getBorderColor(context),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    l10n.income,
                                    style: TextStyle(
                                      color: _transactionType == 'income'
                                          ? Colors.white
                                          : AppColors.getTextSecondary(context),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 2. Amount Input Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                           color: AppColors.getCardBackground(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.getBorderColor(context)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n.amount.toUpperCase()} ($activeCurrency)',
                              style: TextStyle(
                                color: AppColors.getTextSecondary(context),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AdaptiveTextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(
                                color: AppColors.getTextPrimary(context),
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                              onChanged: (_) => setState(() {}),
                              placeholder: '0.00',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Bank Account Selection Dropdown
                      Text(
                        l10n.bankAccount.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.getCardBackground(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.getBorderColor(context)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<BankAccount>(
                            dropdownColor: AppColors.getCardBackground(context),
                            value: _selectedAccount,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.getTextPrimary(context)),
                            onChanged: (BankAccount? val) {
                              setState(() {
                                _selectedAccount = val;
                              });
                            },
                            items: accounts.map((acc) {
                              final bool isAntigravityAccount = ruleEngine.isAntigravity(acc.accountId, '', []);
                              return DropdownMenuItem<BankAccount>(
                                value: acc,
                                child: Row(
                                  children: [
                                    Text(
                                      acc.accountName,
                                      style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isAntigravityAccount)
                                      const Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 16)
                                    else
                                      Text(
                                        '(${acc.accountType})',
                                        style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 11),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4. Category Selection Dropdown
                      Text(
                        l10n.category.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.getCardBackground(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.getBorderColor(context)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: AppColors.getCardBackground(context),
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.getTextPrimary(context)),
                            onChanged: (String? val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCategory = val;
                                });
                              }
                            },
                            items: _categories.map((cat) {
                              final bool isAntigravityCat = ruleEngine.isAntigravity('', cat, []);
                              return DropdownMenuItem<String>(
                                value: cat,
                                child: Row(
                                  children: [
                                    Text(
                                      cat.replaceAll('_', ' ').toUpperCase(),
                                      style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
                                    ),
                                    if (isAntigravityCat) ...[
                                      const SizedBox(width: 8),
                                      const Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 16),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 5. Custom Dynamic Tags Input
                      Text(
                        l10n.tags.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.getCardBackground(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.getBorderColor(context)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: AdaptiveTextField(
                                controller: _tagController,
                                style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13),
                                placeholder: 'Add trigger tags (e.g. speculative-invert)',
                                onSubmitted: (_) => _addTag(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.secondaryNeon),
                              onPressed: _addTag,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) {
                          final bool isAntigravityTag = ruleEngine.isAntigravity('', '', [tag]);
                          return Chip(
                            label: Text('#$tag'),
                            labelStyle: TextStyle(
                              color: isAntigravityTag ? Colors.amberAccent : AppColors.getTextPrimary(context),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: isAntigravityTag
                                ? Colors.purple.shade900
                                : AppColors.getCardBackground(context),
                            side: BorderSide(
                              color: isAntigravityTag
                                  ? Colors.purpleAccent
                                  : AppColors.getBorderColor(context),
                            ),
                            deleteIconColor: Colors.redAccent,
                            onDeleted: () {
                              setState(() {
                                _tags.remove(tag);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // 6. Notes field
                       AdaptiveTextField(
                        controller: _notesController,
                        style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13),
                        labelText: 'Notes',
                        placeholder: 'Enter transaction description...',
                      ),
                      const SizedBox(height: 24),

                      // 7. Date picker button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DATE SEQUENCE',
                            style: TextStyle(
                              color: AppColors.getTextSecondary(context),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.calendar_month_rounded, color: AppColors.secondaryNeon, size: 18),
                            label: Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(color: AppColors.secondaryNeon, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 8. Dynamic Real-time Antigravity Status Badge
                      AntigravityBadge(
                        isAntigravityActive: isAntigravityActive,
                        amount: activeAmount,
                        currency: activeCurrency,
                      ),
                      const SizedBox(height: 36),

                       SizedBox(
                        width: double.infinity,
                        child: AdaptiveButton(
                          onPressed: () {
                            if (activeAmount <= 0.0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid amount greater than zero.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }

                            if (_selectedAccount == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select or create an account.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }

                            // Dispatch Add transaction event
                            context.read<FinanceBloc>().add(
                                  AddTransactionEvent(
                                    amount: activeAmount,
                                    date: _selectedDate,
                                    category: _selectedCategory,
                                    transactionType: _transactionType,
                                    notes: _notesController.text.trim(),
                                    tags: _tags,
                                    accountDbId: _selectedAccount!.id,
                                  ),
                                );

                            Navigator.pop(context);
                          },
                          child: const Text(
                            'RECORD ENTRY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
