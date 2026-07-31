import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onTabChange;

  const DashboardScreen({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.email?.split('@')[0] ?? 'User';
    final currentUserId = user?.uid;
    
    final today = DateTime.now();
    final dateString = "${today.day} ${_getMonthName(today.month)}, ${today.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'LifeOS', 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black87)
        ),
        backgroundColor: Colors.transparent, 
        elevation: 0,
        actions: [
          // 🎯 লগআউট বাটনে কনফার্মেশন পপ-আপ যুক্ত করা হয়েছে
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.black54),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text('Logout? 🚪', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)),
                  content: Text('Are you sure you want to log out of your account?', style: GoogleFonts.poppins(color: Colors.grey.shade700)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // ক্যান্সেল করলে পপ-আপ বন্ধ হবে
                      child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context); // আগে পপ-আপ বন্ধ হবে
                        await FirebaseAuth.instance.signOut(); // এরপর লগআউট হবে
                        if (context.mounted) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade500, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: Text('Logout', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $userName 👋',
                style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.black87, height: 1.2),
              ),
              const SizedBox(height: 6),
              Text(
                dateString,
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),

              Text(
                'Overview',
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.9, 
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildDynamicStudyCard(currentUserId),
                  _buildDynamicExpenseCard(currentUserId),
                  _buildDynamicNotesCard(currentUserId),
                  _buildSummaryCard(
                    icon: Icons.rocket_launch_rounded, 
                    title: 'Goals', 
                    subtitle: 'Coming Soon', 
                    gradientColors: [Colors.orange.shade400, Colors.deepOrange.shade600], 
                    onTap: () {}
                  ),
                ],
              ),
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildDynamicStudyCard(String? userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('study_sessions').where('userId', isEqualTo: userId).snapshots(),
      builder: (context, snapshot) {
        double totalHours = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) totalHours += (doc['time'] as num).toDouble();
        }
        String subtitle = snapshot.connectionState == ConnectionState.waiting ? '...' : '${totalHours.toStringAsFixed(1)} Hrs';
        return _buildSummaryCard(
          icon: Icons.menu_book_rounded, 
          title: 'Study', 
          subtitle: subtitle, 
          gradientColors: [Colors.blue.shade400, Colors.indigo.shade600], 
          onTap: () => onTabChange(1),
        );
      },
    );
  }

  Widget _buildDynamicExpenseCard(String? userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('expenses').where('userId', isEqualTo: userId).snapshots(),
      builder: (context, snapshot) {
        double totalExpense = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) totalExpense += (doc['amount'] as num).toDouble();
        }
        String subtitle = snapshot.connectionState == ConnectionState.waiting ? '...' : '৳ ${totalExpense.toStringAsFixed(0)}';
        return _buildSummaryCard(
          icon: Icons.account_balance_wallet_rounded, 
          title: 'Expense', 
          subtitle: subtitle, 
          gradientColors: [Colors.pink.shade400, Colors.red.shade600], 
          onTap: () => onTabChange(2),
        );
      },
    );
  }

  Widget _buildDynamicNotesCard(String? userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('notes').where('userId', isEqualTo: userId).snapshots(),
      builder: (context, snapshot) {
        int totalNotes = 0;
        if (snapshot.hasData) totalNotes = snapshot.data!.docs.length;
        String subtitle = snapshot.connectionState == ConnectionState.waiting ? '...' : '$totalNotes Written';
        return _buildSummaryCard(
          icon: Icons.sticky_note_2_rounded, 
          title: 'Notes', 
          subtitle: subtitle, 
          gradientColors: [Colors.teal.shade400, Colors.green.shade600], 
          onTap: () => onTabChange(3),
        );
      },
    );
  }

  Widget _buildSummaryCard({required IconData icon, required String title, required String subtitle, required List<Color> gradientColors, required VoidCallback onTap}) {
    return AnimatedCardBounce(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors[1].withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(subtitle, style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class AnimatedCardBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const AnimatedCardBounce({super.key, required this.child, required this.onTap});

  @override
  State<AnimatedCardBounce> createState() => _AnimatedCardBounceState();
}

class _AnimatedCardBounceState extends State<AnimatedCardBounce> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.0, upperBound: 0.05)..addListener(() { setState(() {});});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Transform.scale(scale: _scale, child: widget.child),
    );
  }
}