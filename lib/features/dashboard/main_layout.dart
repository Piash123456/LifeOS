import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'dashboard_screen.dart';
import '../study/study_screen.dart';
import '../expense/expense_screen.dart';
import '../notes/notes_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(onTabChange: _onTabChange),
      const StudyScreen(),
      const ExpenseScreen(),
      const NotesScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        // 🎯 Margin কিছুটা কমানো হয়েছে যাতে স্ক্রিনে বেশি জায়গা পায়
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 6, // 🎯 আইকন ও টেক্সটের মাঝের গ্যাপ কমানো হয়েছে
              activeColor: Colors.white,
              iconSize: 24,
              // 🎯 Padding কমিয়ে দেওয়া হয়েছে যাতে ওভারল্যাপ না হয় (এটাই মূল সমাধান)
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), 
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.deepPurple,
              color: Colors.grey.shade600,
              tabs: const [
                GButton(icon: Icons.dashboard_rounded, text: 'Home'),
                GButton(icon: Icons.menu_book_rounded, text: 'Study'),
                GButton(icon: Icons.account_balance_wallet_rounded, text: 'Expense'),
                GButton(icon: Icons.sticky_note_2_rounded, text: 'Notes'),
              ],
              selectedIndex: _currentIndex,
              onTabChange: _onTabChange,
            ),
          ),
        ),
      ),
    );
  }
}