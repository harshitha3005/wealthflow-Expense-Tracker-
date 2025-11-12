import 'package:flutter/material.dart';
import 'dart:math';

// ------------------- 1. Data Models and Constants -------------------

enum TransactionType { expense, income }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String category;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });

  String get amountFormatted =>
      '${type == TransactionType.expense ? '-' : '+'}${_formatCurrency(amount)}';
  
  static String _formatCurrency(double amount) => '₹${amount.toStringAsFixed(0)}';
}

class Goal {
  final String id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final DateTime dueDate;

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.dueDate,
  });

  double get progress => min(savedAmount / targetAmount, 1.0);
}

const Map<String, IconData> categoryIcons = {
  'Food': Icons.restaurant_menu_rounded,
  'Transport': Icons.directions_bus_rounded,
  'Salary': Icons.account_balance_wallet_rounded,
  'Entertainment': Icons.local_movies_rounded,
  'Utilities': Icons.lightbulb_outline_rounded,
  'Investment': Icons.trending_up_rounded,
  'Other': Icons.category_rounded,
};

// ------------------- 2. Main Application -------------------

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkBackground = Color(0xFF0F172A); // Slate 900
    const Color darkCard = Color(0xFF1E293B); // Slate 800
    const Color primaryColor = Color(0xFF4C1D95); // Deep Violet
    const Color accentColor = Color(0xFF22D3EE); // Bright Cyan

    return MaterialApp(
      title: 'WealthFlow: Financial Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: darkBackground,
        cardColor: darkCard,
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: primaryColor,
          secondary: accentColor,
          background: darkBackground,
          surface: darkCard,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBackground,
          elevation: 2, // Added slight elevation for header
          shadowColor: Colors.black54,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: darkCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
        ),
      ),
      home: const WealthFlowAppScaffold(),
    );
  }
}

// ------------------- 3. Main Scaffold & Navigation (Stateful) -------------------

class WealthFlowAppScaffold extends StatefulWidget {
  const WealthFlowAppScaffold({super.key});

  @override
  State<WealthFlowAppScaffold> createState() => _WealthFlowAppScaffoldState();
}

class _WealthFlowAppScaffoldState extends State<WealthFlowAppScaffold> {
  int _selectedIndex = 0; 
  
  // Core Data State
  double monthlyBudget = 50000.0;
  List<Transaction> transactions = [
    Transaction(id: 't1', title: 'Monthly Salary', amount: 85000.00, date: DateTime.now().subtract(const Duration(days: 3)), type: TransactionType.income, category: 'Salary'),
    Transaction(id: 't2', title: 'Groceries & Household', amount: 4200.00, date: DateTime.now().subtract(const Duration(days: 1)), type: TransactionType.expense, category: 'Food'),
    Transaction(id: 't3', title: 'Internet & Mobile Bill', amount: 1250.00, date: DateTime.now(), type: TransactionType.expense, category: 'Utilities'),
    Transaction(id: 't4', title: 'Bike EMI', amount: 5500.00, date: DateTime.now().subtract(const Duration(days: 4)), type: TransactionType.expense, category: 'Transport'),
    Transaction(id: 't5', title: 'Stock Dividend', amount: 1500.00, date: DateTime.now().subtract(const Duration(days: 10)), type: TransactionType.income, category: 'Investment'),
  ];
  List<Goal> goals = [
    Goal(id: 'g1', title: 'New Laptop', targetAmount: 60000.0, savedAmount: 15000.0, dueDate: DateTime.now().add(const Duration(days: 90))),
    Goal(id: 'g2', title: 'Vacation to Goa', targetAmount: 25000.0, savedAmount: 8000.0, dueDate: DateTime.now().add(const Duration(days: 180))),
  ];

  // Getters for computed values
  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get currentBalance => totalIncome - totalExpense;

  double get monthlyExpense => transactions
      .where((t) => t.type == TransactionType.expense && t.date.month == DateTime.now().month)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get budgetProgress => min(monthlyExpense / monthlyBudget, 1.0);

