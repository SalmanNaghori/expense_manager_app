import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/calculation/rule_engine.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_state.dart';

// Cross-feature BLoC references (Presentation Layer boundaries)
import '../../../settings/presentation/bloc/theme_cubit.dart';
import '../../../settings/presentation/bloc/theme_state.dart';

/// **Presentation Layer - Analytics Screen**
/// 
/// Computes and renders expenditure distributions and dynamic pie chart visuals.
/// Conforms to Clean Architecture by interacting strictly through Presentation layer 
/// blocks and global calculation configurations.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ruleEngine = getIt<RuleEngine>();

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, financeState) {
            final transactions = financeState.transactions;

            // 1. Calculate expenditures by category
            final Map<String, double> categorySums = {};
            double totalExpenses = 0.0;
            int antigravityCount = 0;

            for (final tx in transactions) {
              final account = tx.accountRef.target;
              final bool isAntigravityTx = ruleEngine.isAntigravity(
                account?.accountId ?? '',
                tx.category,
                tx.tagsList,
              );

              if (isAntigravityTx) {
                antigravityCount++;
              }

              if (tx.transactionType == 'expense') {
                final catName = tx.category.replaceAll('_', ' ').toUpperCase();
                categorySums[catName] = (categorySums[catName] ?? 0.0) + tx.amount;
                totalExpenses += tx.amount;
              }
            }

            // Map sums to sections
            final List<PieChartSectionData> chartSections = [];
            final List<Color> sectionColors = [
              AppColors.primaryNeon,
              AppColors.secondaryNeon,
              AppColors.accentNeon,
              Colors.amberAccent,
              Colors.lightGreenAccent,
              Colors.pinkAccent,
              Colors.orangeAccent,
              Colors.tealAccent,
            ];

            int colorIndex = 0;
            categorySums.forEach((cat, sum) {
              final percentage = totalExpenses > 0 ? (sum / totalExpenses) * 100 : 0.0;
              final color = sectionColors[colorIndex % sectionColors.length];
              
              chartSections.add(
                PieChartSectionData(
                  color: color,
                  value: sum,
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: 40,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
              colorIndex++;
            });

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'ANALYTICS LEDGER',
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Visual insights on expenditures and inverted strategies',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // expenditures overview card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: AppColors.getCardBackground(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.getBorderColor(context)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL DETECTED EXPENSES',
                            style: TextStyle(
                              color: AppColors.getTextSecondary(context).withOpacity(0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            CurrencyFormatter.format(
                              totalExpenses,
                              themeState.currency,
                              locale: themeState.locale.languageCode,
                            ),
                            style: TextStyle(
                              color: AppColors.getTextPrimary(context),
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '$antigravityCount Inverted calculation strategies applied.',
                                style: TextStyle(
                                  color: AppColors.getTextSecondary(context),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Visual Pie Chart
                    if (categorySums.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        alignment: Alignment.center,
                        child: Text(
                          'No expenditures recorded to display charts.',
                          style: TextStyle(color: AppColors.getTextMuted(context), fontSize: 13),
                        ),
                      )
                    else ...[
                      Container(
                        height: 220,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.getCardBackground(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.getBorderColor(context)),
                        ),
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 50,
                            sections: chartSections,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Breakdown Legend List
                      Text(
                        'CATEGORY EXPENDITURES BREAKDOWN',
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categorySums.length,
                        itemBuilder: (context, index) {
                          final catName = categorySums.keys.elementAt(index);
                          final sum = categorySums.values.elementAt(index);
                          final color = sectionColors[index % sectionColors.length];
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.getCardBackground(context),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.getBorderColor(context)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    catName,
                                    style: TextStyle(
                                      color: AppColors.getTextPrimary(context),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(
                                    sum,
                                    themeState.currency,
                                    locale: themeState.locale.languageCode,
                                  ),
                                  style: TextStyle(
                                    color: AppColors.getTextPrimary(context),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
