import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  
  void _showAddExpenseSheet(BuildContext context) {
    final TextEditingController itemNameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 32),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
              child: Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Add New Expense 💸', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  _buildTextField(controller: itemNameController, hint: 'Item Name (e.g. Lunch)', icon: Icons.shopping_bag_rounded),
                  const SizedBox(height: 16),
                  _buildTextField(controller: amountController, hint: 'Amount (in ৳)', icon: Icons.attach_money_rounded, isNumber: true),
                  const SizedBox(height: 32),
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.pink.shade400, Colors.red.shade600]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: ElevatedButton(
                      onPressed: isSaving ? null : () async {
                        if (itemNameController.text.trim().isEmpty || amountController.text.trim().isEmpty) return;
                        setModalState(() => isSaving = true);
                        try {
                          await FirebaseFirestore.instance.collection('expenses').add({
                            'userId': FirebaseAuth.instance.currentUser?.uid,
                            'itemName': itemNameController.text.trim(),
                            'amount': double.parse(amountController.text.trim()),
                            'date': DateTime.now(),
                          });
                          if (context.mounted) Navigator.pop(context);
                        } finally {
                          setModalState(() => isSaving = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: isSaving ? const CircularProgressIndicator(color: Colors.white) : Text('Save Expense', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, style: GoogleFonts.poppins(color: Colors.black87),
        decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500), prefixIcon: Icon(icon, color: Colors.red.shade300), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16)),
      ),
    );
  }

  Future<void> _deleteExpense(String docId) async {
    await FirebaseFirestore.instance.collection('expenses').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: Text('Expense Tracker', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black87)), backgroundColor: Colors.transparent, elevation: 0),
      floatingActionButton: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))]),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddExpenseSheet(context),
          backgroundColor: Colors.red.shade500, elevation: 0,
          icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white), 
          label: Text('Add Expense', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Text('Recent Expenses', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('expenses').where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text('No expenses recorded yet.', style: GoogleFonts.poppins(color: Colors.grey)));

                  final docs = snapshot.data!.docs;
                  docs.sort((a, b) => (b['date'] as Timestamp).compareTo(a['date'] as Timestamp));

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final docId = docs[index].id;
                      final data = docs[index].data() as Map<String, dynamic>;
                      final timestamp = data['date'] as Timestamp?;
                      final dateString = timestamp != null ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}" : '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                            child: Icon(Icons.attach_money_rounded, color: Colors.red.shade500),
                          ),
                          title: Text(data['itemName'] ?? 'Unknown', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                          subtitle: Text(dateString, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('৳ ${data['amount']}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red.shade600)),
                              const SizedBox(width: 8),
                              
                              // 🎯 ডিলিট বাটন এবং কনফার্মেশন ডায়ালগ
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: Text('Wait! 🛑', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)),
                                      content: Text('Are you sure you want to delete this expense? This action cannot be undone.', style: GoogleFonts.poppins(color: Colors.grey.shade700)),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteExpense(docId); 
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade500, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                          child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                                  child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 22),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}