  Map<String, double> get dailyExpenseData {
    Map<String, double> data = {};
    for (int i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final dayKey = '${day.day}/${day.month}';
      
      final totalForDay = transactions
          .where((t) => t.type == TransactionType.expense && t.date.day == day.day)
          .fold(0.0, (sum, t) => sum + t.amount);

      data[dayKey] = totalForDay;
    }
    return data;
  }
  
  // Data Manipulation Callbacks
  void _addTransaction(Transaction newTransaction) {
    setState(() {
      transactions.add(newTransaction);
      transactions.sort((a, b) => b.date.compareTo(a.date));
    });
  }
  
  void _deleteTransaction(String id) {
    setState(() {
      transactions.removeWhere((tx) => tx.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction Deleted'), duration: Duration(seconds: 1)),
    );
  }

  void _setMonthlyBudget(double newBudget) {
    setState(() {
      monthlyBudget = newBudget;
    });
  }

  void _addGoal(Goal newGoal) {
    setState(() {
      goals.add(newGoal);
    });
  }

  void _updateGoal(String id, double contribution) {
    setState(() {
      final index = goals.indexWhere((g) => g.id == id);
      if (index != -1) {
        Goal oldGoal = goals[index];
        goals[index] = Goal(
          id: oldGoal.id,
          title: oldGoal.title,
          targetAmount: oldGoal.targetAmount,
          savedAmount: min(oldGoal.savedAmount + contribution, oldGoal.targetAmount),
          dueDate: oldGoal.dueDate,
        );
      }
    });
    // Subtract the contribution from the general balance as an expense
    _addTransaction(Transaction(
      id: DateTime.now().toString(), 
      title: 'Goal Contribution: ${goals.firstWhere((g) => g.id == id).title}', 
      amount: contribution, 
      date: DateTime.now(), 
      type: TransactionType.expense, 
      category: 'Investment' // Use investment for savings goals
    ));
  }

  void _openAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, 
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: TransactionForm(addTx: _addTransaction),
        );
      },
    );
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Page List - using an approach that rebuilds with fresh data
  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          currentBalance: currentBalance,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          monthlyBudget: monthlyBudget,
          monthlyExpense: monthlyExpense,
          budgetProgress: budgetProgress,
          dailyExpenseData: dailyExpenseData,
          transactions: transactions.take(5).toList(), // Show only top 5 in dashboard
          deleteTransaction: _deleteTransaction,
        );
      case 1:
        return CalendarScreen(transactions: transactions);
      case 2:
        return AnalysisScreen(transactions: transactions);
      case 3:
        return GoalsScreen(goals: goals, addGoal: _addGoal, updateGoal: _updateGoal);
      case 4:
        return SettingsScreen(monthlyBudget: monthlyBudget, setMonthlyBudget: _setMonthlyBudget);
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0), // Added top and bottom padding
            child: Text(
              'WealthFlow', // Centered and dynamic title removed
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).cardColor, // Header color set to cardColor for consistency
        elevation: Theme.of(context).appBarTheme.elevation,
        shadowColor: Theme.of(context).appBarTheme.shadowColor,
      ),
      
      body: _getCurrentPage(), 

      // Floating Action Button (for adding primary data type)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTransactionModal(context),
        label: const Text('New Entry', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 10,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      
      // Bottom Navigation Bar (Footer)
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_rounded),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_rounded),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune_rounded),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.white54,
        backgroundColor: Theme.of(context).cardColor, // Footer color consistent with header
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ------------------- 4. Dashboard Screen (Home) -------------------

class DashboardScreen extends StatelessWidget {
  final double currentBalance;
  final double totalIncome;
  final double totalExpense;
  final double monthlyBudget;
  final double monthlyExpense;
  final double budgetProgress;
  final Map<String, double> dailyExpenseData;
  final List<Transaction> transactions;
  final Function deleteTransaction;

  const DashboardScreen({
    super.key,
    required this.currentBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.monthlyBudget,
    required this.monthlyExpense,
    required this.budgetProgress,
    required this.dailyExpenseData,
    required this.transactions,
    required this.deleteTransaction,
  });

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, const Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Net Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${currentBalance.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildMetric('Income', totalIncome, Colors.greenAccent, Icons.arrow_upward_rounded),
              _buildMetric('Expenses', totalExpense, Colors.redAccent, Icons.arrow_downward_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String title, double amount, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Progress (This Month)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: budgetProgress,
                minHeight: 18,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(
                  budgetProgress > 0.8 ? Colors.redAccent : Colors.tealAccent,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ₹${monthlyExpense.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Limit: ₹${monthlyBudget.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseChart(BuildContext context) {
    final maxExpense = dailyExpenseData.values.isEmpty ? 1.0 : dailyExpenseData.values.reduce(max);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last 7 Days Expense Trend',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dailyExpenseData.entries.map<Widget>((entry) {
                  final heightRatio = maxExpense == 0 ? 0 : entry.value / maxExpense;
                  return Bar(
                    key: ValueKey<String>(entry.key),
                    label: entry.key,
                    amount: entry.value,
                    height: heightRatio * 100,
                    color: Theme.of(context).colorScheme.secondary,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            'Recent Activity',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        if (transactions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                'No recent transactions.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          )
        else
          ...transactions.map<Widget>((tx) {
            final bool isExpense = tx.type == TransactionType.expense;
            return Dismissible(
              key: ValueKey<String>(tx.id),
              direction: DismissDirection.endToStart,
              onDismissed: (DismissDirection direction) {
                deleteTransaction(tx.id);
              },
              background: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 30),
              ),
              child: Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isExpense
                          ? Colors.red.withOpacity(0.15)
                          : Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      categoryIcons[tx.category] ?? Icons.category_rounded,
                      color: isExpense ? Colors.redAccent : Colors.greenAccent,
                    ),
                  ),
                  title: Text(
                    tx.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    tx.category,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       Text(
                        tx.amountFormatted,
                        style: TextStyle(
                          color: isExpense ? Colors.redAccent : Colors.greenAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${tx.date.day}/${tx.date.month}',
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildSummaryCard(context),
          _buildBudgetCard(context),
          _buildExpenseChart(context),
          _buildTransactionList(context),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ------------------- 5. Calendar Screen (New Feature) -------------------

class CalendarScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const CalendarScreen({super.key, required this.transactions});
  
  // Group transactions by Date
  Map<DateTime, List<Transaction>> get groupedTransactions {
    final Map<DateTime, List<Transaction>> grouped = {};
    for (var tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(tx);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> sortedDates = groupedTransactions.keys.toList()
      ..sort((DateTime a, DateTime b) => b.compareTo(a));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Monthly Transaction Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Divider(height: 30, color: Colors.white10),

          if (transactions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 80),
                child: Text('No transactions recorded for the calendar view.', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...sortedDates.map<Widget>((date) {
              final List<Transaction> dailyTransactions = groupedTransactions[date]!;
              final double dailyIncome = dailyTransactions.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
              final double dailyExpense = dailyTransactions.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  title: Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${(dailyIncome - dailyExpense).toStringAsFixed(0)}',
                        style: TextStyle(
                          color: (dailyIncome - dailyExpense) >= 0 ? Colors.greenAccent : Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text('Daily Net', style: TextStyle(fontSize: 12, color: Colors.white54)),
                    ],
                  ),
                  children: dailyTransactions.map<Widget>((tx) {
                    final bool isExpense = tx.type == TransactionType.expense;
                    return ListTile(
                      dense: true,
                      leading: Icon(categoryIcons[tx.category], color: Theme.of(context).colorScheme.primary.withOpacity(0.8)),
                      title: Text(tx.title),
                      trailing: Text(
                        tx.amountFormatted,
                        style: TextStyle(
                          color: isExpense ? Colors.redAccent : Colors.greenAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ------------------- 6. Analysis Screen (Category Breakdown) -------------------

class AnalysisScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const AnalysisScreen({super.key, required this.transactions});

  Map<String, double> get categoryExpenseSummary {
    final Map<String, double> summary = {};
    for (var tx in transactions.where((t) => t.type == TransactionType.expense)) {
      summary.update(tx.category, (double value) => value + tx.amount,
          ifAbsent: () => tx.amount);
    }
    return summary;
  }
  
  List<MapEntry<String, double>> get sortedExpenses {
    final List<MapEntry<String, double>> list = categoryExpenseSummary.entries.toList();
    list.sort((MapEntry<String, double> a, MapEntry<String, double> b) => b.value.compareTo(a.value));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, double>> sortedList = sortedExpenses;
    final double totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Expense Breakdown by Category',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Divider(height: 30, color: Colors.white10),
          if (sortedList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 80),
                child: Text('No expenses recorded yet to analyze.', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...sortedList.map<Widget>((entry) {
              final double percentage = totalExpense > 0 ? (entry.value / totalExpense) : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(categoryIcons[entry.key] ?? Icons.category_rounded, color: Theme.of(context).colorScheme.secondary),
                            const SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Text(
                          '₹${entry.value.toStringAsFixed(0)} (${(percentage * 100).toStringAsFixed(1)}%)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 10,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ------------------- 7. Goals Screen (New Feature) -------------------

class GoalsScreen extends StatelessWidget {
  final List<Goal> goals;
  final Function(Goal) addGoal;
  final Function(String, double) updateGoal;

  const GoalsScreen({
    super.key,
    required this.goals,
    required this.addGoal,
    required this.updateGoal,
  });

  void _openAddGoalModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, 
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: AddGoalForm(addGoal: addGoal),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Savings Goals & Reminders',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).colorScheme.secondary, size: 30),
                onPressed: () => _openAddGoalModal(context),
              ),
            ],
          ),
          const Divider(height: 30, color: Colors.white10),

          if (goals.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 80),
                child: Text('No active savings goals. Start saving today!', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...goals.map<Widget>((goal) {
              final int daysLeft = goal.dueDate.difference(DateTime.now()).inDays;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Saved: ₹${goal.savedAmount.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.greenAccent),
                          ),
                          Text(
                            'Target: ₹${goal.targetAmount.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: goal.progress,
                          minHeight: 12,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        daysLeft > 0 ? '$daysLeft days left (Due: ${goal.dueDate.day}/${goal.dueDate.month})' : 'Goal due date passed!',
                        style: TextStyle(fontSize: 14, color: daysLeft < 30 ? Colors.orangeAccent : Colors.white70),
                      ),
                      const SizedBox(height: 15),
                      if (goal.progress < 1.0)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.add_box_rounded),
                            label: const Text('Contribute ₹1,000'),
                            onPressed: () {
                              updateGoal(goal.id, 1000.0);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('₹1,000 contributed to goal!')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.secondary,
                              side: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ------------------- 8. Settings Screen (Budget Management) -------------------

class SettingsScreen extends StatefulWidget {
  final double monthlyBudget;
  final Function(double) setMonthlyBudget;

  const SettingsScreen({
    super.key,
    required this.monthlyBudget,
    required this.setMonthlyBudget,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _budgetController;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController(text: widget.monthlyBudget.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    final double? newBudget = double.tryParse(_budgetController.text);
    if (newBudget != null && newBudget > 0) {
      widget.setMonthlyBudget(newBudget);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Monthly Budget set to ₹${newBudget.toStringAsFixed(0)}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive budget amount.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Custom input decoration for dark theme
    final InputDecoration inputDecoration = InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        labelStyle: const TextStyle(color: Colors.white70));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'App Configuration',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Divider(height: 30, color: Colors.white10),

          // Monthly Budget Setting
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Expense Budget',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Set your target maximum expense limit for the current month.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _budgetController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    decoration: inputDecoration.copyWith(
                      labelText: 'Budget Amount (₹)',
                      prefixText: '₹ ',
                      prefixStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveBudget,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save Budget'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ------------------- 9. Chart Bar Widget (Helper) -------------------

class Bar extends StatelessWidget {
  final String label;
  final double amount;
  final double height;
  final Color color;

  const Bar({super.key, required this.label, required this.amount, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FittedBox(
          child: Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 10, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 100,
          width: 20,
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white10, width: 1.0),
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                heightFactor: height / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

// ------------------- 10. Add Transaction Form Modal (Helper) -------------------

class TransactionForm extends StatefulWidget {
  final Function addTx;
  const TransactionForm({super.key, required this.addTx});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategory = categoryIcons.keys.first;

  void _submitData() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    final double? enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

    final Transaction newTx = Transaction(
      id: DateTime.now().toString(),
      title: _titleController.text,
      amount: enteredAmount,
      date: DateTime.now(),
      type: _selectedType,
      category: _selectedCategory,
    );

    widget.addTx(newTx);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    
    final InputDecoration inputDecoration = InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        labelStyle: const TextStyle(color: Colors.white70));

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, keyboardSpace + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Add New Transaction',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const Divider(height: 30, thickness: 1, color: Colors.white10),
            TextField(
              controller: _titleController,
              decoration: inputDecoration.copyWith(
                labelText: 'Title (e.g., Electricity Bill, Lunch)',
              ),
              onSubmitted: (_) => _submitData(),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: inputDecoration.copyWith(
                labelText: 'Amount (₹)',
                prefixText: '₹ ',
                prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
              onSubmitted: (_) => _submitData(),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TransactionType>(
                    value: _selectedType,
                    decoration: inputDecoration.copyWith(labelText: 'Type'),
                    dropdownColor: Theme.of(context).cardColor,
                    items: const <DropdownMenuItem<TransactionType>>[
                      DropdownMenuItem<TransactionType>(
                        value: TransactionType.expense,
                        child: Text('Expense 🔻', style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem<TransactionType>(
                        value: TransactionType.income,
                        child: Text('Income ⬆', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onChanged: (TransactionType? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedType = newValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: inputDecoration.copyWith(labelText: 'Category'),
                    dropdownColor: Theme.of(context).cardColor,
                    items: categoryIcons.keys.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(categoryIcons[value], size: 20, color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(value, style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitData,
                icon: const Icon(Icons.send_rounded),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text(
                    'Commit Transaction',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- 11. Add Goal Form Modal (Helper) -------------------

class AddGoalForm extends StatefulWidget {
  final Function(Goal) addGoal;

  const AddGoalForm({super.key, required this.addGoal});

  @override
  State<AddGoalForm> createState() => _AddGoalFormState();
}

class _AddGoalFormState extends State<AddGoalForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  void _submitData() {
    final String title = _titleController.text;
    final double? target = double.tryParse(_targetController.text);

    if (title.isEmpty || target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out a valid title and target amount.')),
      );
      return;
    }

    final Goal newGoal = Goal(
      id: DateTime.now().toString(),
      title: title,
      targetAmount: target,
      savedAmount: 0.0,
      dueDate: _dueDate,
    );

    widget.addGoal(newGoal);
    Navigator.of(context).pop();
  }
  
  void _presentDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (BuildContext context, Widget? child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: Theme.of(context).colorScheme.secondary,
            onPrimary: Colors.black,
            surface: Theme.of(context).cardColor,
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: Theme.of(context).cardColor,
        ),
        child: child!,
      ),
    );
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    
    final InputDecoration inputDecoration = InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        labelStyle: const TextStyle(color: Colors.white70));

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, keyboardSpace + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Create New Savings Goal',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const Divider(height: 30, thickness: 1, color: Colors.white10),
            TextField(
              controller: _titleController,
              decoration: inputDecoration.copyWith(
                labelText: 'Goal Name (e.g., Vacation, Down Payment)',
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _targetController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: inputDecoration.copyWith(
                labelText: 'Target Amount (₹)',
                prefixText: '₹ ',
                prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Due Date: ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                TextButton.icon(
                  onPressed: _presentDatePicker,
                  icon: const Icon(Icons.date_range_rounded),
                  label: const Text('Select Date'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                )
              ],
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitData,
                icon: const Icon(Icons.star_rounded),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text(
                    'Create Goal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
